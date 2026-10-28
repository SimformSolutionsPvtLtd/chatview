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

class LinkPreviewConfiguration {
  const LinkPreviewConfiguration({
    this.onUrlDetect,
    this.loadingColor,
    this.backgroundColor,
    this.borderRadius,
    this.bodyStyle,
    this.titleStyle,
    this.linkStyle,
    this.padding,
    this.proxyUrl,
    this.errorBody,
  });

  /// Used for giving background colour of message with link.
  final Color? backgroundColor;

  /// Used for giving border radius of message with link.
  final double? borderRadius;

  /// Used for giving text style of body text in message with link.
  final TextStyle? bodyStyle;

  /// Used for giving text style of title text in message with link.
  final TextStyle? titleStyle;

  /// Used for giving text style of link text in message with link.
  final TextStyle? linkStyle;

  /// Used for giving colour of loader in message with link.
  final Color? loadingColor;

  /// Used for giving padding to message with link.
  final EdgeInsetsGeometry? padding;

  /// Used for giving proxy url to message with link.
  final String? proxyUrl;

  /// Provides callback when message detect url in message.
  final ValueSetter<String>? onUrlDetect;

  /// Displays an error message when the link cannot be parsed for preview.
  final String? errorBody;
}
