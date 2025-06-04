import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../emoji_picker_widget.dart';
import 'text_field_action_button.dart';

/// Emoji picker action button implementation.
class EmojiPickerActionButton extends TextFieldActionButton {
  EmojiPickerActionButton({
    super.key,
    required super.icon,
    super.color,
    required ValueSetter<String?>? onPressed,
    this.emojiPickerSheetConfig,
    required BuildContext context,
    this.height,
  }) : super(
          onPressed: onPressed == null
              ? null
              : () async {
                  final emoji = await _pickEmoji(
                    context: context,
                    config: emojiPickerSheetConfig,
                    height: height,
                  );
                  if (emoji != null) {
                    onPressed.call(emoji);
                  }
                },
        );

  final Config? emojiPickerSheetConfig;
  final double? height;

  /// Shows the emoji picker as a modal bottom sheet and returns the selected emoji.
  static Future<String?> _pickEmoji({
    BuildContext? context,
    Config? config,
    double? height,
  }) async {
    if (context == null) return null;
    String? selectedEmoji;
    await showModalBottomSheet<void>(
      context: context,
      builder: (newContext) => EmojiPickerWidget(
        height: height,
        emojiPickerSheetConfig: config,
        onSelected: (emoji) {
          selectedEmoji = emoji;
          Navigator.of(context).pop();
        },
      ),
    );
    return selectedEmoji;
  }

  @override
  State<EmojiPickerActionButton> createState() =>
      _EmojiPickerActionButtonState();
}

class _EmojiPickerActionButtonState
    extends TextFieldActionButtonState<EmojiPickerActionButton> {}
