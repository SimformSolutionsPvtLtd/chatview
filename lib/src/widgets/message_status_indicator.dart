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
import '../models/config_models/receipts_widget_config.dart';
import '../values/enumeration.dart';
import 'chat_view_inherited_widget.dart';
import 'sending_message_animating_widget.dart';

/// Status indicator (sending, sent, read, ...) of an outgoing message that is
/// rendered next to its chat bubble. This is the "receipt" configured through
/// [ReceiptsWidgetConfig].
///
/// Depending on [ReceiptsWidgetConfig.showReceiptsIn] it is shown for every
/// message or only for the last one, and it uses the custom
/// [ReceiptsWidgetConfig.receiptsBuilder] when one is provided, falling back to
/// [SendingMessageAnimatingWidget] otherwise.
class MessageStatusIndicator extends StatelessWidget {
  const MessageStatusIndicator({
    super.key,
    required this.message,
    required this.isLast,
  });

  /// Message whose status is shown.
  final Message message;

  /// Whether [message] is the last message of the chat.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final receiptsConfig = context.chatListConfig.chatBubbleConfig
        ?.outgoingChatBubbleConfig?.receiptsWidgetConfig;

    final receiptScope =
        receiptsConfig?.showReceiptsIn ?? ShowReceiptsIn.lastMessage;

    // Which messages get an indicator, per ReceiptsWidgetConfig.showReceiptsIn.
    final isMessageEligible =
        receiptScope.isAll || (receiptScope.isLastMessage && isLast);

    // The feature flag that switches the indicator off for the whole chat.
    final isFeatureEnabled = ChatViewInheritedWidget.of(context)
            ?.featureActiveConfig
            .receiptsBuilderVisibility ??
        true;

    if (!isMessageEligible || !isFeatureEnabled) return const SizedBox.shrink();

    return ValueListenableBuilder<MessageStatus>(
      valueListenable: message.statusNotifier,
      builder: (_, status, __) =>
          receiptsConfig?.receiptsBuilder?.call(status) ??
          SendingMessageAnimatingWidget(
            status,
            type: receiptsConfig?.sendingAnimationType ??
                SendingMessageAnimationType.slideOut,
            color: receiptsConfig?.sendingIndicatorColor,
          ),
    );
  }
}
