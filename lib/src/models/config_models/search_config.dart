import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../values/typedefs.dart';

/// Configuration class for the search text field in the chat list UI.
class SearchConfig {
  /// Creates a configuration object for the search text field in the chat list UI.
  const SearchConfig({
    this.searchTextFieldPadding,
    required this.textEditingController,
    this.textStyle,
    this.maxLines,
    this.minLines,
    this.textInputType,
    this.inputFormatters,
    this.enabled,
    this.textCapitalization,
    this.hintText,
    this.hintStyle,
    this.contentPadding,
    this.textFieldBackgroundColor,
    this.borderRadius,
    this.border,
    this.prefixIcon,
    this.suffixIcon,
    this.onSearch,
  });

  /// Padding for the search text field in the chat list.
  final EdgeInsets? searchTextFieldPadding;

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
  final TextCapitalization? textCapitalization;

  /// Hint text for the search text field.
  final String? hintText;

  /// Style for the hint text in the search text field.
  final TextStyle? hintStyle;

  /// Padding for the content of the search text field.
  final EdgeInsets? contentPadding;

  /// Background color for the search text field.
  final Color? textFieldBackgroundColor;

  /// Border radius for the search text field.
  final BorderRadius? borderRadius;

  /// Border for the search text field.
  final InputBorder? border;

  /// Prefix icon for the search text field.
  final Widget? prefixIcon;

  /// Suffix icon for the search text field.
  final Widget? suffixIcon;

  /// Callback function that is called when the search text changes.
  final SearchUser onSearch;
}
