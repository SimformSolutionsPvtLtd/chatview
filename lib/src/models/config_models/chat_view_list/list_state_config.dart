import '../base/state_config_base.dart';
import '../chat_view_state_widget_config.dart';

final class ListStateConfig extends StateConfigBase {
  const ListStateConfig({
    this.noChatsWidgetConfig = const ChatViewStateWidgetConfiguration(),
    this.noSearchChatsWidgetConfig = const ChatViewStateWidgetConfiguration(),
    super.errorWidgetConfig = const ChatViewStateWidgetConfiguration(),
    super.loadingWidgetConfig = const ChatViewStateWidgetConfiguration(),
    super.onReloadButtonTap,
  });

  /// Provides configuration of error state's widget.
  final ChatViewStateWidgetConfiguration noSearchChatsWidgetConfig;

  /// Provides configuration of no message state's widget.
  final ChatViewStateWidgetConfiguration noChatsWidgetConfig;
}
