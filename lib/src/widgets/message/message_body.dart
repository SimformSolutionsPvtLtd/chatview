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

import '../../models/config_models/chat_view/chat_bubble.dart';
import '../../models/config_models/chat_view/message/message_configuration.dart';
import '../message_status/message_seen_label.dart';
import 'message_content.dart';

/// A message and what sits under it: [statusBelowBubble] and, for the newest
/// message of the current user, the "Seen" label.
class MessageBody extends StatelessWidget {
  const MessageBody({
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
    this.controller,
    this.statusBelowBubble,
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

  /// Used to find out whether [message] is the newest message.
  final ChatController? controller;

  /// Status indicator shown right below the bubble, above the "Seen" label.
  final Widget? statusBelowBubble;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: message.reaction.reactions.isNotEmpty ? 6 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MessageContent(
            message: message,
            messageConfig: messageConfig,
            isMessageBySender: isMessageBySender,
            isOutsideBubbleEmoji: isOutsideBubbleEmoji,
            chatBubbleMaxWidth: chatBubbleMaxWidth,
            inComingChatBubbleConfig: inComingChatBubbleConfig,
            outgoingChatBubbleConfig: outgoingChatBubbleConfig,
            highlightColor: highlightColor,
            shouldHighlight: shouldHighlight,
            highlightScale: highlightScale,
            isFirstInGroup: isFirstInGroup,
            isLastInGroup: isLastInGroup,
            onMaxDuration: onMaxDuration,
          ),
          if (statusBelowBubble case final status?)
            Padding(padding: const EdgeInsets.only(right: 6), child: status),
          if (isMessageBySender)
            MessageSeenLabel(
              message: message,
              controller: controller,
              outgoingChatBubbleConfig: outgoingChatBubbleConfig,
            ),
        ],
      ),
    );
  }
}
