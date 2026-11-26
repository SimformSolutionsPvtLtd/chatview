import 'package:flutter/material.dart';

import '../../../models/config_models/chat_view/message/text_selection_config.dart';

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
    final area = SelectionArea(
      focusNode: config?.focusNode,
      selectionControls: config?.selectionControls,
      contextMenuBuilder:
          config?.contextMenuBuilder ?? _defaultContextMenuBuilder,
      onSelectionChanged: config?.onSelectionChanged,
      magnifierConfiguration: config?.magnifierConfiguration,
      child: child,
    );
    final themeData = config?.themeData;
    return themeData == null
        ? area
        : Theme(
            data: Theme.of(context).copyWith(textSelectionTheme: themeData),
            child: area,
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
