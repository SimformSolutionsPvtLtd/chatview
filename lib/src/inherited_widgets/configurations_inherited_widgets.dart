import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class ConfigurationsInheritedWidget extends InheritedWidget {
  const ConfigurationsInheritedWidget({
    required super.child,
    required this.chatBackgroundConfig,
    super.key,
    this.typeIndicatorConfig = const TypeIndicatorConfiguration(),
    this.reactionPopupConfig,
    this.messageConfig,
    this.chatBubbleConfig,
    this.profileCircleConfig,
    this.swipeToReplyConfig,
    this.repliedMessageConfig,
    this.replyPopupConfig,
    this.emojiPickerSheetConfig,
    this.scrollToBottomButtonConfig,
  });

  /// Provides configuration for background of chat.
  final ChatBackgroundConfiguration chatBackgroundConfig;

  /// Provides configuration for reaction pop up appearance.
  final ReactionPopupConfiguration? reactionPopupConfig;

  /// Provides configuration for customisation of different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Provides configuration of chat bubble's appearance.
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Provides configuration for profile circle avatar of user.
  final ProfileCircleConfiguration? profileCircleConfig;

  /// Provides configuration for when user swipe to chat bubble.
  final SwipeToReplyConfiguration? swipeToReplyConfig;

  /// Provides configuration for replied message view which is located upon chat
  /// bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides configuration of typing indicator's appearance.
  final TypeIndicatorConfiguration typeIndicatorConfig;

  /// Provides configuration for reply snack bar's appearance and options.
  final ReplyPopupConfiguration? replyPopupConfig;

  /// Configuration for emoji picker sheet
  final Config? emojiPickerSheetConfig;

  /// Provides a configuration for scroll to bottom button config
  final ScrollToBottomButtonConfig? scrollToBottomButtonConfig;

  static ConfigurationsInheritedWidget? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ConfigurationsInheritedWidget>();

  // Identity, not `==`: the config models have no `==`, and a host that
  // rebuilds with the same instances must not wake every dependent.
  @override
  bool updateShouldNotify(covariant ConfigurationsInheritedWidget oldWidget) {
    return !identical(oldWidget.chatBackgroundConfig, chatBackgroundConfig) ||
        !identical(oldWidget.reactionPopupConfig, reactionPopupConfig) ||
        !identical(oldWidget.messageConfig, messageConfig) ||
        !identical(oldWidget.chatBubbleConfig, chatBubbleConfig) ||
        !identical(oldWidget.profileCircleConfig, profileCircleConfig) ||
        !identical(oldWidget.swipeToReplyConfig, swipeToReplyConfig) ||
        !identical(oldWidget.repliedMessageConfig, repliedMessageConfig) ||
        !identical(oldWidget.typeIndicatorConfig, typeIndicatorConfig) ||
        !identical(oldWidget.replyPopupConfig, replyPopupConfig) ||
        !identical(oldWidget.emojiPickerSheetConfig, emojiPickerSheetConfig) ||
        !identical(
          oldWidget.scrollToBottomButtonConfig,
          scrollToBottomButtonConfig,
        );
  }
}
