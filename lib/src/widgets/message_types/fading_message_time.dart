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
import 'package:flutter/widgets.dart';

import '../../utils/constants/constants.dart';
import 'message_time_widget.dart';

/// The message time shown behind a bubble while it is swiped aside.
///
/// It fades in as the messages slide: invisible at rest, fully visible once
/// they have slid [timeRevealDistance]. Only this widget rebuilds on each swipe
/// frame, not the message list.
///
/// Example: with a [timeRevealDistance] of 120, a slide of `Offset(-60, 0)`
/// shows the time at 50% opacity.
///
/// Must be a child of a [Stack], it fills the bubble's area.
class FadingMessageTime extends StatelessWidget {
  const FadingMessageTime({
    required this.slideAnimation,
    required this.messageTime,
    required this.isCurrentUser,
    super.key,
  });

  /// How far the messages have slide, see [BubbleSlide].
  final Animation<Offset> slideAnimation;

  /// Time of the message to show.
  final DateTime messageTime;

  /// Whether the message was sent by the current user.
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: slideAnimation,
        child: Align(
          alignment: Alignment.centerRight,
          child: MessageTimeWidget(
            messageTime: messageTime,
            isCurrentUser: isCurrentUser,
          ),
        ),
        builder: (_, child) {
          final progress =
              (-slideAnimation.value.dx / timeRevealDistance).clamp(0.0, 1.0);
          return Visibility(
            visible: progress > 0,
            // Opacity goes inside Positioned, which must stay directly under
            // the Stack.
            child: Positioned.fill(
              child: Opacity(opacity: progress, child: child),
            ),
          );
        },
      );
}
