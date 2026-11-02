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

import '../extensions/extensions.dart';
import '../models/chat_bubble.dart';
import '../models/config_models/feature_active_config.dart';
import '../models/config_models/receipts_widget_config.dart';
import '../values/enumeration.dart';
import 'sending_message_animating_widget.dart';

/// The message time and the WhatsApp-style clock/tick, side by side, as drawn
/// at the bottom-right inside text, image and voice bubbles when
/// [SendingMessageAnimationType.clockToTick] is used.
class InBubbleTimeAndReceipt extends StatelessWidget {
  const InBubbleTimeAndReceipt({
    super.key,
    required this.message,
    required this.timeStyle,
    required this.showTime,
    required this.showReceipt,
    required this.outgoingChatBubbleConfig,
  });

  /// Message whose time and status are shown.
  final Message message;

  /// Style of the time. Its color is also the default tick color.
  final TextStyle timeStyle;

  /// Whether the message time is drawn.
  final bool showTime;

  /// Whether the clock/tick is drawn, see [shouldShowReceipt].
  final bool showReceipt;

  /// Outgoing bubble config that provides the receipts settings.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Whether the clock/tick is drawn inside the bubble for these settings.
  ///
  /// Honors the receiptsBuilderVisibility feature flag. A custom
  /// [ReceiptsWidgetConfig.receiptsBuilder] replaces it, in which case it is
  /// rendered next to the bubble by `MessageStatusIndicator` instead.
  static bool shouldShowReceipt({
    required bool isMessageBySender,
    required ChatBubble? outgoingChatBubbleConfig,
    required FeatureActiveConfig? featureActiveConfig,
  }) {
    final config = outgoingChatBubbleConfig?.receiptsWidgetConfig;
    return isMessageBySender &&
        (featureActiveConfig?.receiptsBuilderVisibility ?? true) &&
        config?.receiptsBuilder == null &&
        (config?.sendingAnimationType.isClockToTick ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showTime)
          Text(message.createdAt.getTimeFromDateTime, style: timeStyle),
        if (showTime && showReceipt) const SizedBox(width: 4),
        if (showReceipt)
          ValueListenableBuilder<MessageStatus>(
            valueListenable: message.statusNotifier,
            builder: (_, status, __) => SendingMessageAnimatingWidget(
              status,
              type: SendingMessageAnimationType.clockToTick,
              color: outgoingChatBubbleConfig
                      ?.receiptsWidgetConfig?.sendingIndicatorColor ??
                  timeStyle.color,
            ),
          ),
      ],
    );
  }
}
