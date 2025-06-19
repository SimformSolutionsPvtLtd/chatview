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
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

class ImageMessageConfiguration {
  const ImageMessageConfiguration({
    this.hideShareIcon = false,
    this.shareIconConfig,
    this.onTap,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  /// Provides configuration of share button while image message is appeared.
  final ShareIconConfiguration? shareIconConfig;

  /// Hide share icon in image view.
  final bool hideShareIcon;

  /// Provides callback when user taps on image message.
  final ValueSetter<Message>? onTap;

  /// Used for giving height of image message.
  final double? height;

  /// Used for giving width of image message.
  final double? width;

  /// Used for giving padding of image message.
  final EdgeInsetsGeometry? padding;

  /// Used for giving margin of image message.
  final EdgeInsetsGeometry? margin;

  /// Used for giving border radius of image message.
  final BorderRadius? borderRadius;
}

class ShareIconConfiguration {
  ShareIconConfiguration({
    this.onPressed,
    this.icon,
    this.defaultIconBackgroundColor,
    this.padding,
    this.margin,
    this.defaultIconColor,
  });

  /// Provides callback when user press on share button.
  final ValueSetter<String>? onPressed; // Returns imageURL

  /// Provides ability to add custom share icon.
  final Widget? icon;

  /// Used to give share icon background color.
  final Color? defaultIconBackgroundColor;

  /// Used to give share icon padding.
  final EdgeInsetsGeometry? padding;

  /// Used to give share icon margin.
  final EdgeInsetsGeometry? margin;

  /// Used to give share icon color.
  final Color? defaultIconColor;
}
