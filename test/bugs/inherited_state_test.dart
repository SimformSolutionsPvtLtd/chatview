import 'package:chatview/chatview.dart';
import 'package:chatview/src/inherited_widgets/chat_view_inherited_widget.dart';
import 'package:chatview/src/utils/constants/constants.dart' show heart;
import 'package:chatview/src/widgets/message_list/chat_groupedlist_widget.dart';
import 'package:chatview/src/widgets/reactions/reaction_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plan 1.1 (inherited widget state reset): the popup flag and the text field
/// height must survive the host app rebuilding [ChatView].
void main() {
  ChatController newController() => ChatController(
        initialMessageList: [
          Message(
            id: '0',
            message: 'hello',
            createdAt: DateTime(2026, 10, 1, 12),
            sentBy: '2',
          ),
        ],
        scrollController: ScrollController(),
        currentUser: ChatUser(id: '1', name: 'me'),
        otherUsers: [ChatUser(id: '2', name: 'other')],
      );

  Widget host(ChatController controller, void Function(StateSetter) onSet) =>
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              onSet(setState);
              // A new ChatView on every host build, like a host setState.
              return ChatView(
                chatController: controller,
                chatViewState: ChatViewState.hasMessages,
                featureActiveConfig:
                    const FeatureActiveConfig(enableTextField: false),
              );
            },
          ),
        ),
      );

  testWidgets('popup state and text field height survive a host rebuild',
      (tester) async {
    final controller = newController();
    late StateSetter rebuildHost;

    await tester.pumpWidget(host(controller, (s) => rebuildHost = s));
    await tester.pumpAndSettle();

    ChatViewInheritedWidget inherited() => tester.widget(
          find.byType(ChatViewInheritedWidget),
        );

    final before = inherited();
    before.showPopUp.value = true;
    before.chatTextFieldHeight.value = 56;

    rebuildHost(() {});
    await tester.pump();

    final after = inherited();
    expect(after.showPopUp, same(before.showPopUp),
        reason: 'the popup notifier is recreated on every host rebuild');
    expect(after.chatTextFieldHeight, same(before.chatTextFieldHeight));
    expect(after.reactionPopupKey, same(before.reactionPopupKey));
    expect(after.showPopUp.value, isTrue);
    expect(after.chatTextFieldHeight.value, 56);

    // scrollToLastMessage leaves a short timer behind.
    await tester.pump(const Duration(seconds: 1));
  });

  // Checks of the user-visible effect and of disposal, not assumptions.
  testWidgets('an open reaction popup stays open after a host rebuild',
      (tester) async {
    final controller = newController();
    late StateSetter rebuildHost;
    await tester.pumpWidget(host(controller, (s) => rebuildHost = s));
    await tester.pumpAndSettle();

    bool popupOpen() =>
        tester.widget<ReactionPopup>(find.byType(ReactionPopup)).showPopUp;

    expect(popupOpen(), isFalse);
    await tester.longPress(find.text('hello'));
    await tester.pumpAndSettle();
    expect(popupOpen(), isTrue, reason: 'long press should open the popup');

    rebuildHost(() {});
    await tester.pumpAndSettle();
    expect(popupOpen(), isTrue, reason: 'host rebuild closed the popup');
  });

  testWidgets('both notifiers are disposed when ChatView is removed',
      (tester) async {
    final controller = newController();
    await tester.pumpWidget(host(controller, (_) {}));
    await tester.pumpAndSettle();
    final inherited = tester.widget<ChatViewInheritedWidget>(
      find.byType(ChatViewInheritedWidget),
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));

    // A disposed ChangeNotifier asserts when a listener is added.
    expect(() => inherited.showPopUp.addListener(() {}), throwsFlutterError,
        reason: 'showPopUp not disposed');
    expect(
      () => inherited.chatTextFieldHeight.addListener(() {}),
      throwsFlutterError,
      reason: 'chatTextFieldHeight not disposed',
    );
  });

  // reactionPopupKey: ReactionPopupState keeps the long-pressed message and
  // the popup position, so a new key (new State) loses both. The flag is set
  // again by hand after the rebuild to isolate the key from showPopUp.
  testWidgets('reaction popup keeps its message and position after a rebuild',
      (tester) async {
    final controller = newController();
    late StateSetter rebuildHost;
    await tester.pumpWidget(host(controller, (s) => rebuildHost = s));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('hello'));
    await tester.pumpAndSettle();
    final popupBefore = tester.getTopLeft(find.text(heart));

    rebuildHost(() {});
    await tester.pumpAndSettle();
    // On the fixed code this is a no-op, the popup is still open.
    tester
        .widget<ChatViewInheritedWidget>(find.byType(ChatViewInheritedWidget))
        .showPopUp
        .value = true;
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text(heart)), popupBefore,
        reason: 'popup position was reset');
    await tester.tap(find.text(heart));
    await tester.pumpAndSettle();
    expect(controller.initialMessageList.first.reaction.reactions, [heart],
        reason: 'the long-pressed message was forgotten, tap did nothing');
  });

  // chatTextFieldHeight: the list reserves this much bottom padding above the
  // text field.
  testWidgets('list bottom padding does not reset on a host rebuild',
      (tester) async {
    final controller = newController();
    late StateSetter rebuildHost;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuildHost = setState;
              return ChatView(
                chatController: controller,
                chatViewState: ChatViewState.hasMessages,
                featureActiveConfig: const FeatureActiveConfig(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'one\ntwo\nthree\nfour');
    await tester.pumpAndSettle();

    double bottomPadding() => (tester
            .widget<ListView>(find.descendant(
              of: find.byType(ChatGroupedListWidget),
              matching: find.byType(ListView),
            ))
            .padding! as EdgeInsets)
        .bottom;

    double fieldHeight() => tester
        .widget<ChatViewInheritedWidget>(find.byType(ChatViewInheritedWidget))
        .chatTextFieldViewKey
        .currentContext!
        .size!
        .height;
    final before = bottomPadding();
    rebuildHost(() {});
    await tester.pump();
    expect(bottomPadding(), before,
        reason: 'bottom padding dropped to 0 for a frame after the rebuild');
    await tester.pumpAndSettle();
    expect(bottomPadding(), fieldHeight());
  });
}
