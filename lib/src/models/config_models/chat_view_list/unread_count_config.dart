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

import '../../../utils/constants/constants.dart';
import '../../../values/enumeration.dart';
import '../../../values/typedefs.dart';

/// Configuration class for the unread message widget in the chat list UI.
class UnreadCountConfig {
  /// Creates a configuration object for the unread message widget in the chat list UI.
  const UnreadCountConfig({
    this.maxLines = 1,
    this.textScaler = TextScaler.noScaling,
    this.style = UnreadCountStyle.dot,
    this.backgroundColor = primaryColor,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.countWidgetBuilder,
    this.height,
    this.width,
    this.decoration,
    this.textStyle,
  });

  /// Background color for the unread count widget.
  ///
  /// Defaults to chatview `primaryColor`.
  final Color? backgroundColor;

  /// Text color for the unread count widget.
  ///
  /// Defaults to `Colors.white`.
  final Color? textColor;

  /// Font size for the unread count text.
  ///
  /// Defaults to `12`.
  final double? fontSize;

  /// Height for the unread count widget.
  final double? height;

  /// Width for the unread count widget.
  final double? width;

  /// Decoration for the unread count widget.
  final BoxDecoration? decoration;

  /// Style for the unread count in the user widget.
  ///
  /// Defaults to `UnreadCountStyle.dot`.
  final UnreadCountStyle style;

  /// Text styles for the unread count widget.
  final TextStyle? textStyle;

  /// Maximum number of lines for the unread count text.
  ///
  /// Defaults to `1`.
  final int? maxLines;

  /// Custom text scaler for the unread count text.
  ///
  /// Defaults to `TextScaler.noScaling`.
  final TextScaler? textScaler;

  /// Custom widget builder for the unread count widget.
  final UnreadCountWidgetBuilder? countWidgetBuilder;
}
