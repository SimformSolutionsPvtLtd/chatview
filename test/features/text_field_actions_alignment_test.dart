import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/message_input/chatui_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// `leadingActionsAlignment` / `trailingActionsAlignment` choose where the
/// action buttons sit when the text field grows to several lines.
void main() {
  // Half the height of a 48px action button.
  const half = kMinInteractiveDimension / 2;

  Future<void> mount(
    WidgetTester tester, {
    TextFieldActionsAlignment? leading,
    TextFieldActionsAlignment? trailing,
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
            sendMessageConfig: SendMessageConfiguration(
              textFieldConfig: TextFieldConfiguration(
                hideLeadingActionsOnType: false,
                // A real button, 48px like the send button, so it fills the
                // single-line field and is pinned, not centered, when it grows.
                leadingActions: (context, controller) => [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                ],
                leadingActionsAlignment:
                    leading ?? TextFieldActionsAlignment.center,
                trailingActionsAlignment:
                    trailing ?? TextFieldActionsAlignment.center,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Rect field(WidgetTester tester) =>
      tester.getRect(find.byType(ChatUITextField));
  double search(WidgetTester tester) =>
      tester.getCenter(find.byIcon(Icons.search)).dy;
  // Text is typed, so the trailing action is the send button.
  double send(WidgetTester tester) => tester
      .getCenter(find
          .descendant(
            of: find.byType(ChatUITextField),
            matching: find.byType(IconButton),
          )
          .last)
      .dy;

  Future<void> growField(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), 'one\ntwo\nthree\nfour');
    await tester.pumpAndSettle();
  }

  testWidgets('center is the default and keeps both groups centered',
      (tester) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField), 'one');
    await tester.pumpAndSettle();
    expect(search(tester), field(tester).center.dy);
    expect(send(tester), field(tester).center.dy);

    await growField(tester);
    expect(search(tester), field(tester).center.dy);
    expect(send(tester), field(tester).center.dy);
  });

  testWidgets('bottom pins leading actions to the bottom once the field grows',
      (tester) async {
    await mount(tester, leading: TextFieldActionsAlignment.bottom);
    await tester.enterText(find.byType(TextField), 'one');
    await tester.pumpAndSettle();
    expect(search(tester), field(tester).center.dy,
        reason: 'a single-line field keeps the button centered');

    await growField(tester);
    expect(search(tester), field(tester).bottom - half);
    expect(send(tester), field(tester).center.dy,
        reason: 'trailing actions were not changed');
  });

  testWidgets('top pins leading actions to the top once the field grows',
      (tester) async {
    await mount(tester, leading: TextFieldActionsAlignment.top);
    await growField(tester);
    expect(search(tester), field(tester).top + half);
  });

  testWidgets('bottom pins trailing actions to the bottom once the field grows',
      (tester) async {
    await mount(tester, trailing: TextFieldActionsAlignment.bottom);
    await growField(tester);
    expect(send(tester), field(tester).bottom - half);
    expect(search(tester), field(tester).center.dy,
        reason: 'leading actions were not changed');
  });

  testWidgets('top pins trailing actions to the top once the field grows',
      (tester) async {
    await mount(tester, trailing: TextFieldActionsAlignment.top);
    await growField(tester);
    expect(send(tester), field(tester).top + half);
  });
}
