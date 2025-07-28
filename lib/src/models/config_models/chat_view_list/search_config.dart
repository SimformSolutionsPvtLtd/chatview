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
import 'package:flutter/services.dart';

import '../../../utils/constants/constants.dart';
import '../../../values/typedefs.dart';

/// Configuration class for the search text field in the chat list UI.
class ChatViewListSearchConfig {
  /// Creates a configuration object for the search text field in
  /// the chat list UI.
  const ChatViewListSearchConfig({
    required this.textEditingController,
    this.padding = const EdgeInsets.all(10),
    this.prefixIcon = const Icon(Icons.search),
    this.textFieldBackgroundColor = Colors.white,
    this.textInputAction = TextInputAction.search,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(textFieldBorderRadius),
    ),
    this.onTapOutside,
    this.textStyle,
    this.maxLines,
    this.minLines,
    this.textInputType,
    this.inputFormatters,
    this.enabled,
    this.hintText,
    this.hintStyle,
    this.border,
    this.suffixIcon,
    this.onSearch,
    this.debounceDuration,
    this.decoration,
    this.maxLength,
  });

  /// Padding for the search text field in the chat list.
  ///
  /// Defaults to `EdgeInsets.all(10)`.
  final EdgeInsets padding;

  /// Text editing controller for the search text field.
  final TextEditingController textEditingController;

  /// Style for the text in the search text field.
  final TextStyle? textStyle;

  /// Maximum number of lines for the search text field.
  final int? maxLines;

  /// Minimum number of lines for the search text field.
  final int? minLines;

  /// Type of input for the search text field.
  final TextInputType? textInputType;

  /// List of input formatters for the search text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the search text field is enabled.
  final bool? enabled;

  /// Text capitalization for the search text field.
  ///
  /// Defaults to `TextCapitalization.none`.
  final TextCapitalization textCapitalization;

  /// Hint text for the search text field.
  final String? hintText;

  /// Style for the hint text in the search text field.
  final TextStyle? hintStyle;

  /// Padding for the content of the search text field.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 6)`.
  final EdgeInsets? contentPadding;

  /// Background color for the search text field.
  ///
  /// Defaults to `Colors.white`.
  final Color? textFieldBackgroundColor;

  /// Border radius for the search text field.
  ///
  /// Defaults to circular border with radius of `10`.
  final BorderRadius borderRadius;

  /// Border for the search text field.
  final InputBorder? border;

  /// Prefix icon for the search text field.
  ///
  /// Defaults to an search icon `Icons.search`.
  final Widget? prefixIcon;

  /// Suffix icon for the search text field.
  final Widget? suffixIcon;

  /// Callback function that is called when the search text changes.
  final SearchUserCallback? onSearch;

  /// Duration to debounce the search callback.
  final Duration? debounceDuration;

  /// Decoration for the search text field.
  final InputDecoration? decoration;

  /// Callback function that is called when the user taps outside the search
  /// text field.
  final TapRegionCallback? onTapOutside;

  /// Action to be performed when the user submits the text in the search
  /// text field.
  ///
  /// Defaults to `TextInputAction.search`.
  final TextInputAction? textInputAction;

  /// Maximum length of the text in the search text field.
  final int? maxLength;
}
