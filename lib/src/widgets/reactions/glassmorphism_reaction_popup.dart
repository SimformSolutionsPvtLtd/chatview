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
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/constants/constants.dart';

class GlassMorphismReactionPopup extends StatelessWidget {
  const GlassMorphismReactionPopup({
    required this.child,
    super.key,
    this.reactionPopupConfig,
  });

  /// Allow user to assign custom widget which is appeared in glassmorphism
  /// effect.
  final Widget child;

  /// Provides configuration for reaction pop-up appearance.
  final ReactionPopupConfiguration? reactionPopupConfig;

  Color get backgroundColor =>
      reactionPopupConfig?.glassMorphismConfig?.backgroundColor ?? Colors.white;

  double get strokeWidth =>
      reactionPopupConfig?.glassMorphismConfig?.strokeWidth ?? 2;

  Color get borderColor =>
      reactionPopupConfig?.glassMorphismConfig?.borderColor ??
      Colors.grey.shade400;

  double get borderRadius =>
      reactionPopupConfig?.glassMorphismConfig?.borderRadius ?? 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Margin applied once, to the glass and its border together.
      padding: reactionPopupConfig?.margin ??
          const EdgeInsets.symmetric(horizontal: 25),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: reactionPopupConfig?.maxWidth ?? 350),
        child: CustomPaint(
          // Painted on the glass box itself, so the ring always matches it.
          foregroundPainter: _GradientPainter(
            strokeWidth: strokeWidth,
            radius: borderRadius,
            borderColor: borderColor,
          ),
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 16),
              child: ColoredBox(
                color: backgroundColor.withAlpha(opacity),
                child: Padding(
                  padding: reactionPopupConfig?.padding ??
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  _GradientPainter({
    required this.strokeWidth,
    required this.radius,
    required this.borderColor,
  });

  final double radius;
  final double strokeWidth;

  final Color borderColor;
  final Paint _paintObject = Paint();

  LinearGradient get _gradient => LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: <Color>[
          borderColor.withAlpha(50),
          borderColor.withAlpha(55),
          borderColor.withAlpha(50),
        ],
        stops: const <double>[0.06, 0.95, 1],
      );

  @override
  void paint(Canvas canvas, Size size) {
    final innerRect2 = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        strokeWidth,
        strokeWidth,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius - strokeWidth),
    );

    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    _paintObject.shader = _gradient.createShader(Offset.zero & size);

    // Draw the border as one path holding two shapes: outer and inner rect.
    // `evenOdd` fills only the part covered by one shape (the ring) and leaves
    // the inside of the inner rect empty. This is cheaper than cutting that
    // hole with `Path.combine` on every paint.
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(outerRect)
      ..addRRect(innerRect2);
    canvas.drawPath(path, _paintObject);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      oldDelegate is _GradientPainter &&
      (oldDelegate.radius != radius ||
          oldDelegate.strokeWidth != strokeWidth ||
          oldDelegate.borderColor != borderColor);
}
