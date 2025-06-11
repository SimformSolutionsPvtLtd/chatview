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

import '../models/chat_view_list_tile.dart';
import '../models/config_models/chat_view_list_config.dart';
import '../models/config_models/chat_view_list_time_config.dart';
import '../models/config_models/chat_view_list_user_config.dart';
import '../models/config_models/unread_widget_config.dart';
import '../utils/constants/constants.dart';
import '../utils/helper.dart';
import '../utils/package_strings.dart';
import 'chat_user_avatar.dart';

class ChatViewListUserWidget extends StatelessWidget {
  const ChatViewListUserWidget({
    super.key,
    this.config,
    required this.user,
    this.profileWidget,
    this.userNameWidget,
    this.chatViewListTileConfig,
    this.lastMessageTimeWidget,
    this.trailingWidget,
    this.unReadCountWidget,
    this.unreadWidgetConfig,
    this.timeConfig,
  });

  /// Provides configuration for chat list UI.
  final ChatViewListConfig? config;

  /// User object to display in the chat list.
  final ChatViewListModel user;

  /// Provides widget for profile in chat list.
  final Widget? profileWidget;

  /// Provides widget for user name in chat list.
  final Widget? userNameWidget;

  /// Provides configuration for the user widget in chat list.
  final ChatViewListTileConfig? chatViewListTileConfig;

  /// Configuration for the time display in the chat list.
  final ChatViewListTimeConfig? timeConfig;

  /// Provides widget for last message time in chat list.
  final Widget? lastMessageTimeWidget;

  /// Provides widget for trailing elements in chat list.
  final Widget? trailingWidget;

  /// Provides widget for unread count in chat list.
  final Widget? unReadCountWidget;

  /// Configuration for the unread message widget in the chat list.
  final UnreadWidgetConfig? unreadWidgetConfig;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        chatViewListTileConfig?.onLongPress?.call(user);
      },
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        chatViewListTileConfig?.onTap?.call(user);
      },
      child: Padding(
        padding: config?.padding ??
            const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 8,
            ),
        child: Row(
          children: [
            profileWidget ??
                GestureDetector(
                  onTap: () => chatViewListTileConfig?.onProfileTap?.call(user),
                  child: ChatUserAvatar(
                    user: user,
                    chatViewListTileConfig: chatViewListTileConfig,
                  ),
                ),
            Expanded(
              child: Padding(
                padding:
                    chatViewListTileConfig?.userNameAndLastMessagePadding ??
                        const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userNameWidget ??
                        Text(
                          user.name,
                          maxLines:
                              chatViewListTileConfig?.userNameMaxLines ?? 1,
                          overflow:
                              chatViewListTileConfig?.userNameTextOverflow ??
                                  TextOverflow.ellipsis,
                          style: chatViewListTileConfig?.userNameTextStyle ??
                              const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                    if (user.lastMessage?.message.isNotEmpty ?? false)
                      chatViewListTileConfig?.customLastMessageListViewBuilder
                              ?.call(user.lastMessage) ??
                          switch (user.lastMessage?.messageType) {
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
                                      fontWeight: user.unreadCount != null &&
                                              user.unreadCount! > 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            MessageType.text => Text(
                                user.lastMessage?.message ?? '',
                                maxLines:
                                    chatViewListTileConfig?.userNameMaxLines ??
                                        1,
                                overflow: chatViewListTileConfig
                                        ?.lastMessageTextOverflow ??
                                    TextOverflow.ellipsis,
                                style: chatViewListTileConfig
                                        ?.lastMessageTextStyle ??
                                    TextStyle(
                                      fontSize: 14,
                                      fontWeight: user.unreadCount != null &&
                                              user.unreadCount! > 0
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
            trailingWidget ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastMessageTimeWidget != null)
                      lastMessageTimeWidget!
                    else if (user.lastMessage?.createdAt != null)
                      Text(
                        formatLastMessageTime(
                          user.lastMessage?.createdAt.toString() ?? '',
                          timeConfig?.dateFormatPattern ?? defaultDateFormat,
                        ),
                        style:
                            chatViewListTileConfig?.lastMessageTimeTextStyle ??
                                const TextStyle(fontSize: 12),
                      ),
                    SizedBox(
                      height: timeConfig?.spaceBetweenTimeAndUnreadCount ?? 5,
                    ),
                    if (unReadCountWidget != null)
                      unReadCountWidget!
                    else if (user.unreadCount != null && user.unreadCount! > 0)
                      Builder(
                        builder: (context) {
                          if (unreadWidgetConfig?.unreadCountView.isDot ??
                              false) {
                            double dotSize = unreadWidgetConfig?.width ?? 12;
                            return Container(
                              width: dotSize,
                              height: dotSize,
                              decoration: unreadWidgetConfig?.decoration ??
                                  const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                            );
                          } else if (unreadWidgetConfig
                                  ?.unreadCountView.isNone ??
                              false) {
                            return const SizedBox.shrink();
                          } else {
                            String displayCount = ((unreadWidgetConfig
                                            ?.unreadCountView
                                            .isNinetyNinePlus ??
                                        false) &&
                                    user.unreadCount! > 99)
                                ? '99+'
                                : '${user.unreadCount}';
                            bool isSingleDigit = user.unreadCount! < 10;
                            double minWidth = unreadWidgetConfig?.width ?? 20;
                            double padding = isSingleDigit ? 0 : 4;
                            return Container(
                              constraints: BoxConstraints(
                                minWidth: minWidth,
                                minHeight: unreadWidgetConfig?.height ?? 20,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: padding,
                              ),
                              decoration: unreadWidgetConfig?.decoration ??
                                  BoxDecoration(
                                    color: primaryColor,
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
                                style:
                                    unreadWidgetConfig?.unreadCountTextStyle ??
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
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
