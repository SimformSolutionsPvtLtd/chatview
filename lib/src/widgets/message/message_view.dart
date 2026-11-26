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
import '../../values/typedefs.dart';
import 'long_press_scale.dart';
import 'message_body.dart';

class MessageView extends StatefulWidget {
  const MessageView({
    required this.message,
    required this.isMessageBySender,
    required this.onLongPress,
    required this.isLongPressEnable,
    required this.isOutsideBubbleEmoji,
    super.key,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.longPressAnimationDuration,
    this.onDoubleTap,
    this.highlightColor = Colors.grey,
    this.shouldHighlight = false,
    this.highlightScale = 1.2,
    this.messageConfig,
    this.onMaxDuration,
    this.controller,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.statusBelowBubble,
  });

  /// Status indicator shown right below the bubble, above the "Seen" label.
  final Widget? statusBelowBubble;

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Give callback once user long press on chat bubble.
  final DoubleCallBack onLongPress;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Allow users to give duration of animation when user long press on chat bubble.
  final Duration? longPressAnimationDuration;

  /// Allow user to set some action when user double tap on chat bubble.
  final ValueSetter<Message>? onDoubleTap;

  /// Allow users to pass colour of chat bubble when user taps on replied message.
  final Color highlightColor;

  /// Allow users to turn on/off highlighting chat bubble when user tap on replied message.
  final bool shouldHighlight;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  /// Allow user to giving customisation different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Allow user to turn on/off long press tap on chat bubble.
  final bool isLongPressEnable;

  /// Whether the message is shown as bare emojis outside a chat bubble.
  ///
  /// Decided once by the parent, which also needs it to place the status.
  final bool isOutsideBubbleEmoji;

  final ChatController? controller;

  final ValueSetter<int>? onMaxDuration;

  /// True when this is the oldest message in a consecutive same-sender group.
  final bool isFirstInGroup;

  /// True when this is the newest message in a consecutive same-sender group.
  final bool isLastInGroup;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  @override
  void initState() {
    super.initState();
    if (widget.message.status != MessageStatus.read &&
        !widget.isMessageBySender) {
      widget.inComingChatBubbleConfig?.onMessageRead?.call(widget.message);
    }
  }

  @override
  Widget build(BuildContext context) => LongPressScale(
        enable: widget.isLongPressEnable,
        duration: widget.longPressAnimationDuration,
        onLongPress: widget.onLongPress,
        // Null when the host set none: a double-tap recognizer would delay
        // every inner tap by about 300 ms.
        onDoubleTap: widget.onDoubleTap == null
            ? null
            : () => widget.onDoubleTap!.call(widget.message),
        child: MessageBody(
          message: widget.message,
          messageConfig: widget.messageConfig,
          isMessageBySender: widget.isMessageBySender,
          isOutsideBubbleEmoji: widget.isOutsideBubbleEmoji,
          chatBubbleMaxWidth: widget.chatBubbleMaxWidth,
          inComingChatBubbleConfig: widget.inComingChatBubbleConfig,
          outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
          highlightColor: widget.highlightColor,
          shouldHighlight: widget.shouldHighlight,
          highlightScale: widget.highlightScale,
          isFirstInGroup: widget.isFirstInGroup,
          isLastInGroup: widget.isLastInGroup,
          onMaxDuration: widget.onMaxDuration,
          controller: widget.controller,
          statusBelowBubble: widget.statusBelowBubble,
        ),
      );
}
