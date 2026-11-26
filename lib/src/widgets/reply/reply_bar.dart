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

/// Draws the vertical bar of a replied message as a border on the side
/// facing the screen edge, with [child] inside it.
class ReplyBar extends StatelessWidget {
  const ReplyBar({
    required this.child,
    required this.replyBySender,
    super.key,
    this.verticalBarColor,
    this.verticalBarWidth,
  });

  final Widget child;

  /// Bar is on the right when the current user replied, else on the left.
  final bool replyBySender;

  final Color? verticalBarColor;
  final double? verticalBarWidth;

  @override
  Widget build(BuildContext context) {
    final bar = BorderSide(
      width: verticalBarWidth ?? 2.5,
      color: verticalBarColor ?? Colors.grey.shade300,
    );
    return Container(
      padding: EdgeInsets.only(
        left: replyBySender ? 0 : 4,
        right: replyBySender ? 4 : 0,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: replyBySender ? BorderSide.none : bar,
          right: replyBySender ? bar : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
