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
import '../../../values/typedefs.dart';

class LastMessageTimeConfig {
  const LastMessageTimeConfig({
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.dateFormatPattern = defaultDateFormat,
    this.spaceBetweenTimeAndUnreadCount = 5,
    this.textStyle,
    this.timeBuilder,
  });

  /// Maximum number of lines for the last message time in the chat list.
  ///
  /// Defaults to `1`.
  final int? maxLines;

  /// Text overflow behavior for the last message time in the chat list.
  ///
  /// Defaults to `TextOverflow.ellipsis`.
  final TextOverflow? overflow;

  /// Text style for the last message time in the chat list.
  final TextStyle? textStyle;

  /// Time format pattern for displaying time in the chat list
  /// if the last message date older than yesterday.
  ///
  /// Defaults to `dd/MM/yyyy` format.
  final String dateFormatPattern;

  /// Space between the time and unread count in the user widget.
  ///
  /// Defaults to `5.0`.
  final double spaceBetweenTimeAndUnreadCount;

  final LastMessageTimeBuilder? timeBuilder;
}
