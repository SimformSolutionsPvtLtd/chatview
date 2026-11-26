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
import 'package:flutter/rendering.dart' show RenderStack, RenderViewport;

import '../extensions/extensions.dart';

/// Reports whether [child], placed at the left edge of its parent [Stack],
/// would run past the right edge of the message list.
///
/// Measures after the first layout, when the child's size changes and when the
/// screen size changes (rotation).
class MeasureSize extends StatefulWidget {
  const MeasureSize({
    required this.onSizeChange,
    required this.child,
    this.enabled = true,
    super.key,
  });

  /// When false, [child] is returned as is and nothing is measured.
  final bool enabled;

  final Widget? child;

  /// Called with true when [child] would overflow the right edge of the list.
  final ValueSetter<bool> onSizeChange;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? _lastSize;

  /// Runs on mount and when the screen size changes. After a rotation the child
  /// keeps its size but the list edge moves, so it must be measured again.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.enabled) return;
    MediaQuery.sizeOf(context);
    _lastSize = null;
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child ?? const SizedBox.shrink();

    // Measures only when the size changes, not on every build.
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback(_measure);
        return true;
      },
      child: SizeChangedLayoutNotifier(child: widget.child),
    );
  }

  void _measure(Duration _) {
    if (!mounted) return;

    final childContext = context;
    final childSize = childContext.size;

    if (_lastSize == childSize) return;
    _lastSize = childSize;

    // The child itself (the chip).
    final childBox = childContext.findRenderObject() as RenderBox?;

    // Start from the parent Stack (the bubble), not the child: a child already
    // at `right: 0` would always look inside the list and flip back.
    // Falls back to the child if there is no Stack.
    final leftEdgeBox =
        context.findAncestorRenderObjectOfType<RenderStack>() ?? childBox;
    final childStartX = leftEdgeBox!.localToGlobal(Offset.zero).dx;

    // The list's right edge, not the screen's: a cutout can narrow the list.
    final listViewport =
        context.findAncestorRenderObjectOfType<RenderViewport>();

    // Top-right corner of the list, converted to screen coordinates.
    final listRightEdgeX = listViewport == null
        ? context.widthFraction()
        : listViewport.localToGlobal(Offset(listViewport.size.width, 0)).dx;

    final wouldOverflow = (childStartX + childSize!.width) >= listRightEdgeX;
    widget.onSizeChange(wouldOverflow);
  }
}
