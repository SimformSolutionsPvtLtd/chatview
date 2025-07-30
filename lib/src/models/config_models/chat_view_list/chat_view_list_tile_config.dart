/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:flutter/material.dart';

import '../../../values/typedefs.dart';
import '../../chat_view_list_item.dart';
import 'last_message_time_config.dart';
import 'unread_count_config.dart';
import 'user_active_status_config.dart';
import 'user_avatar_config.dart';

/// Configuration class for the user widget in the chat list UI.
class ChatViewListTileConfig {
  /// Creates a configuration object for the user widget in the chat list UI.
  const ChatViewListTileConfig({
    this.showOnlineStatus = true,
    this.timeConfig = const LastMessageTimeConfig(),
    this.userAvatarConfig = const UserAvatarConfig(),
    this.unreadCountConfig = const UnreadCountConfig(),
    this.userActiveStatusConfig = const UserActiveStatusConfig(),
    this.userNameMaxLines = 1,
    this.userNameTextOverflow = TextOverflow.ellipsis,
    this.lastMessageMaxLines = 1,
    this.lastMessageTextOverflow = TextOverflow.ellipsis,
    this.middleWidgetPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.padding = const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    this.userNameTextStyle,
    this.lastMessageTextStyle,
    this.onTap,
    this.onLongPress,
    this.customLastMessageListViewBuilder,
  });

  /// Padding around the widget in the chat list.
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: 6, horizontal: 8)`.
  final EdgeInsets padding;

  /// Text styles for various text elements in the user widget.
  final TextStyle? userNameTextStyle;

  /// Text overflow behavior for the user name text.
  ///
  /// Defaults to `TextOverflow.ellipsis`.
  final TextOverflow? userNameTextOverflow;

  /// Maximum number of lines for the user name text.
  ///
  /// Defaults to `1`.
  final int? userNameMaxLines;

  /// Text styles for the last message text in the user widget.
  final TextStyle? lastMessageTextStyle;

  /// Text overflow behavior for the last message text.
  ///
  /// Defaults to `TextOverflow.ellipsis`.
  final TextOverflow? lastMessageTextOverflow;

  /// Maximum number of lines for the last message text.
  ///
  /// Defaults to `1`.
  final int? lastMessageMaxLines;

  /// Configuration for the time display in the chat list.
  final LastMessageTimeConfig timeConfig;

  /// Configuration for the unread count widget in the chat list.
  final UnreadCountConfig unreadCountConfig;

  /// Padding between the profile widget and the last message time.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12)`.
  final EdgeInsets middleWidgetPadding;

  /// Callback function that is called when a user taps on a chat item.
  final ValueSetter<ChatViewListItem>? onTap;

  /// Callback function that is called when the user long presses on a chat item.
  final ValueSetter<ChatViewListItem>? onLongPress;

  /// Configuration for the user avatar in the chat list.
  final UserAvatarConfig userAvatarConfig;

  /// Configuration for the online status of the user in the chat list.
  final UserActiveStatusConfig userActiveStatusConfig;

  /// Whether to show the online status of the user in the chat list.
  final bool showOnlineStatus;

  /// Custom builder for the last message view in the chat list.
  final CustomLastMessageListViewBuilder? customLastMessageListViewBuilder;
}
