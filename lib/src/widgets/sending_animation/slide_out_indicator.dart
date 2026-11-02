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

import '../../utils/constants/constants.dart';

/// Default indicator: a small dot that slides out to the right once sent.
class SlideOutIndicator extends StatefulWidget {
  const SlideOutIndicator(this.status, {required this.color, super.key});

  /// Status of the message; the dot is shown while it is pending.
  final MessageStatus status;

  /// Color of the dot.
  final Color color;

  @override
  State<SlideOutIndicator> createState() => _SlideOutIndicatorState();
}

class _SlideOutIndicatorState extends State<SlideOutIndicator>
    with SingleTickerProviderStateMixin {
  /// Runs for twice the animation time: the first half is the wait before the
  /// dot slides out, the second half is the slide. This replaces a timer, so a
  /// retry just runs it back toward 1 and there is nothing to cancel.
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: sendingAnimationDuration * 2,
    // Start half-visible while pending, already collapsed when the message
    // was sent before this widget was ever built (e.g. history scroll-in or
    // ShowReceiptsIn.all) so no stuck dot remains.
    value: widget.status.isPending ? 1.0 : 0.0,
  );

  /// Stays at 1 during the wait (first half), then eases to 0 (second half).
  late final _curved = CurvedAnimation(
    parent: _animationController,
    curve: Interval(0, 0.5, curve: sendingAnimationCurve),
  );

  /// Horizontal offset of the dot: 0 while pending, slid out by half its size
  /// once sent.
  late final Animation<double> _dx =
      Tween<double>(begin: slideOutDotSize * 0.5, end: 0.0).animate(_curved);

  /// Visible clip width: half the dot while pending, 0 once sent.
  late final Animation<double> _width =
      Tween<double>(begin: 0.0, end: slideOutDotSize * 0.5).animate(_curved);

  /// Keeps the dot in step with the status: it slides out once the message is
  /// no longer pending and shows again if the message becomes pending again
  /// (for example when a failed message is retried).
  @override
  void didUpdateWidget(SlideOutIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.animateTo(widget.status.isPending ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (_, child) => SizedBox(
            width: _width.value,
            height: slideOutDotSize,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: slideOutDotSize,
              maxWidth: slideOutDotSize,
              child: Transform.translate(
                offset: Offset(_dx.value, 0),
                child: child,
              ),
            ),
          ),
          child: Container(
            width: slideOutDotSize,
            height: slideOutDotSize,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
