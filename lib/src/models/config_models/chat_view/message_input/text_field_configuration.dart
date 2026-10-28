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
import 'package:flutter/services.dart';

import '../../../../values/typedefs.dart';

class TextFieldConfiguration {
  const TextFieldConfiguration({
    this.enabled = true,
    this.hideLeadingActionsOnType = true,
    this.compositionThresholdTime = const Duration(seconds: 1),
    this.contentPadding,
    this.maxLines,
    this.borderRadius,
    this.hintText,
    this.hintStyle,
    this.textStyle,
    this.padding,
    this.margin,
    this.minLines,
    this.textInputType,
    this.onMessageTyping,
    this.inputFormatters,
    this.textCapitalization,
    this.height,
    this.hintMaxLines,
    this.trailingActions,
    this.leadingActions,
  });

  /// Used to give max lines in text field.
  final int? maxLines;

  /// Used to give min lines in text field.
  final int? minLines;

  /// Used to give padding in text field.
  final EdgeInsetsGeometry? padding;

  /// Used to give margin in text field.
  final EdgeInsetsGeometry? margin;

  /// Used to give hint text in text field.
  final String? hintText;

  /// Used to give text style of hint text in text field.
  final TextStyle? hintStyle;

  /// Used to give text style of actual text in text field.
  final TextStyle? textStyle;

  /// Used to give border radius in text field.
  final BorderRadius? borderRadius;

  /// Used to give content padding in text field.
  final EdgeInsetsGeometry? contentPadding;

  /// Used to give text input type of text field.
  final TextInputType? textInputType;

  /// Used to give list of input formatters for text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Used to give textCapitalization enums to text field.
  final TextCapitalization? textCapitalization;

  /// Callback when a user starts/stops typing a message by [TypeWriterStatus]
  final ValueSetter<TypeWriterStatus>? onMessageTyping;

  /// After typing stopped, the threshold time after which the composing
  /// status to be changed to `TypeWriterStatus.composed`.
  /// Default is 1 second.
  final Duration compositionThresholdTime;

  /// Used for enable or disable the chat text field.
  /// `false` also will disable the buttons for send images, record audio or take picture.
  /// Default is `true`.
  final bool enabled;

  /// Used to give height of text field.
  final double? height;

  /// List of widgets to be shown as trailing action widget in text field.
  final TextFieldActionWidgetBuilder? trailingActions;

  /// List of widgets to be shown as leading action widget in text field.
  final TextFieldActionWidgetBuilder? leadingActions;

  /// The maximum number of lines the [hintText] can occupy.
  ///
  /// Default is `1`.
  final int? hintMaxLines;

  /// Whether to hide leading action buttons when user starts typing.
  /// - `true` to hide leading action buttons when user starts typing.
  /// - `false` to always show leading action buttons.
  ///
  /// Default is `true`.
  final bool hideLeadingActionsOnType;
}
