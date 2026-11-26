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

import 'dart:async';

import 'package:flutter/material.dart';

import '../../values/typedefs.dart';

/// Shrinks its [child] while the user long presses it, then springs it back.
///
/// [child] is built once by the parent and only scaled while animating, so a
/// long press does not rebuild the message.
class LongPressScale extends StatefulWidget {
  const LongPressScale({
    required this.enable,
    required this.onLongPress,
    required this.child,
    this.onDoubleTap,
    this.duration,
    super.key,
  });

  /// Whether a long press starts the animation and calls [onLongPress].
  final bool enable;

  /// Called with the global y and x position where the long press started.
  final DoubleCallBack onLongPress;

  /// Called when the user double taps [child].
  final VoidCallback? onDoubleTap;

  /// How long the shrinking takes. Defaults to 250 milliseconds.
  final Duration? duration;

  final Widget child;

  @override
  State<LongPressScale> createState() => _LongPressScaleState();
}

class _LongPressScaleState extends State<LongPressScale>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(LongPressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The feature may be turned on after the first build.
    _initializeController();
  }

  /// Creates the controller once, and only if long press is enabled.
  ///
  /// It runs from 0 to 0.1 and the child is scaled by `1 - value`, so the
  /// child shrinks by at most 10%. It springs back as soon as it is there.
  void _initializeController() {
    if (!widget.enable || _controller != null) return;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 250),
      upperBound: 0.1,
    )..addStatusListener((status) {
        if (status.isCompleted) {
          unawaited(_controller?.reverse());
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return GestureDetector(
      onLongPressStart: widget.enable ? _onLongPressStart : null,
      onDoubleTap: widget.onDoubleTap,
      child: widget.enable && controller != null
          ? AnimatedBuilder(
              animation: controller,
              child: widget.child,
              builder: (_, child) => Transform.scale(
                scale: 1 - controller.value,
                child: child,
              ),
            )
          : widget.child,
    );
  }

  Future<void> _onLongPressStart(LongPressStartDetails details) async {
    await _controller?.forward();
    // The widget can be removed while the animation runs.
    if (!mounted) return;
    widget.onLongPress(details.globalPosition.dy, details.globalPosition.dx);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
