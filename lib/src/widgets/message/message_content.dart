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

import '../../extensions/extensions.dart';
import '../../inherited_widgets/chat_view_inherited_widget.dart';
import '../../models/config_models/chat_view/chat_bubble.dart';
import '../../models/config_models/chat_view/message/message_configuration.dart';
import '../message_types/custom/custom_message_view.dart';
import '../message_types/emoji/emoji_message_view.dart';
import '../message_types/image/image_message_view.dart';
import '../message_types/text/text_message_view.dart';
import '../message_types/voice/voice_message_view.dart';
import 'highlight_aware.dart';

/// Shows [message] with the view for its type: text, emoji, image, voice or
/// custom.
class MessageContent extends StatelessWidget {
  const MessageContent({
    required this.message,
    required this.isMessageBySender,
    required this.isOutsideBubbleEmoji,
    required this.highlightColor,
    required this.shouldHighlight,
    required this.highlightScale,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    this.messageConfig,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.onMaxDuration,
    super.key,
  });

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Whether the message is shown as bare emojis outside a chat bubble.
  final bool isOutsideBubbleEmoji;

  /// Allow user to giving customisation different types messages.
  final MessageConfiguration? messageConfig;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Allow users to pass colour of chat bubble when user taps on replied message.
  final Color highlightColor;

  /// Allow users to turn on/off highlighting chat bubble when user tap on replied message.
  final bool shouldHighlight;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  /// True when this is the oldest message in a consecutive same-sender group.
  final bool isFirstInGroup;

  /// True when this is the newest message in a consecutive same-sender group.
  final bool isLastInGroup;

  final ValueSetter<int>? onMaxDuration;

  @override
  Widget build(BuildContext context) {
    final featureActiveConfig =
        ChatViewInheritedWidget.of(context)?.featureActiveConfig;
    final reaction = message.reaction;
    final emojiMessageConfig = messageConfig?.emojiMessageConfig;
    final messageReactionConfig = messageConfig?.messageReactionConfig;
    return switch (message.messageType) {
      MessageType.image => HighlightAware(
          highlighted: shouldHighlight,
          builder: (_, highlighted, __) => ImageMessageView(
            message: message,
            isLastInGroup: isLastInGroup,
            isFirstInGroup: isFirstInGroup,
            highlightScale: highlightScale,
            highlightImage: highlighted,
            isMessageBySender: isMessageBySender,
            featureActiveConfig: featureActiveConfig,
            messageReactionConfig: messageReactionConfig,
            inComingChatBubbleConfig: inComingChatBubbleConfig,
            outgoingChatBubbleConfig: outgoingChatBubbleConfig,
            imageMessageConfig: messageConfig?.imageMessageConfig,
          ),
        ),
      MessageType.text when isOutsideBubbleEmoji => HighlightAware(
          highlighted: shouldHighlight,
          builder: (_, highlighted, __) => EmojiMessageView(
            reaction: reaction,
            message: message.message,
            padding: emojiMessageConfig?.padding,
            textStyle: emojiMessageConfig?.textStyle,
            isMessageBySender: isMessageBySender,
            chatBubbleMaxWidth: chatBubbleMaxWidth,
            messageReactionConfig: messageReactionConfig,
            highlightScale: highlighted ? highlightScale : 1.0,
          ),
        ),
      MessageType.text => TextMessageView(
          message: message,
          isLastInGroup: isLastInGroup,
          isFirstInGroup: isFirstInGroup,
          highlightColor: highlightColor,
          highlightMessage: shouldHighlight,
          isMessageBySender: isMessageBySender,
          chatBubbleMaxWidth: chatBubbleMaxWidth,
          featureActiveConfig: featureActiveConfig,
          messageReactionConfig: messageReactionConfig,
          inComingChatBubbleConfig: inComingChatBubbleConfig,
          outgoingChatBubbleConfig: outgoingChatBubbleConfig,
        ),
      MessageType.voice => VoiceMessageView(
          screenWidth: context.widthFraction(),
          message: message,
          onMaxDuration: onMaxDuration,
          config: messageConfig?.voiceMessageConfig,
          isMessageBySender: isMessageBySender,
          featureActiveConfig: featureActiveConfig,
          messageReactionConfig: messageReactionConfig,
          inComingChatBubbleConfig: inComingChatBubbleConfig,
          outgoingChatBubbleConfig: outgoingChatBubbleConfig,
        ),
      MessageType.custom when messageConfig?.customMessageBuilder != null =>
        CustomMessageView(
          reaction: reaction,
          isMessageBySender: isMessageBySender,
          messageReactionConfig: messageReactionConfig,
          showReactions: messageConfig?.showReactionsOnCustomMessages ?? true,
          customChild: messageConfig!.customMessageBuilder!.call(message),
        ),
      MessageType.custom => const SizedBox.shrink(),
    };
  }
}
