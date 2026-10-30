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

import '../../extensions/extensions.dart';

/// Keeps the message list's bottom padding equal to the chat text field's
/// height: measures [child] once it is laid out, then again whenever it
/// changes size.
///
/// The text field grows and shrinks as the user types, and when a reply, edit
/// or image preview appears.
///
/// Example: typing a fourth line grows the field from 66 to 114, so the list's
/// bottom padding becomes 114 and the last message stays above the field.
///
/// [child] must hold the `chatTextFieldViewKey` of the `ChatViewInheritedWidget`,
/// that key is what gets measured.
class TextFieldSizeObserver extends StatefulWidget {
  const TextFieldSizeObserver({required this.child, super.key});

  final Widget child;

  @override
  State<TextFieldSizeObserver> createState() => _TextFieldSizeObserverState();
}

class _TextFieldSizeObserverState extends State<TextFieldSizeObserver> {
  @override
  void initState() {
    super.initState();
    _measureAfterFrame();
  }

  // Never measure during layout, that would rebuild the list mid-layout.
  void _measureAfterFrame() => WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.calculateAndUpdateTextFieldHeight(),
      );

  @override
  Widget build(BuildContext context) =>
      NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (_) {
          _measureAfterFrame();
          return false;
        },
        child: SizeChangedLayoutNotifier(child: widget.child),
      );
}
