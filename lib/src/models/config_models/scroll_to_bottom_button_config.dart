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

import '../../values/enumeration.dart';

/// Configuration for the "Scroll to Bottom" button.
class ScrollToBottomButtonConfig {
  ScrollToBottomButtonConfig({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.icon,
    this.scrollAnimationDuration,
    this.alignment,
    this.padding,
    this.onClick,
    this.buttonDisplayOffset,
  });

  /// The background color of the button.
  final Color? backgroundColor;

  /// The border of the button.
  final Border? border;

  /// The border radius of the button.
  final BorderRadius? borderRadius;

  /// The icon displayed on the button.
  final Icon? icon;

  /// The duration of the scroll animation when the button is clicked.
  final Duration? scrollAnimationDuration;

  /// The alignment of the button on top of text field.
  final ScrollButtonAlignment? alignment;

  /// The padding around the button.
  final EdgeInsets? padding;

  /// The callback function to be executed when the button is clicked.
  final VoidCallback? onClick;

  /// The scroll offset after which the button is displayed.
  /// The button appears when the scroll position is greater than or equal to this value.
  final double? buttonDisplayOffset;
}
