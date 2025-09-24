import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../chatview.dart' show ChatView;
import '../../values/typedefs.dart';
import '../emoji_picker_widget.dart';
import 'text_field_action_button.dart';

/// Emoji picker action button implementation.
class EmojiPickerActionButton extends TextFieldActionButton {
  EmojiPickerActionButton({
    required super.icon,
    required EmojiPickerActionCallback? onPressed,
    required BuildContext context,
    this.emojiPickerSheetConfig,
    this.height,
    super.key,
    super.color,
    super.style,
  }) : super(
          onPressed: onPressed == null
              ? null
              : (_) async {
                  final emoji = await _pickEmoji(
                    context: context,
                    config: emojiPickerSheetConfig,
                    height: height,
                  );
                  if (emoji != null) {
                    final replyMessage = context.mounted
                        ? ChatView.getReplyMessage(context)
                        : null;
                    onPressed.call(emoji, replyMessage);
                  }
                },
        );

  final Config? emojiPickerSheetConfig;
  final double? height;

  /// Shows the emoji picker as a modal bottom sheet and
  /// returns the selected emoji.
  static Future<String?> _pickEmoji({
    BuildContext? context,
    Config? config,
    double? height,
  }) async {
    if (context == null) return null;
    return showModalBottomSheet<String?>(
      context: context,
      builder: (newContext) => EmojiPickerWidget(
        height: height,
        emojiPickerSheetConfig: config,
        onSelected: (emoji) => Navigator.pop<String>(context, emoji),
      ),
    );
  }

  @override
  State<EmojiPickerActionButton> createState() =>
      _EmojiPickerActionButtonState();
}

// As no need to custom build method,
// we are using the same state class as parent.
class _EmojiPickerActionButtonState
    extends TextFieldActionButtonState<EmojiPickerActionButton> {}
