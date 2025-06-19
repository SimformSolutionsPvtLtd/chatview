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

import '../extensions/extensions.dart';

class ReplyIcon extends StatelessWidget {
  const ReplyIcon({
    Key? key,
    required this.animationValue,
    this.replyIconSize = 25,
  }) : super(key: key);

  /// Represents scale animation value of icon when user swipes for reply.
  final double animationValue;

  /// Allow user to set color of icon which is appeared when user swipes for reply.
  final double replyIconSize;

  @override
  Widget build(BuildContext context) {
    final swipeToReplyConfig = context.chatListConfig.swipeToReplyConfig;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(replyIconSize),
            color: animationValue >= 1.0
                ? swipeToReplyConfig?.replyIconBackgroundColor ??
                    Colors.grey.shade300
                : Colors.transparent,
          ),
          height: replyIconSize,
          width: replyIconSize,
          child: CircularProgressIndicator(
            value: animationValue,
            backgroundColor: Colors.transparent,
            strokeWidth: 1.5,
            color: swipeToReplyConfig?.replyIconProgressRingColor ??
                Colors.grey.shade300,
          ),
        ),
        Transform.scale(
          scale: animationValue,
          child: Icon(
            Icons.reply_rounded,
            color: swipeToReplyConfig?.replyIconColor ?? Colors.black,
            size: replyIconSize - 5,
          ),
        ),
      ],
    );
  }
}
