import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../utils/constants/constants.dart';

/// A widget builder that contains the logic to calculate the height of the chat text field
/// When reply message view is shown update the height of the chat text field
/// When selected image view is shown update the height of the chat text field
class ChatTextFieldViewBuilder<T> extends StatelessWidget {
  /// A widget that rebuilds when the value of a [ValueNotifier] changes.
  const ChatTextFieldViewBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
  });

  /// The [ValueListenable] that provides the value to be listened to.
  final ValueListenable<T> valueListenable;

  /// The builder function that takes the current context, value, and an optional child widget.
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final chatViewIW = context.chatViewIW;
          // Update the chat text field height based on the current context size.
          chatViewIW?.chatTextFieldHeight.value =
              chatViewIW.chatTextFieldViewKey.currentContext?.size?.height ??
                  defaultChatTextFieldHeight;
        });
        return builder.call(context, value, child);
      },
    );
  }
}
