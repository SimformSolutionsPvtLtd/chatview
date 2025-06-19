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

class ChatViewStateConfiguration {
  const ChatViewStateConfiguration({
    this.errorWidgetConfig = const ChatViewStateWidgetConfiguration(),
    this.noMessageWidgetConfig = const ChatViewStateWidgetConfiguration(),
    this.loadingWidgetConfig = const ChatViewStateWidgetConfiguration(),
    this.onReloadButtonTap,
  });

  /// Provides configuration of error state's widget.
  final ChatViewStateWidgetConfiguration? errorWidgetConfig;

  /// Provides configuration of no message state's widget.
  final ChatViewStateWidgetConfiguration? noMessageWidgetConfig;

  /// Provides configuration of loading state's widget.
  final ChatViewStateWidgetConfiguration? loadingWidgetConfig;

  /// Provides callback when user taps on reload button.
  final VoidCallback? onReloadButtonTap;
}

class ChatViewStateWidgetConfiguration {
  const ChatViewStateWidgetConfiguration({
    this.widget,
    this.title,
    this.titleTextStyle,
    this.imageWidget,
    this.subTitle,
    this.subTitleTextStyle,
    this.loadingIndicatorColor,
    this.reloadButton,
    this.showDefaultReloadButton = true,
    this.reloadButtonColor,
  });

  /// Used to give title of state.
  final String? title;

  /// Used to give sub-title of state.
  final String? subTitle;

  /// Used to give text style of title in any state.
  final TextStyle? titleTextStyle;

  /// Used to give text style of sub-title in any state.
  final TextStyle? subTitleTextStyle;

  /// Provides parameter to pass image widget in any state.
  final Widget? imageWidget;

  /// Used to give color of loading indicator.
  final Color? loadingIndicatorColor;

  /// Provides parameter to pass custom reload button in any state.
  final Widget? reloadButton;

  /// Used to show reload button.
  final bool showDefaultReloadButton;

  /// Used to give color of reload button.
  final Color? reloadButtonColor;

  /// Gives ability to pass custom widget in any state.
  final Widget? widget;
}
