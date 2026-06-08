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

import '../models/models.dart';
import '../utils/constants/constants.dart';

class GlassMorphismReactionPopup extends StatelessWidget {
  const GlassMorphismReactionPopup({
    super.key,
    required this.child,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          constraints:
              BoxConstraints(maxWidth: reactionPopupConfig?.maxWidth ?? 350),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                backgroundColor.withAlpha(opacity),
                backgroundColor.withAlpha(opacity),
              ],
              stops: const <double>[
                0.3,
                0,
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 16,
              ),
              child: Padding(
                padding: reactionPopupConfig?.padding ??
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                child: child,
              ),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: true,
          child: Padding(
            padding: reactionPopupConfig?.margin ??
                const EdgeInsets.symmetric(horizontal: 25),
            child: CustomPaint(
              painter: _GradientPainter(
                strokeWidth: strokeWidth,
                radius: borderRadius,
                borderColor: borderColor,
              ),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: reactionPopupConfig?.maxWidth ?? maxWidth),
                padding: EdgeInsets.symmetric(
                  vertical: reactionPopupConfig?.emojiConfig?.size ?? 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(borderRadius),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
    final RRect innerRect2 = RRect.fromRectAndRadius(
      Rect.fromLTRB(strokeWidth, strokeWidth, size.width - strokeWidth,
          size.height - strokeWidth),
      Radius.circular(radius - strokeWidth),
    );

    final RRect outerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    _paintObject.shader = _gradient.createShader(Offset.zero & size);

    final Path outerRectPath = Path()..addRRect(outerRect);
    final Path innerRectPath2 = Path()..addRRect(innerRect2);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        outerRectPath,
        Path.combine(
          PathOperation.intersect,
          outerRectPath,
          innerRectPath2,
        ),
      ),
      _paintObject,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
