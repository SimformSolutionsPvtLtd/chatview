import 'package:flutter/material.dart';

import '../../../values/typedefs.dart';

/// Configuration for the chat list type indicator.
/// Controls appearance and behavior of the indicator shown in chat list tiles.
class TypingStatusConfig {
  /// Creates a [TypingStatusConfig].
  ///
  /// Configuration options for the chat view list type indicator:
  ///
  /// - [suffix]: Appends a string to the indicator text.
  /// Default is `null`.
  /// - [maxLines]: Limits the number of lines for the indicator text.
  /// Default is `1`.
  /// - [showUserNames]: Toggles the display of user names in the indicator.
  /// Default is `false`.
  /// - [textStyle]: Customizes the style of the indicator text.
  /// - [overflow]: Sets the text overflow behavior.
  /// Default is `TextOverflow.ellipsis`.
  /// - [prefix]: Prepends a string to the indicator text.
  /// Default is `null`.
  /// - [textBuilder]: Allows custom building of the indicator text.
  /// Default is `null`.
  /// - [widgetBuilder]: Allows custom building of the indicator widget.
  /// Default is `null`.
  const TypingStatusConfig({
    this.suffix = '...',
    this.maxLines = 1,
    this.showUserNames = false,
    this.textStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
    ),
    this.overflow = TextOverflow.ellipsis,
    this.prefix,
    this.textBuilder,
    this.widgetBuilder,
  });

  /// Optional text appended after the typing indicator.
  ///
  /// The main indicator text comes from locale `typing`.
  ///
  /// Example:
  /// - If `suffix = '...'`,
  ///   ➜ Display: `'typing...'`
  /// - If `suffix = null`,
  ///   ➜ Display: `'typing'`
  final String? suffix;

  /// Whether to show user names in the indicator.
  ///
  /// If `true`, the indicator will include user names.
  /// Example:
  /// - If `showUserNames = true` and there are two users typing,
  ///   ➜ Display: `'ChatView & Simform are typing...'`
  /// - If `showUserNames = false`,
  ///   ➜ Display: `'ChatView & 1 other is typing...'`
  final bool showUserNames;

  /// Optional text prepended before the typing indicator.
  ///
  /// The main indicator text comes from locale `typing`.
  ///
  /// Example:
  /// - If `prefix = 'User'`,
  ///  ➜ Display: `'User typing...'`
  /// - If `prefix = null`,
  ///  ➜ Display: `'typing...'`
  final String? prefix;

  /// Style for the indicator text.
  final TextStyle? textStyle;

  /// Maximum number of lines for the indicator text.
  final int? maxLines;

  /// Overflow behavior for the indicator text.
  final TextOverflow? overflow;

  /// Custom builder for indicator text.
  final ChatViewListTextBuilder? textBuilder;

  /// Custom builder for indicator widget.
  final ChatViewListWidgetBuilder? widgetBuilder;
}
