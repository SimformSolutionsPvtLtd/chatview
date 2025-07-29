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

// Different types Message of ChatView

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../utils/package_strings.dart';

enum ShowReceiptsIn { all, lastMessage }

enum SuggestionListAlignment {
  left(Alignment.bottomLeft),
  center(Alignment.bottomCenter),
  right(Alignment.bottomRight);

  const SuggestionListAlignment(this.alignment);

  final Alignment alignment;
}

extension ChatViewStateExtension on ChatViewState {
  bool get hasMessages => this == ChatViewState.hasMessages;

  bool get isLoading => this == ChatViewState.loading;

  bool get isError => this == ChatViewState.error;

  bool get noMessages => this == ChatViewState.noData;
}

enum GroupedListOrder { asc, desc }

extension GroupedListOrderExtension on GroupedListOrder {
  bool get isAsc => this == GroupedListOrder.asc;

  bool get isDesc => this == GroupedListOrder.desc;
}

enum ScrollButtonAlignment {
  left(Alignment.bottomLeft),
  center(Alignment.bottomCenter),
  right(Alignment.bottomRight);

  const ScrollButtonAlignment(this.alignment);

  final Alignment alignment;
}

enum SuggestionItemsType {
  scrollable,
  multiline;

  bool get isScrollType => this == SuggestionItemsType.scrollable;

  bool get isMultilineType => this == SuggestionItemsType.multiline;
}

/// Enum to distinguish between single user and group chat.
enum ChatType {
  /// Represents a single user chat.
  user,

  /// Represents a group chat.
  group;

  /// Returns true if the chat type is user.
  bool get isUser => this == user;

  /// Returns true if the chat type is group.
  bool get isGroup => this == group;
}

/// An enumeration of unread count styles.
enum UnreadCountStyle {
  /// Represents unread count as a dot.
  dot,

  /// Represents unread count as a number.
  count,

  /// Represents unread count as 99+ when the count exceeds 99.
  /// Otherwise, it will show the actual count.
  ninetyNinePlus,

  /// Represents no unread count.
  none;

  /// Returns true if the unread count style is dot.
  bool get isDot => this == dot;

  /// Returns true if the unread count style is count.
  bool get isCount => this == count;

  /// Returns true if the unread count style is ninety-nine plus.
  bool get isNinetyNinePlus => this == ninetyNinePlus;

  /// Returns true if the unread count style is none.
  bool get isNone => this == none;
}

/// An enumeration of user status.
enum UserActiveStatus {
  /// user is active
  online,

  /// user is inactive
  offline;

  /// is user inactive
  bool get isOnline => this == online;

  /// is user active
  bool get isOffline => this == offline;
}

/// An enumeration representing mute status options.
enum MuteStatus {
  /// The chat is muted.
  muted,

  /// The chat is not muted.
  unmute;

  /// Returns true if the chat is muted.
  bool get isMuted => this == muted;

  /// Returns true if the chat is unmuted.
  bool get isUnmute => this == unmute;

  String get menuName => switch (this) {
        muted => PackageStrings.currentLocale.mute,
        unmute => PackageStrings.currentLocale.unmute,
      };

  IconData get iconData => switch (this) {
        muted => Icons.notifications_off,
        unmute => Icons.notifications,
      };
}

/// An enumeration representing the status of a chat pinning operation.
enum PinStatus {
  /// The chat is pinned.
  pinned,

  /// The chat is unpinned.
  unpinned;

  /// Returns true if the chat is pinned.
  bool get isPinned => this == pinned;

  /// Returns true if the chat is unpinned.
  bool get isNone => this == unpinned;

  String get menuName => switch (this) {
        pinned => PackageStrings.currentLocale.pin,
        unpinned => PackageStrings.currentLocale.unpin,
      };

  IconData get iconData => switch (this) {
        pinned => Icons.push_pin,
        unpinned => Icons.push_pin_outlined,
      };
}
