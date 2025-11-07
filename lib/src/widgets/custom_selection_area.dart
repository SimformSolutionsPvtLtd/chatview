import 'package:chatview/src/models/config_models/text_selection_config.dart';
import 'package:flutter/material.dart';

/// A convenience wrapper around [SelectionArea] that lets you locally
/// customize selection highlight, handle, and colors
/// without changing the global app [Theme].

class CustomSelectionArea extends StatelessWidget {
  const CustomSelectionArea({
    required this.child,
    this.config,
    super.key,
  });

  /// The subtree whose text becomes selectable.
  final Widget child;

  /// Configuration for text selection behavior and appearance.
  final TextSelectionConfig? config;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(textSelectionTheme: config?.themeData),
      child: SelectionArea(
        focusNode: config?.focusNode,
        selectionControls: config?.selectionControls,
        contextMenuBuilder:
            config?.contextMenuBuilder ?? _defaultContextMenuBuilder,
        onSelectionChanged: config?.onSelectionChanged,
        magnifierConfiguration: config?.magnifierConfiguration,
        child: child,
      ),
    );
  }

  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    SelectableRegionState selectableRegionState,
  ) {
    return AdaptiveTextSelectionToolbar.selectableRegion(
      selectableRegionState: selectableRegionState,
    );
  }
}
