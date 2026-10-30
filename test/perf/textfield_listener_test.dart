import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/message_input/chatui_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts [addListener] calls. Past [cap] it stops registering, so the buggy
/// (exponential) behaviour is measurable instead of hanging the test.
class _CountingController extends TextEditingController {
  static const cap = 1000;
  int adds = 0;

  @override
  void addListener(VoidCallback listener) {
    adds++;
    if (adds <= cap) super.addListener(listener);
  }
}

/// S3: typing must not register a new text controller listener per keystroke.
void main() {
  testWidgets('S3 typing does not add listeners to the text controller',
      (tester) async {
    final controller = _CountingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatUITextField(
            focusNode: FocusNode(),
            textEditingController: controller,
            onPressed: () {},
            onRecordingComplete: (_) {},
            onImageSelected: (_, __) {},
            sendMessageConfig: const SendMessageConfiguration(),
          ),
        ),
      ),
    );

    final addsAfterMount = controller.adds;
    const keystrokes = 30;
    for (var i = 1; i <= keystrokes; i++) {
      controller.text = 'a' * i;
      await tester.pump();
    }

    final addsWhileTyping = controller.adds - addsAfterMount;
    // ignore: avoid_print
    print('S3 addListener: mount=$addsAfterMount | during $keystrokes '
        'keystrokes: $addsWhileTyping');
    expect(addsWhileTyping, 0, reason: 'typing must not add listeners');
  });
}
