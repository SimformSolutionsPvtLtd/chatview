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

import '../../inherited_widgets/configurations_inherited_widgets.dart';
import '../../models/config_models/chat_view/feature_active_config.dart';
import '../../utils/constants/constants.dart';
import '../../values/typedefs.dart';
import '../common/profile_circle.dart';
import 'messages_widget_column.dart';

/// One chat row: padding/margin, the avatar (or a spacer that keeps
/// alignment) on either side, and the message column in the middle.
class ChatBubbleContent extends StatelessWidget {
  const ChatBubbleContent({
    required this.message,
    required this.messagedUser,
    required this.isMessageBySender,
    required this.isOutsideBubbleEmoji,
    required this.chatListConfig,
    required this.featureActiveConfig,
    required this.chatController,
    required this.currentUser,
    required this.onSwipe,
    required this.onLongPress,
    required this.onMaxDuration,
    required this.messageStatusIndicator,
    required this.profileCircle,
    this.onReplyTap,
    this.shouldHighlight = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    super.key,
  });

  final Message message;
  final ChatUser? messagedUser;
  final bool isMessageBySender;
  final bool isOutsideBubbleEmoji;
  final ConfigurationsInheritedWidget chatListConfig;
  final FeatureActiveConfig? featureActiveConfig;
  final ChatController? chatController;
  final ChatUser? currentUser;

  /// Swipe-to-reply callback, already resolved for the swipe direction.
  final VoidCallback onSwipe;
  final DoubleCallBack onLongPress;
  final ValueSetter<int> onMaxDuration;
  final Widget messageStatusIndicator;

  /// The sender's avatar, shown only for the last message of a group; other
  /// messages get a same-width spacer instead.
  final ProfileCircle profileCircle;

  final ValueSetter<String>? onReplyTap;
  final bool shouldHighlight;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  @override
  Widget build(BuildContext context) {
    final chatBubbleConfig = chatListConfig.chatBubbleConfig;
    final profileCircleConfig = chatListConfig.profileCircleConfig;

    final avatarRadius = profileCircleConfig?.circleRadius ?? 16;
    final padding = (profileCircleConfig?.padding ??
            const EdgeInsets.only(
              left: avatarDefaultPaddingLeft,
              right: avatarDefaultPaddingRight,
            ))
        .resolve(Directionality.of(context));
    final avatarSpacerWidth = avatarRadius * 2 + padding.left + padding.right;

    final avatar =
        isLastInGroup ? profileCircle : SizedBox(width: avatarSpacerWidth);

    return Container(
      padding: chatBubbleConfig?.padding ?? const EdgeInsets.only(left: 5),
      margin: chatBubbleConfig?.margin ??
          EdgeInsets.only(
            bottom: (featureActiveConfig?.enableMessageGrouping ?? true) &&
                    !isLastInGroup
                ? (featureActiveConfig?.messageGroupSpacing ??
                    messageGroupDefaultSpacing)
                : 10.0,
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMessageBySender &&
              (featureActiveConfig?.enableOtherUserProfileAvatar ?? true))
            avatar,
          Expanded(
            child: MessagesWidgetColumn(
              message: message,
              messagedUser: messagedUser,
              isMessageBySender: isMessageBySender,
              isOutsideBubbleEmoji: isOutsideBubbleEmoji,
              chatListConfig: chatListConfig,
              featureActiveConfig: featureActiveConfig,
              chatController: chatController,
              currentUser: currentUser,
              onSwipe: onSwipe,
              onLongPress: onLongPress,
              onMaxDuration: onMaxDuration,
              onReplyTap: onReplyTap,
              shouldHighlight: shouldHighlight,
              isFirstInGroup: isFirstInGroup,
              isLastInGroup: isLastInGroup,
              messageStatusIndicator: messageStatusIndicator,
            ),
          ),
          if (isMessageBySender &&
              (featureActiveConfig?.enableCurrentUserProfileAvatar ?? true))
            avatar,
        ],
      ),
    );
  }
}
