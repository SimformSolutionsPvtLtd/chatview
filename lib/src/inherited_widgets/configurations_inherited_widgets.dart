import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class ConfigurationsInheritedWidget extends InheritedWidget {
  const ConfigurationsInheritedWidget({
    Key? key,
    required Widget child,
    required this.chatBackgroundConfig,
    this.reactionPopupConfig,
    this.messageConfig,
    this.chatBubbleConfig,
    this.profileCircleConfig,
    this.swipeToReplyConfig,
    this.repliedMessageConfig,
    this.typeIndicatorConfig,
    this.replyPopupConfig,
    this.emojiPickerSheetConfig,
    this.scrollToBottomButtonConfig,
  }) : super(key: key, child: child);

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
  final TypeIndicatorConfiguration? typeIndicatorConfig;

  /// Provides configuration for reply snack bar's appearance and options.
  final ReplyPopupConfiguration? replyPopupConfig;

  /// Configuration for emoji picker sheet
  final Config? emojiPickerSheetConfig;

  /// Provides a configuration for scroll to bottom button config
  final ScrollToBottomButtonConfig? scrollToBottomButtonConfig;

  static ConfigurationsInheritedWidget? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ConfigurationsInheritedWidget>();

  @override
  bool updateShouldNotify(covariant ConfigurationsInheritedWidget oldWidget) =>
      oldWidget != this;
}
