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

import 'bubble_slide.dart';
import 'fading_message_time.dart';

/// Slides [child] with the swipe animation and, when [showSwipeTime] is true,
/// reveals the message time behind it.
class ChatBubbleSlideWrapper extends StatelessWidget {
  const ChatBubbleSlideWrapper({
    required this.slideAnimation,
    required this.messageTime,
    required this.isCurrentUser,
    required this.showSwipeTime,
    required this.child,
    super.key,
  });

  final Animation<Offset>? slideAnimation;
  final DateTime messageTime;
  final bool isCurrentUser;

  /// Whether the time fades in behind the bubble while it is swiped.
  final bool showSwipeTime;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = slideAnimation;
    if (showSwipeTime && animation != null) {
      return Stack(
        children: [
          FadingMessageTime(
            slideAnimation: animation,
            messageTime: messageTime,
            isCurrentUser: isCurrentUser,
          ),
          BubbleSlide(animation: animation, child: child),
        ],
      );
    }

    return BubbleSlide(
      animation: animation ?? const AlwaysStoppedAnimation(Offset.zero),
      child: child,
    );
  }
}
