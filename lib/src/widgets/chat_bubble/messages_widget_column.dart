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
import '../../models/config_models/chat_view/message/receipts_widget_config.dart';
import '../../utils/constants/constants.dart';
import '../../utils/package_strings.dart';
import '../../values/enumeration.dart';
import '../../values/typedefs.dart';
import '../message/message_view.dart';
import '../reply/reply_message_widget.dart';
import '../reply/swipe_to_reply.dart';
import 'chat_bubble_with_status.dart';

/// Column shown for one message: sender name, replied message, "edited"
/// label and the bubble itself with its status indicator.
class MessagesWidgetColumn extends StatelessWidget {
  const MessagesWidgetColumn({
    required this.messageStatusIndicator,
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
  final ValueSetter<String>? onReplyTap;
  final bool shouldHighlight;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  final Widget messageStatusIndicator;

  ReceiptsWidgetConfig? get _receiptsConfig => chatListConfig
      .chatBubbleConfig?.outgoingChatBubbleConfig?.receiptsWidgetConfig;

  SendingMessageAnimationType get _sendingAnimationType =>
      _receiptsConfig?.sendingAnimationType ??
      SendingMessageAnimationType.slideOut;

  /// Whether the clock/tick sits below the bubble: custom messages and
  /// bubble-less emoji messages have no inline slot, and a custom
  /// `receiptsBuilder` replaces the inline tick.
  bool get _showClockToTickBelowBubble =>
      _sendingAnimationType.isClockToTick &&
      (message.messageType.isCustom ||
          _receiptsConfig?.receiptsBuilder != null ||
          isOutsideBubbleEmoji);

  /// Whether the status indicator sits beside the bubble.
  bool get _showStatusBesideBubble =>
      isMessageBySender && _sendingAnimationType.isSlideOut;

  /// Whether the status indicator sits just below the bubble.
  bool get _showStatusBelowBubble =>
      isMessageBySender &&
      (_sendingAnimationType.isTextLabel || _showClockToTickBelowBubble);

  @override
  Widget build(BuildContext context) {
    final replyMessage = message.replyMessage;

    final chatBubbleConfig = chatListConfig.chatBubbleConfig;
    final repliedMessageConfig = chatListConfig.repliedMessageConfig;
    final repliedMsgAutoScrollConfig =
        repliedMessageConfig?.repliedMsgAutoScrollConfig;
    final repliedMessageWidgetBuilder =
        repliedMessageConfig?.repliedMessageWidgetBuilder;
    final inComingChatBubbleConfig = chatBubbleConfig?.inComingChatBubbleConfig;

    // If showTimeInChatBubble is enabled and message length is less than 37,
    // use smaller horizontal padding to accommodate time in the bubble.
    // Otherwise, use larger padding.
    final horizontalPadding =
        ((featureActiveConfig?.showTimeInChatBubble ?? false) &&
                message.message.length < 37)
            ? replyBorderRadius1
            : replyBorderRadius2;
    return Column(
      crossAxisAlignment:
          isMessageBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // TODO: add a non-copying `hasOtherUsers` getter to ChatController
        // (chatview_utils); `otherUsers` copies the map, so it is checked last.
        if (!isMessageBySender &&
            isFirstInGroup &&
            (featureActiveConfig?.enableOtherUserName ?? true) &&
            (chatController?.otherUsers.isNotEmpty ?? false))
          Padding(
            padding: inComingChatBubbleConfig?.padding ??
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              messagedUser?.name ?? '',
              style: inComingChatBubbleConfig?.senderNameTextStyle,
            ),
          ),
        if (replyMessage.message.isNotEmpty)
          repliedMessageWidgetBuilder?.call(replyMessage) ??
              ReplyMessageWidget(
                replyMessage: replyMessage,
                config: repliedMessageConfig,
                onTap: () => onReplyTap?.call(replyMessage.messageId),
              ),
        if (message.updatedAt != null && message.messageType.isText)
          Padding(
            padding: EdgeInsets.only(
              left: isMessageBySender ? 0 : horizontalPadding,
              right: isMessageBySender ? horizontalPadding : 0,
              bottom: 2,
            ),
            child: Text(
              PackageStrings.currentLocale.edited,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ChatBubbleWithStatus(
          statusIndicator:
              _showStatusBesideBubble ? messageStatusIndicator : null,
          alignStatusToBottom: _receiptsConfig?.receiptsBuilder != null,
          bubble: SwipeToReply(
            isMessageByCurrentUser: isMessageBySender,
            onSwipe: onSwipe,
            child: MessageView(
              message: message,
              onLongPress: onLongPress,
              controller: chatController,
              onMaxDuration: onMaxDuration,
              isLastInGroup: isLastInGroup,
              isFirstInGroup: isFirstInGroup,
              shouldHighlight: shouldHighlight,
              isMessageBySender: isMessageBySender,
              isOutsideBubbleEmoji: isOutsideBubbleEmoji,
              messageConfig: chatListConfig.messageConfig,
              chatBubbleMaxWidth: chatBubbleConfig?.maxWidth,
              inComingChatBubbleConfig: inComingChatBubbleConfig,
              highlightScale: repliedMsgAutoScrollConfig?.highlightScale ?? 1.1,
              outgoingChatBubbleConfig:
                  chatBubbleConfig?.outgoingChatBubbleConfig,
              longPressAnimationDuration:
                  chatBubbleConfig?.longPressAnimationDuration,
              statusBelowBubble:
                  _showStatusBelowBubble ? messageStatusIndicator : null,
              highlightColor:
                  repliedMsgAutoScrollConfig?.highlightColor ?? Colors.grey,
              isLongPressEnable:
                  (featureActiveConfig?.enableReactionPopup ?? true) ||
                      (featureActiveConfig?.enableReplySnackBar ?? true),
              onDoubleTap: featureActiveConfig?.enableDoubleTapToLike ?? false
                  ? chatBubbleConfig?.onDoubleTap ??
                      (tapped) => currentUser != null
                          ? chatController?.setReaction(
                              emoji: heart,
                              messageId: tapped.id,
                              userId: currentUser!.id,
                            )
                          : null
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
