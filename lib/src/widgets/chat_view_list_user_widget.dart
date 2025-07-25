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

import '../models/chat_view_list_tile.dart';
import '../models/config_models/chat_list/chat_list_type_indicator_config.dart';
import '../models/config_models/chat_list/mute_icon_config.dart';
import '../models/config_models/chat_list/pin_icon_config.dart';
import '../models/config_models/chat_view_list_config.dart';
import '../models/config_models/chat_view_list_time_config.dart';
import '../models/config_models/chat_view_list_user_config.dart';
import '../models/config_models/unread_widget_config.dart';
import '../utils/constants/constants.dart';
import '../utils/helper.dart';
import '../utils/package_strings.dart';
import 'chat_list/chat_list_last_message_tile.dart';
import 'chat_list/unread_count_tile.dart';
import 'chat_user_avatar.dart';

class ChatViewListUserWidget extends StatelessWidget {
  const ChatViewListUserWidget({
    required this.chat,
    required this.typeIndicatorConfig,
    required this.config,
    required this.muteIconConfig,
    required this.pinIconConfig,
    this.profileWidget,
    this.userNameWidget,
    this.chatViewListTileConfig,
    this.lastMessageTimeWidget,
    this.trailingWidget,
    this.unReadCountWidget,
    this.unreadWidgetConfig,
    this.timeConfig,
    super.key,
  });

  /// Provides configuration for chat list UI.
  final ChatViewListConfig config;

  /// Chat object to display in the chat list.
  final ChatViewListModel chat;

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

  /// Configuration for the typing indicator in the chat list.
  final ChatListTypeIndicatorConfig typeIndicatorConfig;

  /// Configuration for the mute icon in the chat list.
  final MuteIconConfig muteIconConfig;

  /// Configuration for the pin icon in the chat list.
  final PinIconConfig pinIconConfig;

  @override
  Widget build(BuildContext context) {
    final unreadCount = chat.unreadCount ?? 0;
    final isAnyUserTyping = chat.typingUsers.isNotEmpty;
    final showTypingIndicator = isAnyUserTyping ||
        (isAnyUserTyping &&
            typeIndicatorConfig.widgetBuilder?.call(chat) != null) ||
        (isAnyUserTyping &&
            typeIndicatorConfig.textBuilder?.call(chat) != null);
    final showUnreadCount = unReadCountWidget != null || unreadCount > 0;
    final lastMessage = chat.lastMessage;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        chatViewListTileConfig?.onLongPress?.call(chat);
      },
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        chatViewListTileConfig?.onTap?.call(chat);
      },
      child: Padding(
        padding: config.padding ??
            const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            profileWidget ??
                GestureDetector(
                  onTap: () => chatViewListTileConfig?.onProfileTap?.call(chat),
                  child: ChatUserAvatar(
                    chat: chat,
                    chatViewListTileConfig: chatViewListTileConfig,
                  ),
                ),
            Expanded(
              child: Padding(
                padding:
                    chatViewListTileConfig?.userNameAndLastMessagePadding ??
                        const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userNameWidget ??
                        Text(
                          chat.name,
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
                    if (showTypingIndicator || lastMessage != null)
                      AnimatedSwitcher(
                        switchOutCurve: Curves.easeOut,
                        switchInCurve: Curves.easeIn,
                        duration: const Duration(milliseconds: 200),
                        reverseDuration: const Duration(milliseconds: 150),
                        child: showTypingIndicator
                            ? typeIndicatorConfig.widgetBuilder?.call(chat) ??
                                Text(
                                  typeIndicatorConfig.textBuilder?.call(chat) ??
                                      _getTypingStatus(
                                        prefix:
                                            typeIndicatorConfig.prefix ?? '',
                                        suffix:
                                            typeIndicatorConfig.suffix ?? '',
                                        value:
                                            PackageStrings.currentLocale.typing,
                                      ),
                                  maxLines: typeIndicatorConfig.maxLines,
                                  overflow: typeIndicatorConfig.overflow,
                                  style: typeIndicatorConfig.textStyle,
                                )
                            : ChatListLastMessageTile(
                                unreadCount: unreadCount,
                                lastMessage: lastMessage,
                                config: chatViewListTileConfig,
                              ),
                      ),
                  ],
                ),
              ),
            ),
            trailingWidget ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastMessageTimeWidget != null)
                      lastMessageTimeWidget!
                    else if (lastMessage?.createdAt != null)
                      Text(
                        formatLastMessageTime(
                          lastMessage?.createdAt.toString() ?? '',
                          timeConfig?.dateFormatPattern ?? defaultDateFormat,
                        ),
                        style:
                            chatViewListTileConfig?.lastMessageTimeTextStyle ??
                                const TextStyle(fontSize: 12),
                      ),
                    SizedBox(
                      height: timeConfig?.spaceBetweenTimeAndUnreadCount ?? 5,
                    ),
                    Row(
                      children: [
                        if (chat.settings.pinStatus.isPinned) ...[
                          pinIconConfig.widget ??
                              Icon(
                                Icons.push_pin,
                                size: pinIconConfig.iconSize,
                                color: pinIconConfig.iconColor,
                              ),
                          if (chat.settings.muteStatus.isMuted)
                            const SizedBox(width: 10),
                        ],
                        if (chat.settings.muteStatus.isMuted) ...[
                          muteIconConfig.widget ??
                              Icon(
                                Icons.notifications_off,
                                size: muteIconConfig.iconSize,
                                color: muteIconConfig.iconColor,
                              ),
                          if (showUnreadCount) const SizedBox(width: 10),
                        ],
                        if (showUnreadCount)
                          unReadCountWidget ??
                              UnreadCountTile(
                                chat: chat,
                                config: unreadWidgetConfig,
                              ),
                      ],
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  String _getTypingStatus({
    required String value,
    required String prefix,
    required String suffix,
  }) {
    final text = '$prefix$value$suffix';
    if (chat.typingUsers.isEmpty) return text;
    final list = chat.typingUsers.toList();
    final count = list.length;

    final firstName = list[0];

    if (count == 1) {
      return '$firstName is $text';
    } else if (count == 2) {
      return '$firstName & 1 other $text';
    } else {
      return '$firstName & ${count - 1} others $text';
    }
  }
}
