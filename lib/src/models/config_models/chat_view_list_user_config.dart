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

import '../../utils/constants/constants.dart';
import '../../values/typedefs.dart';
import '../chat_view_list_tile.dart';

/// Configuration class for the user widget in the chat list UI.
class ChatViewListTileConfig {
  /// Creates a configuration object for the user widget in the chat list UI.
  const ChatViewListTileConfig({
    this.userNameTextStyle,
    this.lastMessageTextStyle,
    this.lastMessageTimeTextStyle,
    this.userNameTextOverflow,
    this.lastMessageTextOverflow,
    this.userNameAndLastMessagePadding,
    this.onTap,
    this.onLongPress,
    this.userNameMaxLines,
    this.lastMessageMaxLines,
    this.circleAvatarRadius = userAvatarRadius,
    this.backgroundColor,
    this.onBackgroundImageError,
    this.onProfileTap,
    this.showOnlineStatus = true,
  });

  /// Text styles for various text elements in the user widget.
  final TextStyle? userNameTextStyle;

  /// Text styles for the last message text in the user widget.
  final TextStyle? lastMessageTextStyle;

  /// Text styles for the last message time in the user widget.
  final TextStyle? lastMessageTimeTextStyle;

  /// Text overflow behavior for the user name text.
  final TextOverflow? userNameTextOverflow;

  /// Text overflow behavior for the last message text.
  final TextOverflow? lastMessageTextOverflow;

  /// Padding between the profile widget and the user name text.
  final EdgeInsets? userNameAndLastMessagePadding;

  /// Callback function that is called when a user taps on a chat item.
  final ValueSetter<ChatViewListModel>? onTap;

  /// Callback function that is called when the user long presses on a chat item.
  final ValueSetter<ChatViewListModel>? onLongPress;

  /// Maximum number of lines for the user name text.
  final int? userNameMaxLines;

  /// Maximum number of lines for the last message text.
  final int? lastMessageMaxLines;

  /// Radius for the circle avatar in the profile widget.
  final double circleAvatarRadius;

  /// Background color for the profile widget .
  final Color? backgroundColor;

  /// Callback function that is called when there is an error loading the background image.
  final BackgroundImageLoadError onBackgroundImageError;

  /// Callback function that is called when the profile widget is tapped.
  final ValueSetter<ChatViewListModel>? onProfileTap;

  /// Whether to show the online status of the user in the chat list.
  final bool showOnlineStatus;
}
