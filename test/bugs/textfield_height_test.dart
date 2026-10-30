import 'package:chatview/chatview.dart';
import 'package:chatview/src/inherited_widgets/chat_view_inherited_widget.dart';
import 'package:chatview/src/widgets/message_list/chat_groupedlist_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The message list reserves bottom padding equal to the text field's height.
/// It must follow the field as it grows and shrinks while typing.
void main() {
  Future<void> mount(
    WidgetTester tester, {
    ReplyMessageWithReturnWidget? sendMessageBuilder,
  }) async {
    final controller = ChatController(
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
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            chatController: controller,
            chatViewState: ChatViewState.hasMessages,
            featureActiveConfig: const FeatureActiveConfig(),
            sendMessageBuilder: sendMessageBuilder,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double bottomPadding(WidgetTester tester) => (tester
          .widget<ListView>(find.descendant(
            of: find.byType(ChatGroupedListWidget),
            matching: find.byType(ListView),
          ))
          .padding! as EdgeInsets)
      .bottom;

  double fieldHeight(WidgetTester tester) => tester
      .widget<ChatViewInheritedWidget>(find.byType(ChatViewInheritedWidget))
      .chatTextFieldViewKey
      .currentContext!
      .size!
      .height;

  testWidgets('padding follows the default text field while typing',
      (tester) async {
    await mount(tester);
    final single = bottomPadding(tester);
    expect(single, fieldHeight(tester));

    await tester.enterText(find.byType(TextField), 'one\ntwo\nthree\nfour');
    await tester.pumpAndSettle();
    expect(fieldHeight(tester), greaterThan(single), reason: 'field grew');
    expect(bottomPadding(tester), fieldHeight(tester),
        reason: 'padding did not follow the grown field');

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(bottomPadding(tester), single, reason: 'padding did not shrink');
  });

  testWidgets('padding follows a custom text field while typing',
      (tester) async {
    await mount(
      tester,
      sendMessageBuilder: (_) => const Material(
        child: TextField(maxLines: null),
      ),
    );
    final single = bottomPadding(tester);
    expect(single, fieldHeight(tester));

    await tester.enterText(find.byType(TextField), 'one\ntwo\nthree\nfour');
    await tester.pumpAndSettle();
    expect(fieldHeight(tester), greaterThan(single), reason: 'field grew');
    expect(bottomPadding(tester), fieldHeight(tester),
        reason: 'padding did not follow the grown custom field');
  });

  testWidgets('padding follows the field when a reply preview appears',
      (tester) async {
    await mount(tester);
    final single = bottomPadding(tester);

    await tester.longPress(find.text('hello'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(fieldHeight(tester), greaterThan(single), reason: 'preview shown');
    expect(bottomPadding(tester), fieldHeight(tester),
        reason: 'padding did not follow the reply preview');
  });
}
