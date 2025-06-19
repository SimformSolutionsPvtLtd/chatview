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
import 'package:flutter/material.dart';

import '../../values/typedefs.dart';
import 'replied_msg_auto_scroll_config.dart';

class RepliedMessageConfiguration {
  const RepliedMessageConfiguration({
    this.verticalBarColor,
    this.backgroundColor,
    this.textStyle,
    this.replyTitleTextStyle,
    this.margin,
    this.padding,
    this.maxWidth,
    this.borderRadius,
    this.verticalBarWidth,
    this.repliedImageMessageHeight,
    this.repliedImageMessageWidth,
    this.repliedMessageWidgetBuilder,
    this.opacity,
    this.repliedMsgAutoScrollConfig = const RepliedMsgAutoScrollConfig(),
    this.micIconColor,
  });

  /// Used to give color to vertical bar.
  final Color? verticalBarColor;

  /// Used to give background color to replied message widget.
  final Color? backgroundColor;

  /// Used to give text style to reply message.
  final TextStyle? textStyle;

  /// Used to give text style to replied message widget's title
  final TextStyle? replyTitleTextStyle;

  /// Used to give margin in replied message widget.
  final EdgeInsetsGeometry? margin;

  /// Used to give padding in replied message widget.
  final EdgeInsetsGeometry? padding;

  /// Used to give max width in replied message widget.
  final double? maxWidth;

  /// Used to give border radius in replied message widget.
  final BorderRadiusGeometry? borderRadius;

  /// Used to give width to vertical bar in replied message widget.
  final double? verticalBarWidth;

  /// Used to give height of image when there is image in replied message.
  final double? repliedImageMessageHeight;

  /// Used to give width of image when there is image in replied message.
  final double? repliedImageMessageWidth;

  /// Used to give opacity of replied message.
  final double? opacity;

  /// Provides builder for custom view of replied message.
  final ReplyMessageWithReturnWidget? repliedMessageWidgetBuilder;

  /// Configuration for auto scrolling and highlighting a message when
  /// tapping on the original message above the replied message.
  final RepliedMsgAutoScrollConfig repliedMsgAutoScrollConfig;

  /// Color for microphone icon.
  final Color? micIconColor;
}
