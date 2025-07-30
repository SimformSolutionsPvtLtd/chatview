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
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../models/chat_view_list_item.dart';
import '../../models/config_models/chat_view_list/chat_view_list_tile_config.dart';
import '../../utils/helper.dart';
import '../../utils/package_strings.dart';
import 'user_avatar_view.dart';

class ChatViewListItemTile extends StatelessWidget {
  const ChatViewListItemTile({
    required this.chat,
    required this.tileConfig,
    this.profile,
    this.userName,
    this.lastMessageTime,
    this.trailing,
    this.unreadCount,
    super.key,
  });

  /// User object to display in the chat list.
  final ChatViewListItem chat;

  /// Provides widget for profile in chat list.
  final Widget? profile;

  /// Provides widget for user name in chat list.
  final Widget? userName;

  /// Provides configuration for the user widget in chat list.
  final ChatViewListTileConfig tileConfig;

  /// Provides widget for last message time in chat list.
  final Widget? lastMessageTime;

  /// Provides widget for trailing elements in chat list.
  final Widget? trailing;

  /// Provides widget for unread count in chat list.
  final Widget? unreadCount;

  @override
  Widget build(BuildContext context) {
    final unreadCountConfig = tileConfig.unreadCountConfig;
    final lastMessageTimeConfig = tileConfig.timeConfig;
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
                    if (chat.lastMessage?.message.isNotEmpty ?? false)
                      tileConfig.customLastMessageListViewBuilder
                              ?.call(chat.lastMessage) ??
                          switch (chat.lastMessage?.messageType) {
                            MessageType.image => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo,
                                    size: 14,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    PackageStrings.currentLocale.photo,
                                    style: TextStyle(
                                      fontWeight: chat.unreadCount != null &&
                                              chat.unreadCount! > 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            MessageType.text => Text(
                                chat.lastMessage?.message ?? '',
                                maxLines: tileConfig.lastMessageMaxLines,
                                overflow: tileConfig.lastMessageTextOverflow,
                                style: tileConfig.lastMessageTextStyle ??
                                    TextStyle(
                                      fontSize: 14,
                                      fontWeight: chat.unreadCount != null &&
                                              chat.unreadCount! > 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                            MessageType.voice => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.mic,
                                    size: 14,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    PackageStrings.currentLocale.voice,
                                  ),
                                ],
                              ),
                            // Provides the view for the custom message type in [customLastMessageListViewBuilder]
                            MessageType.custom ||
                            null =>
                              const SizedBox.shrink(),
                          }
                  ],
                ),
              ),
            ),
            trailing ??
                Column(
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
                    if (unreadCount case final widget?)
                      widget
                    else if (chat.unreadCount != null && chat.unreadCount! > 0)
                      Builder(
                        builder: (context) {
                          if (unreadCountConfig.style.isDot) {
                            final dotSize = unreadCountConfig.width ?? 12;
                            return Container(
                              width: dotSize,
                              height: dotSize,
                              decoration: unreadCountConfig.decoration ??
                                  BoxDecoration(
                                    color: unreadCountConfig.backgroundColor,
                                    shape: BoxShape.circle,
                                  ),
                            );
                          } else if (unreadCountConfig.style.isNone) {
                            return const SizedBox.shrink();
                          } else {
                            final displayCount =
                                ((unreadCountConfig.style.isNinetyNinePlus) &&
                                        chat.unreadCount! > 99)
                                    ? '99+'
                                    : '${chat.unreadCount}';
                            final isSingleDigit = chat.unreadCount! < 10;
                            final minWidth = unreadCountConfig.width ?? 20;
                            final padding = isSingleDigit ? 0.0 : 4.0;
                            return Container(
                              constraints: BoxConstraints(
                                minWidth: minWidth,
                                minHeight: unreadCountConfig.height ?? 20,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: padding,
                              ),
                              decoration: unreadCountConfig.decoration ??
                                  BoxDecoration(
                                    color: unreadCountConfig.backgroundColor,
                                    shape: isSingleDigit
                                        ? BoxShape.circle
                                        : BoxShape.rectangle,
                                    borderRadius: isSingleDigit
                                        ? null
                                        : BorderRadius.circular(minWidth),
                                  ),
                              alignment: Alignment.center,
                              child: Text(
                                displayCount,
                                style: unreadCountConfig.textStyle ??
                                    TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: unreadCountConfig.textColor,
                                      fontSize: unreadCountConfig.fontSize,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
