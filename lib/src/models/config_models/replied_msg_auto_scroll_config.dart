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

class RepliedMsgAutoScrollConfig {
  /// Auto scrolls to original message when tapped on replied message.
  /// Defaults to true.
  final bool enableScrollToRepliedMsg;

  /// Highlights the text by changing background color of chat bubble for
  /// given duration. Default to true.
  final bool enableHighlightRepliedMsg;

  /// Chat bubble color when highlighted. Defaults to Colors.grey.
  final Color highlightColor;

  /// Chat will remain highlighted for this duration. Defaults to 500ms.
  final Duration highlightDuration;

  /// When replied message have image or only emojis. They will be scaled
  /// for provided [highlightDuration] to highlight them. Defaults to 1.1
  final double highlightScale;

  /// Animation curve for auto scroll. Defaults to Curves.easeIn.
  final Curve highlightScrollCurve;

  /// Configuration for auto scrolling and highlighting a message when
  /// tapping on the original message above the replied message.
  const RepliedMsgAutoScrollConfig({
    this.enableHighlightRepliedMsg = true,
    this.enableScrollToRepliedMsg = true,
    this.highlightColor = Colors.grey,
    this.highlightDuration = const Duration(milliseconds: 500),
    this.highlightScale = 1.1,
    this.highlightScrollCurve = Curves.easeIn,
  });
}
