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

import '../extensions/extensions.dart';
import '../models/models.dart';
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

  /// Toggles the mute status.
  /// If the current status is muted, it returns unmute.
  /// If the current status is unmute, it returns muted.
  MuteStatus get toggle {
    return switch (this) {
      muted => unmute,
      unmute => muted,
    };
  }

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

  /// Toggles the pin status.
  /// If the current status is pinned, it returns unpinned.
  /// If the current status is unpinned, it returns pinned.
  PinStatus get toggle {
    return switch (this) {
      pinned => unpinned,
      unpinned => pinned,
    };
  }

  String get menuName => switch (this) {
        pinned => PackageStrings.currentLocale.pin,
        unpinned => PackageStrings.currentLocale.unpin,
      };

  IconData get iconData => switch (this) {
        pinned => Icons.push_pin,
        unpinned => Icons.push_pin_outlined,
      };
}

/// Enum for different chat list sorting options (for internal use only)
enum ChatViewListSortBy {
  /// No sorting applied.
  none,

  /// Pin chats first (sorted by pin time), then unpinned by message date/time
  pinFirstByPinTime;

  int sort(ChatViewListItem chat1, ChatViewListItem chat2) {
    switch (this) {
      case none:
        return 0;
      case pinFirstByPinTime:
        final isChatAPinned = chat1.settings.pinStatus.isPinned;
        final isChatBPinned = chat2.settings.pinStatus.isPinned;

        // 1. Pinned chats first
        if (isChatAPinned && !isChatBPinned) return -1;
        if (!isChatAPinned && isChatBPinned) return 1;

        // 2. Sort pinned chats by pinTime descending (latest first)
        if (isChatAPinned && isChatBPinned) {
          final pinTimeA = chat1.settings.pinTime;
          final pinTimeB = chat2.settings.pinTime;
          if (pinTimeA != null && pinTimeB != null) {
            return pinTimeB.compareTo(pinTimeA);
          }
          // If one has null pinTime, treat it as older
          if (pinTimeA == null && pinTimeB != null) return 1;
          if (pinTimeA != null && pinTimeB == null) return -1;
        }

        // 3. Sort unpinned chats by message date/time (newest first)
        if (!isChatAPinned && !isChatBPinned) {
          final chatBCreateAt = chat2.lastMessage?.createdAt;
          return chatBCreateAt.compareWith(chat1.lastMessage?.createdAt);
        }

        return 0;
    }
  }
}
