import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Without a `textStyle`, typed text must be readable on the field's fill.
void main() {
  Future<TextField> mount(
    WidgetTester tester, {
    Color? fill,
    TextStyle? textStyle,
  }) async {
    final controller = ChatController(
      initialMessageList: [],
      scrollController: ScrollController(),
      currentUser: ChatUser(id: '1', name: 'me'),
      otherUsers: [ChatUser(id: '2', name: 'other')],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            chatController: controller,
            chatViewState: ChatViewState.noData,
            featureActiveConfig: const FeatureActiveConfig(),
            sendMessageConfig: SendMessageConfiguration(
              textFieldBackgroundColor: fill,
              textFieldConfig: TextFieldConfiguration(textStyle: textStyle),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tester.widget<TextField>(find.byType(TextField));
  }

  testWidgets('default fill gets dark text, not white on white',
      (tester) async {
    final field = await mount(tester);
    expect(field.style!.color, isNot(Colors.white));
    expect(
      ThemeData.estimateBrightnessForColor(field.style!.color!),
      Brightness.dark,
    );
  });

  testWidgets('a dark fill keeps white text', (tester) async {
    final field = await mount(tester, fill: const Color(0xff202020));
    expect(field.style!.color, Colors.white);
  });

  testWidgets('an explicit textStyle is used as given', (tester) async {
    final field = await mount(
      tester,
      textStyle: const TextStyle(color: Colors.red),
    );
    expect(field.style!.color, Colors.red);
  });
}
