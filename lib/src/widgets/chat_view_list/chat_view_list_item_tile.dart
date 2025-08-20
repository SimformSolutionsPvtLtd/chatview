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
import 'icon_scale_animation.dart';
import 'last_message_view.dart';
import 'unread_count_view.dart';
import 'user_avatar_view.dart';

class ChatViewListItemTile extends StatelessWidget {
  const ChatViewListItemTile({
    required this.chat,
    required this.config,
    super.key,
  });

  /// User object to display in the chat list.
  final ChatViewListItem chat;

  /// Provides configuration for the user widget in chat list.
  final ListTileConfig config;

  @override
  Widget build(BuildContext context) {
    final pinIconConfig = config.pinIconConfig;
    final muteIconConfig = config.muteIconConfig;
    final typingStatusConfig = config.typingStatusConfig;
    final unreadCountConfig = config.unreadCountConfig;
    final lastMessageTimeConfig = config.timeConfig;
    final unreadCount = chat.unreadCount ?? 0;
    final isAnyUserTyping = chat.typingUsers.isNotEmpty;
    final showUnreadCount =
        unreadCountConfig.countWidgetBuilder != null || unreadCount > 0;
    final lastMessage = chat.lastMessage;
    final typingStatusText = typingStatusConfig.textBuilder?.call(chat) ??
        TypingStatusConfigExtension(typingStatusConfig)
            .toTypingStatus(chat.typingUsers.toList());
    final isPinned = chat.settings.pinStatus.isPinned;
    final isMuted = chat.settings.muteStatus.isMuted;
    final hasTimeSubChild = isPinned || isMuted || showUnreadCount;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        config.onTap?.call(chat);
      },
      child: Padding(
        padding: config.padding,
        child: Row(
          children: [
            config.userAvatarConfig.avatarBuilder?.call(chat) ??
                UserAvatarView(
                  imageUrl: chat.imageUrl ?? '',
                  onTap: () => config.userAvatarConfig.onProfileTap?.call(chat),
                  config: config.userAvatarConfig,
                  showOnlineStatus:
                      config.showOnlineStatus && chat.userActiveStatus.isOnline,
                  userActiveStatusConfig: config.userActiveStatusConfig,
                ),
            Expanded(
              child: Padding(
                padding: config.middleWidgetPadding,
                child: AnimatedSize(
                  alignment: Alignment.topCenter,
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      config.userNameBuilder?.call(chat) ??
                          AnimatedSwitcher(
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            duration: const Duration(milliseconds: 200),
                            reverseDuration: const Duration(milliseconds: 150),
                            child: Align(
                              key: ValueKey(chat.name),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                chat.name,
                                maxLines: config.userNameMaxLines,
                                overflow: config.userNameTextOverflow,
                                style: config.userNameTextStyle ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                      if (isAnyUserTyping || lastMessage != null)
                        AnimatedSwitcher(
                          switchOutCurve: Curves.easeOut,
                          switchInCurve: Curves.easeIn,
                          duration: const Duration(milliseconds: 200),
                          reverseDuration: const Duration(milliseconds: 150),
                          child: isAnyUserTyping
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: typingStatusConfig.widgetBuilder
                                          ?.call(chat) ??
                                      Text(
                                        key: ValueKey(typingStatusText),
                                        typingStatusText,
                                        maxLines: typingStatusConfig.maxLines,
                                        overflow: typingStatusConfig.overflow,
                                        style: typingStatusConfig.textStyle,
                                      ),
                                )
                              : LastMessageView(
                                  key: lastMessage?.id.isEmpty ?? true
                                      ? null
                                      : ValueKey(lastMessage?.id),
                                  unreadCount: unreadCount,
                                  lastMessage: lastMessage,
                                  lastMessageType: lastMessage?.messageType,
                                  lastMessageMaxLines:
                                      config.lastMessageMaxLines,
                                  lastMessageTextOverflow:
                                      config.lastMessageTextOverflow,
                                  lastMessageTextStyle:
                                      config.lastMessageTextStyle,
                                  lastMessageBuilder: config
                                      .lastMessageTileBuilder
                                      ?.call(lastMessage),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            config.trailingBuilder?.call(chat) ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chat.lastMessage?.createdAt case final createAt?) ...[
                      lastMessageTimeConfig.timeBuilder?.call(createAt) ??
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
                      if (hasTimeSubChild)
                        SizedBox(
                          height: lastMessageTimeConfig
                              .spaceBetweenTimeAndUnreadCount,
                        ),
                    ],
                    Row(
                      children: [
                        IconScaleAnimation(
                          enable: isPinned,
                          tag: 'pin',
                          child: pinIconConfig.widget ??
                              Icon(
                                Icons.push_pin,
                                size: pinIconConfig.size,
                                color: pinIconConfig.color,
                              ),
                        ),
                        if (isPinned && isMuted) const SizedBox(width: 10),
                        IconScaleAnimation(
                          enable: isMuted,
                          tag: 'mute',
                          child: muteIconConfig.widget ??
                              Icon(
                                Icons.notifications_off,
                                size: muteIconConfig.size,
                                color: muteIconConfig.color,
                              ),
                        ),
                        if ((isPinned || isMuted) && showUnreadCount)
                          const SizedBox(width: 10),
                        if (showUnreadCount)
                          unreadCountConfig.countWidgetBuilder
                                  ?.call(unreadCount) ??
                              UnreadCountView(
                                unreadCount: unreadCount,
                                config: unreadCountConfig,
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
}
