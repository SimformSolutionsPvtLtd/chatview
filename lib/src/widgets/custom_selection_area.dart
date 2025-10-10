import 'package:flutter/material.dart';

/// A convenience wrapper around [SelectionArea] that lets you locally
/// customize selection highlight, handle, and colors
/// without changing the global app [Theme].

class CustomSelectionArea extends StatelessWidget {
  const CustomSelectionArea({
    super.key,
    required this.child,
    this.selectionColor,
    this.selectionHandleColor,
    this.selectionControls,
    this.cursorColor,
  });

  /// The subtree whose text becomes selectable.
  final Widget child;

  /// Color used to paint the selected text highlight background.
  final Color? selectionColor;

  /// Color for the drag handles. If null, falls back to theme.
  final Color? selectionHandleColor;

  /// Optional custom selection controls (toolbar / handles). If you just need
  /// color tweaks, you usually do not need to supply this.
  final TextSelectionControls? selectionControls;

  /// Cursor color for any text.
  final Color? cursorColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextSelectionTheme = theme.textSelectionTheme;

    final mergedTextSelectionTheme = baseTextSelectionTheme.copyWith(
      selectionColor: selectionColor ?? baseTextSelectionTheme.selectionColor,
      selectionHandleColor:
          selectionHandleColor ?? baseTextSelectionTheme.selectionHandleColor,
      cursorColor: cursorColor ?? baseTextSelectionTheme.cursorColor,
    );

    return Theme(
      data: theme.copyWith(textSelectionTheme: mergedTextSelectionTheme),
      child: SelectionArea(selectionControls: selectionControls, child: child),
    );
  }
}

class ColoredTextSelectionControls extends MaterialTextSelectionControls {
  ColoredTextSelectionControls(this.handleColor);

  /// Color for the drag handles.
  final Color handleColor;

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textHeight, [
    VoidCallback? onTap,
  ]) {
    final handle = super.buildHandle(context, type, textHeight, onTap);
    return IconTheme.merge(
      data: IconThemeData(color: handleColor),
      child: handle,
    );
  }
}
