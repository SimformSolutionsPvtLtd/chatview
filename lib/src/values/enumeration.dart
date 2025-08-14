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
  chatViewList;

  bool get isChatView => this == ChatViewStateType.chatView;

  bool get isChatViewList => this == ChatViewStateType.chatViewList;
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
