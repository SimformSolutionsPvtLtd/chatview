/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/chat_view_list_item.dart';
import '../../models/config_models/chat_view_list/list_tile_config.dart';
import '../../utils/helper.dart';
import 'last_message_view.dart';
import 'unread_count_view.dart';
import 'user_avatar_view.dart';

class ChatViewListItemTile extends StatelessWidget {
  const ChatViewListItemTile({
    required this.chat,
    required this.tileConfig,
    this.profile,
    this.userName,
    this.lastMessageTime,
    this.trailing,
    super.key,
  });

  /// User object to display in the chat list.
  final ChatViewListItem chat;

  /// Provides widget for profile in chat list.
  final Widget? profile;

  /// Provides widget for user name in chat list.
  final Widget? userName;

  /// Provides configuration for the user widget in chat list.
  final ListTileConfig tileConfig;

  /// Provides widget for last message time in chat list.
  final Widget? lastMessageTime;

  /// Provides widget for trailing elements in chat list.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final typingStatusConfig = tileConfig.typingStatusConfig;
    final unreadCountConfig = tileConfig.unreadCountConfig;
    final lastMessageTimeConfig = tileConfig.timeConfig;
    final unreadCount = chat.unreadCount ?? 0;
    final isAnyUserTyping = chat.typingUsers.isNotEmpty;
    final showUnreadCount =
        unreadCountConfig.countWidgetBuilder != null || unreadCount > 0;
    final lastMessage = chat.lastMessage;
    final typingStatusText = typingStatusConfig.textBuilder?.call(chat) ??
        TypingStatusConfigExtension(typingStatusConfig)
            .toTypingStatus(chat.typingUsers.toList());
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => tileConfig.onLongPress?.call(chat),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        tileConfig.onTap?.call(chat);
      },
      child: Padding(
        padding: tileConfig.padding,
        child: Row(
          children: [
            profile ??
                UserAvatarView(
                  imageUrl: chat.imageUrl ?? '',
                  onTap: () =>
                      tileConfig.userAvatarConfig.onProfileTap?.call(chat),
                  config: tileConfig.userAvatarConfig,
                  showOnlineStatus: tileConfig.showOnlineStatus &&
                      chat.userActiveStatus.isOnline,
                  userActiveStatusConfig: tileConfig.userActiveStatusConfig,
                ),
            Expanded(
              child: Padding(
                padding: tileConfig.middleWidgetPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userName ??
                        Text(
                          chat.name,
                          maxLines: tileConfig.userNameMaxLines,
                          overflow: tileConfig.userNameTextOverflow,
                          style: tileConfig.userNameTextStyle ??
                              const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                    if (isAnyUserTyping || lastMessage != null)
                      AnimatedSwitcher(
                        switchOutCurve: Curves.easeOut,
                        switchInCurve: Curves.easeIn,
                        duration: const Duration(milliseconds: 200),
                        reverseDuration: const Duration(milliseconds: 150),
                        child: isAnyUserTyping
                            ? typingStatusConfig.widgetBuilder?.call(chat) ??
                                Text(
                                  key: ValueKey(typingStatusText),
                                  typingStatusText,
                                  maxLines: typingStatusConfig.maxLines,
                                  overflow: typingStatusConfig.overflow,
                                  style: typingStatusConfig.textStyle,
                                )
                            : LastMessageView(
                                key: lastMessage?.id.isEmpty ?? true
                                    ? null
                                    : ValueKey(lastMessage?.id),
                                unreadCount: unreadCount,
                                lastMessage: lastMessage,
                                lastMessageType: lastMessage?.messageType,
                                lastMessageMaxLines:
                                    tileConfig.lastMessageMaxLines,
                                lastMessageTextOverflow:
                                    tileConfig.lastMessageTextOverflow,
                                lastMessageTextStyle:
                                    tileConfig.lastMessageTextStyle,
                                lastMessageBuilder: tileConfig
                                    .lastMessageTileBuilder
                                    ?.call(lastMessage),
                              ),
                      ),
                  ],
                ),
              ),
            ),
            trailing ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastMessageTime case final widget?)
                      widget
                    else if (chat.lastMessage?.createdAt case final createAt?)
                      Text(
                        formatLastMessageTime(
                          createAt.toString(),
                          lastMessageTimeConfig.dateFormatPattern,
                        ),
                        maxLines: lastMessageTimeConfig.maxLines,
                        overflow: lastMessageTimeConfig.overflow,
                        style: lastMessageTimeConfig.textStyle ??
                            const TextStyle(fontSize: 12),
                      ),
                    SizedBox(
                      height:
                          lastMessageTimeConfig.spaceBetweenTimeAndUnreadCount,
                    ),
                    if (showUnreadCount)
                      unreadCountConfig.countWidgetBuilder?.call(unreadCount) ??
                          UnreadCountView(
                            unreadCount: unreadCount,
                            config: unreadCountConfig,
                          ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
