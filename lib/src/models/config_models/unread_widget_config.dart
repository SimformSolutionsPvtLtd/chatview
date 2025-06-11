import 'package:flutter/material.dart';

import '../../values/enumeration.dart';

/// Configuration class for the unread message widget in the chat list UI.
class UnReadWidgetConfig {
  /// Creates a configuration object for the unread message widget in the chat list UI.
  const UnReadWidgetConfig({
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.height,
    this.width,
    this.decoration,
    this.unReadCountView = UnReadCountView.dot,
  });

  /// Background color for the unread message widget.
  final Color? backgroundColor;

  /// Text color for the unread message widget.
  final Color? textColor;

  /// Font size for the unread message text.
  final double? fontSize;

  /// Height for the unread message widget.
  final double? height;

  /// Width for the unread message widget.
  final double? width;

  /// Decoration for the unread message widget.
  final BoxDecoration? decoration;

  /// View style for the unread count.
  final UnReadCountView unReadCountView;
}
