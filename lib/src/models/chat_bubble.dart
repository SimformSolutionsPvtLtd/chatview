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

import 'config_models/link_preview_configuration.dart';
import 'config_models/receipts_widget_config.dart';

class ChatBubble {
  const ChatBubble({
    this.color,
    this.borderRadius,
    this.textStyle,
    this.padding,
    this.margin,
    this.linkPreviewConfig,
    this.senderNameTextStyle,
    this.receiptsWidgetConfig,
    this.onMessageRead,
  });

  /// Used for giving color of chat bubble.
  final Color? color;

  /// Used for giving border radius of chat bubble.
  final BorderRadiusGeometry? borderRadius;

  /// Used for giving text style of chat bubble.
  final TextStyle? textStyle;

  /// Used for giving padding of chat bubble.
  final EdgeInsetsGeometry? padding;

  /// Used for giving margin of chat bubble.
  final EdgeInsetsGeometry? margin;

  /// Used to provide configuration of messages with link.
  final LinkPreviewConfiguration? linkPreviewConfig;

  /// Used to give text style of message sender name.
  final TextStyle? senderNameTextStyle;

  /// Used to provide builders for last seen message reciept,
  /// at latest outgoing messsage.
  final ReceiptsWidgetConfig? receiptsWidgetConfig;

  /// Callback when a message has been displayed for the first
  /// time only
  final ValueSetter<Message>? onMessageRead;
}
