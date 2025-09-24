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

class TypeIndicatorConfiguration {
  const TypeIndicatorConfiguration({
    this.indicatorSize = 10,
    this.indicatorSpacing = 4,
    this.flashingCircleDarkColor = const Color(0xFF939497),
    this.flashingCircleBrightColor = const Color(0xFFadacb0),
    this.padding = const EdgeInsets.only(left: 5, bottom: 12),
    this.customIndicator,
  });

  /// Used for giving typing indicator size.
  final double indicatorSize;

  /// Used for giving spacing between indicator dots.
  final double indicatorSpacing;

  /// Used to give color of dark circle dots.
  final Color? flashingCircleDarkColor;

  /// Used to give color of light circle dots.
  final Color? flashingCircleBrightColor;

  /// Used for giving padding to typing indicator.
  final EdgeInsets padding;

  /// Used to provide custom indicator widget.
  final Widget? customIndicator;
}
