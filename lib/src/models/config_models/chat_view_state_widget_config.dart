import 'package:flutter/material.dart';

import '../../utils/constants/constants.dart';

class ChatViewStateWidgetConfiguration {
  const ChatViewStateWidgetConfiguration({
    this.showDefaultReloadButton = true,
    this.reloadButtonColor = primaryColor,
    this.loadingIndicatorSize = loadMoreCircularProgressIndicatorSize,
    this.titleTextStyle = const TextStyle(fontSize: 22),
    this.widget,
    this.title,
    this.imageWidget,
    this.subTitle,
    this.subTitleTextStyle,
    this.loadingIndicatorColor,
    this.reloadButton,
  });

  /// Used to give title of state.
  final String? title;

  /// Used to give sub-title of state.
  final String? subTitle;

  /// Used to give text style of title in any state.
  ///
  /// Defaults to `TextStyle(fontSize: 22)`.
  final TextStyle? titleTextStyle;

  /// Used to give text style of sub-title in any state.
  final TextStyle? subTitleTextStyle;

  /// Provides parameter to pass image widget in any state.
  final Widget? imageWidget;

  /// Used to give color of loading indicator.
  final Color? loadingIndicatorColor;

  /// Used to give size of loading indicator.
  ///
  /// Defaults to `36.0`.
  final double loadingIndicatorSize;

  /// Provides parameter to pass custom reload button in any state.
  final Widget? reloadButton;

  /// Used to show reload button.
  final bool showDefaultReloadButton;

  /// Used to give color of reload button.
  ///
  /// Defaults to chatview `primaryColor`.
  final Color? reloadButtonColor;

  /// Gives ability to pass custom widget in any state.
  final Widget? widget;
}
