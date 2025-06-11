import 'package:chatview/src/utils/constants/constants.dart';
import 'package:chatview/src/widgets/chat_user_avatar.dart';
import 'package:flutter/material.dart';

import '../../chatview.dart';

class ChatViewListUserWidget extends StatelessWidget {
  const ChatViewListUserWidget({
    super.key,
    this.config,
    required this.user,
    this.profileWidget,
    this.profileWidgetConfig,
    this.userNameWidget,
    this.chatViewListUserConfig,
    this.lastMessageWidget,
    this.lastMessageTimeWidget,
    this.trailingWidget,
    this.unReadCountWidget,
    this.unReadWidgetConfig,
    this.timeConfig,
  });

  /// Provides configuration for chat list UI.
  final ChatViewListConfig? config;

  /// User object to display in the chat list.
  final ChatViewListUser user;

  /// Provides widget for profile in chat list.
  final Widget? profileWidget;

  /// Provides configuration for the profile widget in chat list.
  final ProfileWidgetConfig? profileWidgetConfig;

  /// Provides widget for user name in chat list.
  final Widget? userNameWidget;

  /// Provides configuration for the user widget in chat list.
  final ChatViewListUserConfig? chatViewListUserConfig;

  /// Configuration for the time display in the chat list.
  final ChatViewListTimeConfig? timeConfig;

  /// Provides widget for last message in chat list.
  final Widget? lastMessageWidget;

  /// Provides widget for last message time in chat list.
  final Widget? lastMessageTimeWidget;

  /// Provides widget for trailing elements in chat list.
  final Widget? trailingWidget;

  /// Provides widget for unread count in chat list.
  final Widget? unReadCountWidget;

  /// Configuration for the unread message widget in the chat list.
  final UnReadWidgetConfig? unReadWidgetConfig;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        chatViewListUserConfig?.onLongPress?.call(user);
      },
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        chatViewListUserConfig?.onTap?.call(user);
      },
      child: Padding(
        padding: config?.chatViewListPadding ??
            const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 8,
            ),
        child: Row(
          children: [
            profileWidget ??
                GestureDetector(
                  onTap: () => profileWidgetConfig?.onTap?.call(user),
                  child: ChatUserAvatar(
                    user: user,
                    profileWidgetConfig: profileWidgetConfig,
                  ),
                ),
            Expanded(
              child: Padding(
                padding:
                    chatViewListUserConfig?.userNameAndLastMessagePadding ??
                        const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userNameWidget ??
                        Text(
                          user.name,
                          maxLines:
                              chatViewListUserConfig?.userNameMaxLines ?? 1,
                          overflow:
                              chatViewListUserConfig?.userNameTextOverflow ??
                                  TextOverflow.ellipsis,
                          style: chatViewListUserConfig?.userNameTextStyle ??
                              const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                    if (lastMessageWidget != null)
                      lastMessageWidget!
                    else if (user.lastMessageText?.isNotEmpty ?? false)
                      Text(
                        user.lastMessageText ?? '',
                        maxLines: chatViewListUserConfig?.userNameMaxLines ?? 1,
                        overflow:
                            chatViewListUserConfig?.lastMessageTextOverflow ??
                                TextOverflow.ellipsis,
                        style: chatViewListUserConfig?.lastMessageTextStyle ??
                            TextStyle(
                              fontSize: 14,
                              fontWeight: user.unreadCount != null &&
                                      user.unreadCount! > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                      ),
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
                    else if (user.lastMessageTime?.isNotEmpty ?? false)
                      Text(
                        timeConfig?.formatLastMessageTime(
                              user.lastMessageTime ?? '',
                            ) ??
                            '',
                        style:
                            chatViewListUserConfig?.lastMessageTimeTextStyle ??
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
                          if (unReadWidgetConfig?.unReadCountView.isDot ??
                              false) {
                            double dotSize = unReadWidgetConfig?.width ?? 12;
                            return Container(
                              width: dotSize,
                              height: dotSize,
                              decoration: unReadWidgetConfig?.decoration ??
                                  const BoxDecoration(
                                    color: Color(primaryColorHex),
                                    shape: BoxShape.circle,
                                  ),
                            );
                          } else if (unReadWidgetConfig
                                  ?.unReadCountView.isNone ??
                              false) {
                            return const SizedBox.shrink();
                          } else {
                            String displayCount = ((unReadWidgetConfig
                                            ?.unReadCountView
                                            .isNinetyNinePlus ??
                                        false) &&
                                    user.unreadCount! > 99)
                                ? '99+'
                                : '${user.unreadCount}';
                            bool isSingleDigit = user.unreadCount! < 10;
                            double minWidth = unReadWidgetConfig?.width ?? 20;
                            double padding = isSingleDigit ? 0 : 4;
                            return Container(
                              constraints: BoxConstraints(
                                minWidth: minWidth,
                                minHeight: unReadWidgetConfig?.height ?? 20,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: padding,
                              ),
                              decoration: unReadWidgetConfig?.decoration ??
                                  BoxDecoration(
                                    color: const Color(primaryColorHex),
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
                                style: chatViewListUserConfig
                                        ?.unreadCountTextStyle ??
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
