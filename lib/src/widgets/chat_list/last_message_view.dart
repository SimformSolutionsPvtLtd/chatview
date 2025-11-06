import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../models/config_models/chat_list/last_message_status_config.dart';
import '../../utils/package_strings.dart';
import 'message_status_icon.dart';

class LastMessageView extends StatelessWidget {
  const LastMessageView({
    required this.unreadCount,
    required this.lastMessage,
    required this.showStatusIcon,
    required this.statusConfig,
    required this.iconColor,
    this.highlightTextStyle,
    this.lastMessageType,
    this.lastMessageBuilder,
    this.lastMessageMaxLines,
    this.lastMessageTextStyle,
    this.lastMessageTextOverflow,
    super.key,
  }) : assert(
          !(lastMessageBuilder == null &&
              lastMessageType == MessageType.custom),
          'Ensure that lastMessageBuilder is provided for MessageType.custom'
          ' to prevent the message preview from being empty.',
        );

  final int unreadCount;
  final Message lastMessage;

  final int? lastMessageMaxLines;
  final TextStyle? lastMessageTextStyle;
  final TextOverflow? lastMessageTextOverflow;

  /// Defined separately from config, as config properties
  /// can't be used in assert with const constructor.
  final MessageType? lastMessageType;
  final Widget? lastMessageBuilder;
  final bool showStatusIcon;
  final TextStyle? highlightTextStyle;
  final LastMessageStatusConfig statusConfig;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final highlightText = highlightTextStyle != null && unreadCount > 0;
    return lastMessageBuilder ??
        AnimatedSwitcher(
          switchOutCurve: Curves.easeOut,
          switchInCurve: Curves.easeIn,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 200),
          child: Align(
            key: ValueKey('${lastMessage.id}_${lastMessage.message}'),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (showStatusIcon) ...[
                  MessageStatusIcon(
                    config: statusConfig,
                    status: lastMessage.status,
                  ),
                  const SizedBox(width: 5),
                ],
                Expanded(
                  child: switch (lastMessageType) {
                    MessageType.image => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo, size: 14, color: iconColor),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              PackageStrings.currentLocale.photo,
                              maxLines: lastMessageMaxLines,
                              overflow: lastMessageTextOverflow,
                              style: lastMessageTextStyle?.merge(
                                highlightText ? highlightTextStyle : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    MessageType.text => Text(
                        lastMessage.message,
                        textAlign: TextAlign.left,
                        maxLines: lastMessageMaxLines,
                        overflow: lastMessageTextOverflow,
                        style: lastMessageTextStyle?.merge(
                          highlightText ? highlightTextStyle : null,
                        ),
                      ),
                    MessageType.voice => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, size: 14, color: iconColor),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              PackageStrings.currentLocale.voice,
                              maxLines: lastMessageMaxLines,
                              overflow: lastMessageTextOverflow,
                              style: lastMessageTextStyle?.merge(
                                highlightText ? highlightTextStyle : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    // Provides the view for the custom message type in
                    // `lastMessageTileBuilder`
                    MessageType.custom || null => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          ),
        );
  }
}
