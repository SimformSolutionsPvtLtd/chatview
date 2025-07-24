import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../models/config_models/chat_view_list_user_config.dart';
import '../../utils/package_strings.dart';

class ChatListLastMessageTile extends StatelessWidget {
  const ChatListLastMessageTile({
    required this.unreadCount,
    required this.lastMessage,
    this.config,
    super.key,
  });

  final int unreadCount;
  final Message? lastMessage;
  final ChatViewListTileConfig? config;

  @override
  Widget build(BuildContext context) {
    return config?.customLastMessageListViewBuilder?.call(lastMessage) ??
        switch (lastMessage?.messageType) {
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
              maxLines: config?.userNameMaxLines ?? 1,
              overflow:
                  config?.lastMessageTextOverflow ?? TextOverflow.ellipsis,
              style: config?.lastMessageTextStyle ??
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
          // Provides the view for the custom message type in [customLastMessageListViewBuilder]
          MessageType.custom || null => const SizedBox.shrink(),
        };
  }
}
