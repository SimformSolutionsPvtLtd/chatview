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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../utils/constants/constants.dart';
import '../values/typedefs.dart';

/// A widget builder that contains the logic to calculate the height of the chat text field
/// When reply message view is shown update the height of the chat text field
/// When selected image view is shown update the height of the chat text field
class ChatTextFieldViewBuilder<T> extends StatelessWidget {
  /// A widget that rebuilds when the value of a [ValueNotifier] changes.
  const ChatTextFieldViewBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
  });

  /// The [ValueListenable] that provides the value to be listened to.
  final ValueListenable<T> valueListenable;

  /// The builder function that takes the current context, value, and an optional child widget.
  final ChatTextFieldViewBuilderCallback<T> builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final chatViewIW = context.chatViewIW;
          // Update the chat text field height based on the current context size.
          chatViewIW?.chatTextFieldHeight.value =
              chatViewIW.chatTextFieldViewKey.currentContext?.size?.height ??
                  defaultChatTextFieldHeight;
        });
        return builder.call(context, value, child);
      },
    );
  }
}
