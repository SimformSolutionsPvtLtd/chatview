import 'dart:ui';

import '../chat_view_state_widget_config.dart';

abstract base class StateConfigBase {
  const StateConfigBase({
    required this.errorWidgetConfig,
    required this.loadingWidgetConfig,
    this.onReloadButtonTap,
  });

  /// Provides configuration of error state's widget.
  final ChatViewStateWidgetConfiguration errorWidgetConfig;

  /// Provides configuration of loading state's widget.
  final ChatViewStateWidgetConfiguration loadingWidgetConfig;

  /// Provides callback when user taps on reload button.
  final VoidCallback? onReloadButtonTap;
}
