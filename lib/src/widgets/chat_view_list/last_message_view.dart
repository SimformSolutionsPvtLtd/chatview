import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../utils/package_strings.dart';

class LastMessageView extends StatelessWidget {
  const LastMessageView({
    required this.unreadCount,
    required this.lastMessage,
    this.lastMessageType,
    this.lastMessageBuilder,
    super.key,
    this.lastMessageMaxLines,
    this.lastMessageTextStyle,
    this.lastMessageTextOverflow,
  }) : assert(
          !(lastMessageBuilder == null &&
              lastMessageType == MessageType.custom),
          'Ensure that lastMessageBuilder is provided for MessageType.custom'
          ' to prevent the message preview from being empty.',
        );

  final int unreadCount;
  final Message? lastMessage;

  final int? lastMessageMaxLines;
  final TextStyle? lastMessageTextStyle;
  final TextOverflow? lastMessageTextOverflow;

  /// Defined separately from config, as config properties
  /// can't be used in assert with const constructor.
  final MessageType? lastMessageType;
  final Widget? lastMessageBuilder;

  @override
  Widget build(BuildContext context) {
    return lastMessageBuilder ??
        switch (lastMessageType) {
          MessageType.image => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo, size: 14),
                const SizedBox(width: 5),
                Text(
                  PackageStrings.currentLocale.photo,
                  style: TextStyle(
                    fontWeight:
                        unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          MessageType.text => Text(
              lastMessage?.message ?? '',
              maxLines: lastMessageMaxLines,
              overflow: lastMessageTextOverflow,
              style: lastMessageTextStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight:
                        unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          MessageType.voice => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, size: 14),
                const SizedBox(width: 5),
                Text(PackageStrings.currentLocale.voice),
              ],
            ),
          // Provides the view for the custom message type in
          // `lastMessageTileBuilder`
          MessageType.custom || null => const SizedBox.shrink(),
        };
  }
}
