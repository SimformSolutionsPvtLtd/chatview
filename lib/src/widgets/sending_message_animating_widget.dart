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

import '../utils/constants/constants.dart';
import '../values/enumeration.dart';
import 'sending_animation/clock_to_tick_indicator.dart';
import 'sending_animation/sending_text_label.dart';
import 'sending_animation/slide_out_indicator.dart';

/// Renders the sending → sent receipt indicator next to an outgoing chat
/// bubble, dispatching to one of the [SendingMessageAnimationType]
/// implementations.
class SendingMessageAnimatingWidget extends StatelessWidget {
  const SendingMessageAnimatingWidget(
    this.status, {
    this.type = SendingMessageAnimationType.slideOut,
    this.color,
    super.key,
  });

  /// Status of the message the indicator reflects.
  final MessageStatus status;

  /// The animation style used for the pending → sent transition.
  final SendingMessageAnimationType type;

  /// Optional color for the indicator. When null, a default is used. Useful to
  /// match the surrounding bubble (e.g. light color inside a colored bubble).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? sendingIndicatorDefaultColor;
    return switch (type) {
      SendingMessageAnimationType.slideOut =>
        SlideOutIndicator(status, color: indicatorColor),
      SendingMessageAnimationType.textLabel =>
        SendingTextLabel(status, color: indicatorColor),
      SendingMessageAnimationType.clockToTick =>
        ClockToTickIndicator(status, color: indicatorColor),
    };
  }
}
