import 'package:flutter/material.dart';

import '../../values/typedefs.dart';

/// Configuration class for the user widget in the chat list UI.
class ChatViewListUserConfig {
  /// Creates a configuration object for the user widget in the chat list UI.
  const ChatViewListUserConfig({
    this.userNameTextStyle,
    this.lastMessageTextStyle,
    this.lastMessageTimeTextStyle,
    this.unreadCountTextStyle,
    this.userNameTextOverflow,
    this.lastMessageTextOverflow,
    this.userNameAndLastMessagePadding,
    this.onTap,
    this.onLongPress,
    this.userNameMaxLines,
    this.lastMessageMaxLines,
  });

  /// Text styles for various text elements in the user widget.
  final TextStyle? userNameTextStyle;

  /// Text styles for the last message text in the user widget.
  final TextStyle? lastMessageTextStyle;

  /// Text styles for the last message time in the user widget.
  final TextStyle? lastMessageTimeTextStyle;

  /// Text styles for the unread count in the user widget.
  final TextStyle? unreadCountTextStyle;

  /// Text overflow behavior for the user name text.
  final TextOverflow? userNameTextOverflow;

  /// Text overflow behavior for the last message text.
  final TextOverflow? lastMessageTextOverflow;

  /// Padding between the profile widget and the user name text.
  final EdgeInsets? userNameAndLastMessagePadding;

  /// Callback function that is called when a user taps on a chat item.
  final NullableChatViewListUserCallback onTap;

  /// Callback function that is called when the user long presses on a chat item.
  final NullableChatViewListUserCallback onLongPress;

  /// Maximum number of lines for the user name text.
  final int? userNameMaxLines;

  /// Maximum number of lines for the last message text.
  final int? lastMessageMaxLines;
}
