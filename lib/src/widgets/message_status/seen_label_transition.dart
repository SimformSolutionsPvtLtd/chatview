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

/// Size, fade and slide transition for the "Seen" label inside an
/// `AnimatedSwitcher`. Pass [builder] as its `transitionBuilder`.
class SeenLabelTransition extends StatelessWidget {
  const SeenLabelTransition({
    required this.animation,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;

  /// Same function object on every build, so it can be a `transitionBuilder`.
  static Widget builder(Widget child, Animation<double> animation) =>
      SeenLabelTransition(animation: animation, child: child);

  static final _slide = Tween<Offset>(
    begin: const Offset(0, 0.35),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      // TODO(YASH): Use `alignment: Alignment.topCenter` and
      // remove axisAlignment (and the ignore) once the minimum
      // Flutter version has `SizeTransition.alignment`
      // (after 3.41).
      // ignore: deprecated_member_use
      axisAlignment: -1,
      // With the Align's widthFactor, keeps the row at
      // content width.
      fixedCrossAxisSizeFactor: 1,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: _slide.animate(animation),
          child: child,
        ),
      ),
    );
  }
}
