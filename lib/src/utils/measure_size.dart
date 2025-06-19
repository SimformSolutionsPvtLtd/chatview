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

/// This widget has been created for size of widget which is covered in view port
/// It also gives update when size changes.
class MeasureSize extends StatefulWidget {
  const MeasureSize({
    Key? key,
    required this.onSizeChange,
    required this.child,
  }) : super(key: key);
  final Widget? child;
  final ValueSetter<bool> onSizeChange;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  GlobalKey widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(Duration timestamp) {
    var currentContext = widgetKey.currentContext;
    if (currentContext == null) return;

    var newSize = currentContext.size;
    if (oldSize == newSize) return;
    oldSize = newSize;
    RenderBox? box = widgetKey.currentContext?.findRenderObject() as RenderBox?;
    Offset position = box!.localToGlobal(Offset.zero);

    /// Below logic checks that end position of widget greater than or less than
    /// to device width
    widget.onSizeChange(
        (position.dx + newSize!.width) >= MediaQuery.of(context).size.width);
  }
}
