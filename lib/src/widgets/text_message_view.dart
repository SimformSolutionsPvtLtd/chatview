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
import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/custom_selection_area.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../utils/constants/constants.dart';
import 'link_preview.dart';
import 'reaction_widget.dart';

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    super.key,
    required this.isMessageBySender,
    required this.message,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.messageReactionConfig,
    this.highlightMessage = false,
    this.highlightColor,
    this.featureActiveConfig,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.httpHeaders,
  });

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides message instance of chat.
  final Message message;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents message should highlight.
  final bool highlightMessage;

  /// Allow user to set color of highlighted message.
  final Color? highlightColor;

  /// Provides configuration of active features in chat.
  final FeatureActiveConfig? featureActiveConfig;

  /// True when this is the oldest message in a consecutive same-sender group.
  final bool isFirstInGroup;

  /// True when this is the newest message in a consecutive same-sender group.
  final bool isLastInGroup;

  /// Optional HTTP headers used for querying images.
  final Map<String, String>? httpHeaders;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textMessage = message.message;
    final showTimeInChatBubble =
        featureActiveConfig?.showTimeInChatBubble ?? false;
    final timeText = message.createdAt.getTimeFromDateTime;
    final border = isMessageBySender
        ? outgoingChatBubbleConfig?.border
        : inComingChatBubbleConfig?.border;
    final isSelectable = featureActiveConfig?.enableTextSelection ?? false;
    final textSelectionConfig = isMessageBySender
        ? outgoingChatBubbleConfig?.textSelectionConfig
        : inComingChatBubbleConfig?.textSelectionConfig;
    final extractedUrls = textMessage.extractedUrls;
    final timestampStyle = (textTheme.bodySmall ?? const TextStyle())
        .copyWith(
          fontSize: 12,
          color: isMessageBySender ? Colors.white70 : Colors.black54,
        )
        .merge(_messageTimeTextStyle);
    final effectiveTextStyle = _textStyle ??
        textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontSize: 16,
        ) ??
        const TextStyle(color: Colors.white, fontSize: 16);
    final baseWidget = extractedUrls.isNotEmpty
        ? LinkPreview(
            linkPreviewConfig: _linkPreviewConfig,
            textMessage: textMessage,
            extractedUrls: extractedUrls,
            normalTextStyle: effectiveTextStyle,
          )
        : Text(
            textMessage,
            style: effectiveTextStyle,
          );
    final messageWidget = isSelectable
        ? CustomSelectionArea(
            config: textSelectionConfig,
            child: baseWidget,
          )
        : baseWidget;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: chatBubbleMaxWidth ??
                  MediaQuery.of(context).size.width * 0.75),
          padding: _padding ??
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
          margin: _margin ??
              EdgeInsets.fromLTRB(
                  5, 0, 6, message.reaction.reactions.isNotEmpty ? 15 : 2),
          decoration: BoxDecoration(
            color: highlightMessage ? highlightColor : _color,
            border: border,
            borderRadius: _borderRadius(textMessage, showTimeInChatBubble),
            boxShadow: isMessageBySender
                ? outgoingChatBubbleConfig?.boxShadow
                : inComingChatBubbleConfig?.boxShadow,
          ),
          child: showTimeInChatBubble
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    if (extractedUrls.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          messageWidget,
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(timeText, style: timestampStyle),
                          ),
                        ],
                      );
                    }

                    final canShowInSingleLine = !textMessage.contains('\n') &&
                        _canRenderTimeInSingleLine(
                          context: context,
                          messageText: textMessage,
                          messageStyle: effectiveTextStyle,
                          timeText: timeText,
                          timeStyle: timestampStyle,
                          maxContentWidth: constraints.maxWidth,
                        );

                    if (canShowInSingleLine) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(child: messageWidget),
                          const SizedBox(width: 8),
                          Text(timeText, style: timestampStyle),
                        ],
                      );
                    }

                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Padding(
                          // Reserve space at bottom for timestamp without a
                          // large blank strip on the left.
                          padding: const EdgeInsets.only(bottom: 20),
                          child: messageWidget,
                        ),
                        Text(timeText, style: timestampStyle),
                      ],
                    );
                  },
                )
              : messageWidget,
        ),
        if (message.reaction.reactions.isNotEmpty)
          ReactionWidget(
            key: key,
            isMessageBySender: isMessageBySender,
            reaction: message.reaction,
            messageReactionConfig: messageReactionConfig,
            httpHeaders: httpHeaders,
          ),
      ],
    );
  }

  EdgeInsetsGeometry? get _padding => isMessageBySender
      ? outgoingChatBubbleConfig?.padding
      : inComingChatBubbleConfig?.padding;

  EdgeInsetsGeometry? get _margin => isMessageBySender
      ? outgoingChatBubbleConfig?.margin
      : inComingChatBubbleConfig?.margin;

  LinkPreviewConfiguration? get _linkPreviewConfig => isMessageBySender
      ? outgoingChatBubbleConfig?.linkPreviewConfig
      : inComingChatBubbleConfig?.linkPreviewConfig;

  TextStyle? get _textStyle => isMessageBySender
      ? outgoingChatBubbleConfig?.textStyle
      : inComingChatBubbleConfig?.textStyle;

  TextStyle? get _messageTimeTextStyle => isMessageBySender
      ? outgoingChatBubbleConfig?.messageTimeTextStyle
      : inComingChatBubbleConfig?.messageTimeTextStyle;

  BorderRadiusGeometry _borderRadius(
      String message, bool showTimeInChatBubble) {
    final config =
        isMessageBySender ? outgoingChatBubbleConfig : inComingChatBubbleConfig;
    if (config?.borderRadius != null) return config!.borderRadius!;

    final r =
        (showTimeInChatBubble && message.length < (isMessageBySender ? 37 : 29))
            ? replyBorderRadius1
            : replyBorderRadius2;

    final groupingEnabled = featureActiveConfig?.enableMessageGrouping ?? true;
    final standalone = isFirstInGroup && isLastInGroup;
    if (!groupingEnabled || standalone) return BorderRadius.circular(r);

    final small = (featureActiveConfig?.chainedCornerRadius ??
            (r * messageGroupCornerRadiusFactor))
        .clamp(0.0, r);

    // Sender → reduce only right-side corners (avatar is on the right).
    // Receiver → reduce only left-side corners (avatar is on the left).
    // First (top): bottom corner = small (connects down to next msg).
    // Last (bottom): top corner = small (connects up to prev msg).
    if (isMessageBySender) {
      return BorderRadius.only(
        topLeft: Radius.circular(r),
        topRight: Radius.circular(isFirstInGroup ? r : small),
        bottomLeft: Radius.circular(r),
        bottomRight: Radius.circular(isLastInGroup ? r : small),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(isFirstInGroup ? r : small),
        topRight: Radius.circular(r),
        bottomLeft: Radius.circular(isLastInGroup ? r : small),
        bottomRight: Radius.circular(r),
      );
    }
  }

  Color get _color => isMessageBySender
      ? outgoingChatBubbleConfig?.color ?? Colors.purple
      : inComingChatBubbleConfig?.color ?? Colors.grey.shade500;

  bool _canRenderTimeInSingleLine({
    required BuildContext context,
    required String messageText,
    required TextStyle messageStyle,
    required String timeText,
    required TextStyle? timeStyle,
    required double maxContentWidth,
  }) {
    if (messageText.length > 60) return false;

    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);

    final timePainter = TextPainter(
      text: TextSpan(text: timeText, style: timeStyle),
      textDirection: textDirection,
      maxLines: 1,
      textScaler: textScaler,
    )..layout(maxWidth: maxContentWidth);

    final availableForMessage = maxContentWidth - 8 - timePainter.width;

    final messagePainter = TextPainter(
      text: TextSpan(text: messageText, style: messageStyle),
      textDirection: textDirection,
      maxLines: 1,
      textScaler: textScaler,
    )..layout(maxWidth: availableForMessage);

    return !messagePainter.didExceedMaxLines &&
        messagePainter.width <= availableForMessage;
  }
}
