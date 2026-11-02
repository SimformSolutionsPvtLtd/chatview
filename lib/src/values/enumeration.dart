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

enum ShowReceiptsIn {
  all,
  lastMessage;

  bool get isAll => this == ShowReceiptsIn.all;

  bool get isLastMessage => this == ShowReceiptsIn.lastMessage;
}

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

/// Defines how the sending → sent receipt transition is animated next to an
/// outgoing chat bubble.
enum SendingMessageAnimationType {
  /// Default. A small dot/circle indicator that slides out to the right once
  /// the message transitions from pending to sent.
  slideOut,

  /// A minimal "Sending..." text label (no surrounding padding) that fades and
  /// collapses away once the message is sent.
  textLabel,

  /// WhatsApp-style clock that turns into a tick once sent.
  ///
  /// Text, image and voice bubbles draw it inline next to the time, and
  /// [ShowReceiptsIn] is ignored. Custom messages draw it below the bubble.
  /// A custom `receiptsBuilder` replaces it and is drawn below the bubble.
  clockToTick;

  /// Returns true if the animation type is [slideOut].
  bool get isSlideOut => this == slideOut;

  /// Returns true if the animation type is [textLabel].
  bool get isTextLabel => this == textLabel;

  /// Returns true if the animation type is [clockToTick].
  bool get isClockToTick => this == clockToTick;
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

enum ChatViewStateType {
  chatView,
  chatList;

  bool get isChatView => this == ChatViewStateType.chatView;

  bool get isChatList => this == ChatViewStateType.chatList;
}

enum UserActiveStatusAlignment {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  bool get isTopLeft => this == topLeft;

  bool get isTopRight => this == topRight;

  bool get isBottomLeft => this == bottomLeft;

  bool get isBottomRight => this == bottomRight;
}

/// Defines the audio player mode,
/// controlling whether single or multiple audio files can be
/// played simultaneously.
enum PlayerMode {
  /// Only one audio can be played at a time.
  ///
  /// Note: Starting recording will stop any currently playing audio.
  single,

  /// Multiple audios can be played simultaneously.
  ///
  /// Note: Starting recording will not affect any currently playing audio.
  multi;
}

/// Extension methods for PlayerMode enum.
extension PlayerModeExtension on PlayerMode {
  /// Checks if the player mode is single.
  bool get isSingle => this == PlayerMode.single;

  /// Checks if the player mode is multi.
  bool get isMulti => this == PlayerMode.multi;
}

/// Defines built-in display formats for voice message durations.
enum VoiceDurationFormat {
  /// Displays as HH:MM:SS (example: 00:01:32).
  hhmmss,

  /// Displays as MM:SS (example: 01:32).
  mmss,

  /// Displays as H:MM:SS if hour > 0, otherwise MM:SS.
  adaptive;
}

/// Extension methods for [VoiceDurationFormat].
extension VoiceDurationFormatExtension on VoiceDurationFormat {
  bool get isHhmmss => this == VoiceDurationFormat.hhmmss;

  bool get isMmss => this == VoiceDurationFormat.mmss;

  bool get isAdaptive => this == VoiceDurationFormat.adaptive;
}

extension MessageStatusExtension on MessageStatus {
  String get localizedLabel {
    final locale = PackageStrings.currentLocale;
    return switch (this) {
      MessageStatus.pending => locale.sending,
      MessageStatus.delivered => locale.sent,
      MessageStatus.read => locale.read,
      MessageStatus.undelivered => locale.notDelivered,
    };
  }

  IconData get statusIcon => switch (this) {
        MessageStatus.pending => Icons.access_time,
        MessageStatus.delivered => Icons.check,
        MessageStatus.read => Icons.done_all,
        MessageStatus.undelivered => Icons.error_outline,
      };
}
