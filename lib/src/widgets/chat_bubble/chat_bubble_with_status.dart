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

/// Lays out a chat [bubble] with its optional [statusIndicator] beside it.
class ChatBubbleWithStatus extends StatelessWidget {
  const ChatBubbleWithStatus({
    required this.bubble,
    this.statusIndicator,
    this.alignStatusToBottom = false,
    super.key,
  });

  /// The chat bubble.
  final Widget bubble;

  /// Status indicator shown next to the bubble. Nothing extra is laid out when
  /// null.
  final Widget? statusIndicator;

  /// Whether [statusIndicator] is bottom-aligned instead of vertically
  /// centered.
  final bool alignStatusToBottom;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignStatusToBottom
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: [
        // Flexible keeps the bubble within the available width.
        Flexible(child: bubble),
        if (statusIndicator case final statusIndicator?) statusIndicator,
      ],
    );
  }
}
