import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/cupertino.dart';

import '../../../values/typedefs.dart';

class ChatMenuConfig {
  const ChatMenuConfig({
    this.enabled = true,
    this.actions,
    this.textStyle,
    this.menuBuilder,
    this.muteStatusCallback,
    this.pinStatusCallback,
    this.muteStatusTrailingIcon,
    this.pinStatusTrailingIcon,
  });

  /// Whether the context menu is enabled.
  ///
  /// Defaults to `true`.
  ///
  /// if set to `false`, the default or custom context menu
  /// will not be shown.
  final bool enabled;

  /// Custom text style for the menu items.
  final TextStyle? textStyle;

  /// Custom actions to be added to the context menu.
  ///
  /// by default, it will add the mute and pin actions
  /// if callbacks are provided.
  final MenuActionBuilder? actions;

  /// Custom menu builder to create the context menu.
  final MenuBuilderCallback? menuBuilder;

  /// Callback for mute status changes.
  ///
  /// In this callback, new mute status along with the chat
  /// is provided.
  final ChatStatusCallback<MuteStatus>? muteStatusCallback;

  /// Callback for pin status changes.
  final ChatStatusCallback<PinStatus>? pinStatusCallback;

  /// Custom trailing icon for mute status menu item.
  final StatusTrailingIcon<MuteStatus>? muteStatusTrailingIcon;

  /// Custom trailing icon for pin status menu item.
  final StatusTrailingIcon<PinStatus>? pinStatusTrailingIcon;
}
