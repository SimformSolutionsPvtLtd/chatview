import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../models/config_models/feature_active_config.dart';
import '../models/config_models/profile_circle_configuration.dart';
import 'reaction_popup.dart';

/// This widget for alternative of excessive amount of passing arguments
/// over widgets.
class ChatViewInheritedWidget extends InheritedWidget {
  ChatViewInheritedWidget({
    Key? key,
    required Widget child,
    required this.featureActiveConfig,
    required this.chatController,
    required this.chatTextFieldViewKey,
    this.profileCircleConfiguration,
  }) : super(key: key, child: child);
  final FeatureActiveConfig featureActiveConfig;
  final ProfileCircleConfiguration? profileCircleConfiguration;
  final ChatController chatController;
  final GlobalKey chatTextFieldViewKey;
  final ValueNotifier<bool> showPopUp = ValueNotifier(false);
  final ValueNotifier<double> chatTextFieldHeight = ValueNotifier(0.0);
  final GlobalKey<ReactionPopupState> reactionPopupKey = GlobalKey();

  static ChatViewInheritedWidget? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatViewInheritedWidget>();

  @override
  bool updateShouldNotify(covariant ChatViewInheritedWidget oldWidget) =>
      oldWidget.featureActiveConfig != featureActiveConfig;
}
