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

import 'package:chatview/src/widgets/adaptive_image.dart';
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../models/chat_bubble.dart';
import '../models/config_models/feature_active_config.dart';
import '../models/config_models/image_message_configuration.dart';
import '../models/config_models/message_reaction_configuration.dart';
import '../utils/constants/constants.dart';
import 'reaction_widget.dart';
import 'share_icon.dart';

class ImageMessageView extends StatelessWidget {
  const ImageMessageView({
    super.key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
    this.featureActiveConfig,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration for image message appearance.
  final ImageMessageConfiguration? imageMessageConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents flag of highlighting image when user taps on replied image.
  final bool highlightImage;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  /// Provides configuration of active features in chat.
  final FeatureActiveConfig? featureActiveConfig;

  /// True when this is the oldest message in a consecutive same-sender group.
  final bool isFirstInGroup;

  /// True when this is the newest message in a consecutive same-sender group.
  final bool isLastInGroup;

  String get imageUrl => message.message;

  Widget get iconButton => ShareIcon(
        shareIconConfig: imageMessageConfig?.shareIconConfig,
        imageUrl: imageUrl,
      );

  BorderRadius _groupAwareBorderRadius() {
    if (imageMessageConfig?.borderRadius != null) {
      return imageMessageConfig!.borderRadius!;
    }
    const r = imageBubbleBorderRadius;
    final groupingEnabled = featureActiveConfig?.enableMessageGrouping ?? true;
    final standalone = isFirstInGroup && isLastInGroup;
    if (!groupingEnabled || standalone) {
      return const BorderRadius.all(Radius.circular(r));
    }
    final small = (featureActiveConfig?.chainedCornerRadius ??
            (r * messageGroupCornerRadiusFactor))
        .clamp(0.0, r);

    // Sender → reduce only right-side corners.
    // Receiver → reduce only left-side corners.
    // First (top): bottom corner = small (connects down to next msg).
    // Last (bottom): top corner = small (connects up to prev msg).
    if (isMessageBySender) {
      return BorderRadius.only(
        topLeft: const Radius.circular(r),
        topRight: Radius.circular(isFirstInGroup ? r : small),
        bottomLeft: const Radius.circular(r),
        bottomRight: Radius.circular(isLastInGroup ? r : small),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(isFirstInGroup ? r : small),
        topRight: const Radius.circular(r),
        bottomLeft: Radius.circular(isLastInGroup ? r : small),
        bottomRight: const Radius.circular(r),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = _groupAwareBorderRadius();
    final backgroundColor = isMessageBySender
        ? outgoingChatBubbleConfig?.color ?? Colors.purple
        : inComingChatBubbleConfig?.color ?? Colors.grey.shade500;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isMessageBySender && !(imageMessageConfig?.hideShareIcon ?? false))
          iconButton,
        Stack(
          children: [
            GestureDetector(
              onTap: () => imageMessageConfig?.onTap != null
                  ? imageMessageConfig?.onTap!(message)
                  : null,
              child: Transform.scale(
                scale: highlightImage ? highlightScale : 1.0,
                alignment: isMessageBySender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: borderRadius,
                    border: imageMessageConfig?.border,
                  ),
                  padding: imageMessageConfig?.padding ?? EdgeInsets.zero,
                  margin: imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: isMessageBySender ? 6 : 0,
                        left: isMessageBySender ? 0 : 6,
                        bottom: message.reaction.reactions.isNotEmpty ? 15 : 0,
                      ),
                  height: imageMessageConfig?.height ?? 200,
                  width: imageMessageConfig?.width ?? 150,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: borderRadius,
                        child: SizedBox.expand(
                          child: AdaptiveImage(
                            imageUrl: imageUrl,
                            fit: imageMessageConfig?.fit ?? BoxFit.cover,
                            errorBuilder: imageMessageConfig?.errorBuilder,
                            httpHeaders: imageMessageConfig?.httpHeaders,
                          ),
                        ),
                      ),
                      if (featureActiveConfig?.showTimeInChatBubble ?? false)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message.createdAt.getTimeFromDateTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ).merge(
                                isMessageBySender
                                    ? outgoingChatBubbleConfig
                                        ?.messageTimeTextStyle
                                    : inComingChatBubbleConfig
                                        ?.messageTimeTextStyle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (message.reaction.reactions.isNotEmpty)
              ReactionWidget(
                isMessageBySender: isMessageBySender,
                reaction: message.reaction,
                messageReactionConfig: messageReactionConfig,
              ),
          ],
        ),
        if (!isMessageBySender && !(imageMessageConfig?.hideShareIcon ?? false))
          iconButton,
      ],
    );
  }
}
