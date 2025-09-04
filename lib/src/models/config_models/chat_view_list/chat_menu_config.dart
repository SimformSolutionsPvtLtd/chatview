import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/cupertino.dart';

import '../../../values/typedefs.dart';

class ChatMenuConfig {
  const ChatMenuConfig({
    this.enabled = true,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.highlightColor = const Color(0x1AEE5366),
    this.callbackDelayDuration = const Duration(milliseconds: 800),
    this.actions,
    this.textStyle,
    this.builder,
    this.muteStatusCallback,
    this.pinStatusCallback,
    this.deleteCallback,
    this.muteStatusIcon,
    this.pinStatusIcon,
    this.deleteIcon,
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

  /// Maximum number of lines for the menu item text.
  ///
  /// Defaults to `1`.
  final int? maxLines;

  /// Overflow behavior for the menu item text.
  ///
  /// Defaults to `TextOverflow.ellipsis`.
  final TextOverflow? overflow;

  /// Custom actions to be added to the context menu.
  ///
  /// by default, it will add the mute and pin actions
  /// if callbacks are provided.
  final MenuActionBuilder? actions;

  /// Custom menu builder to create the context menu.
  final MenuBuilderCallback? builder;

  /// Callback for mute status changes.
  ///
  /// In this callback, new mute status along with the chat
  /// is provided.
  final ChatStatusCallback<MuteStatus>? muteStatusCallback;

  /// Callback for pin status changes.
  ///
  /// In this callback, new pin status along with the chat
  /// is provided.
  final ChatStatusCallback<PinStatus>? pinStatusCallback;

  /// Callback for delete chat.
  ///
  /// In this callback, the chat to be deleted is provided.
  final DeleteChatCallback? deleteCallback;

  /// The delay duration before executing a callback after a UI action.
  ///
  /// For example, this can be used to wait for animations to complete
  /// (like menu expand/collapse) before running logic that updates
  /// the chat list or triggers another UI change.
  ///
  /// If null, no extra delay is applied.
  ///
  /// Defaults to `const Duration(milliseconds: 800)`.
  ///
  /// **Note** This delay is not applied on web and desktop platforms.
  final Duration? callbackDelayDuration;

  /// Custom icon for mute status menu item.
  ///
  /// Defaults to:
  /// {@macro chatview.extensions.MuteStatus.iconData}
  final StatusTrailingIcon<MuteStatus>? muteStatusIcon;

  /// Custom icon for pin status menu item.
  ///
  /// Defaults to:
  /// {@macro chatview.extensions.PinStatus.iconData}
  final StatusTrailingIcon<PinStatus>? pinStatusIcon;

  /// Custom icon for delete menu item.
  final IconData? deleteIcon;

  /// The highlight color for the menu item when pressed.
  ///
  /// Applicable only for web platform.
  final Color highlightColor;
}
