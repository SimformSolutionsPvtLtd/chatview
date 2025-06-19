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

class ReplyPopupConfiguration {
  const ReplyPopupConfiguration({
    this.buttonTextStyle,
    this.topBorderColor,
    this.onUnsendTap,
    this.onReplyTap,
    this.onReportTap,
    this.onMoreTap,
    this.backgroundColor,
    this.replyPopupBuilder,
  });

  /// Used for giving background color to reply snack-bar.
  final Color? backgroundColor;

  /// Provides builder for creating reply pop-up widget.
  final ReplyPopupBuilder? replyPopupBuilder;

  /// Provides callback on unSend button.
  final MessageCallBack? onUnsendTap;

  /// Provides callback on onReply button.
  final MessageCallBack? onReplyTap;

  /// Provides callback on onReport button.
  final MessageCallBack? onReportTap;

  /// Provides callback on onMore button.
  final MoreTapCallBack? onMoreTap;

  /// Used to give text style of button text.
  final TextStyle? buttonTextStyle;

  /// Used to give color to top side border of reply snack bar.
  final Color? topBorderColor;
}
