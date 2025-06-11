import 'package:flutter/material.dart';

/// Configuration class for the load more chat list widget.
class LoadMoreChatListConfig {
  /// Creates a configuration object for the load more chat list widget.
  const LoadMoreChatListConfig({
    this.padding,
    this.color,
  });

  /// Padding for the load more widget.
  final EdgeInsets? padding;

  /// Color for the load more widget.
  final Color? color;
}
