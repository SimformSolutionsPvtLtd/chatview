import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TextSelectionConfig {
  const TextSelectionConfig({
    this.selectionControls,
    this.focusNode,
    this.onSelectionChanged,
    this.contextMenuBuilder,
    this.magnifierConfiguration,
    this.themeData,
  });

  /// The delegate to build the selection handles and toolbar.
  ///
  /// If it is null, the platform specific selection control is used.
  final TextSelectionControls? selectionControls;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// The configuration for the magnifier in the selection region.
  ///
  /// By default, builds a [CupertinoTextMagnifier] on iOS and [TextMagnifier]
  /// on Android, and builds nothing on all other platforms. To suppress the
  /// magnifier, consider passing [TextMagnifierConfiguration.disabled].
  ///
  /// {@macro flutter.widgets.magnifier.intro}
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Called when the selected content changes.
  final ValueChanged<SelectedContent?>? onSelectionChanged;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, will build a default menu based on the ambient
  /// [ThemeData.platform].
  ///
  /// {@tool dartpad}
  /// This example shows how to build a custom context menu for any selected
  /// content in a SelectionArea.
  ///
  /// ** See code in examples/api/lib/material/context_menu/selectable_region_toolbar_builder.0.dart **
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [AdaptiveTextSelectionToolbar], which is built by default.
  final SelectableRegionContextMenuBuilder? contextMenuBuilder;

  /// Theme data for text selection.
  ///
  /// If null, defaults to the theme's `TextSelectionThemeData`.
  final TextSelectionThemeData? themeData;
}
