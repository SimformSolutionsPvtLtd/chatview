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

import 'chat_view_list_time_config.dart';
import 'chat_view_list_user_config.dart';
import 'load_more_widget_config.dart';
import 'search_config.dart';
import 'unread_widget_config.dart';

/// Configuration class for the chat list UI.
class ChatViewListConfig {
  /// Creates a configuration object for the chat list UI.
  const ChatViewListConfig({
    this.searchConfig,
    this.separatorWidget,
    this.padding,
    this.chatViewListTileConfig,
    this.unreadWidgetConfig,
    this.extraSpaceAtLast,
    this.loadMoreChatListConfig,
    this.timeConfig,
    this.enablePagination = false,
  });

  /// Configuration for the search text field in the chat list.
  final SearchConfig? searchConfig;

  /// Divider widget to be used in the chat list.
  final Widget? separatorWidget;

  /// Padding for the chat list.
  final EdgeInsets? padding;

  /// Configuration for the user widget in the chat list.
  final ChatViewListTileConfig? chatViewListTileConfig;

  /// Configuration for the unread message widget in the chat list.
  final UnreadWidgetConfig? unreadWidgetConfig;

  /// Configuration for the unread message widget in the chat list.
  final ChatViewListTimeConfig? timeConfig;

  /// Extra space at the last element of the chat list.
  final double? extraSpaceAtLast;

  /// Configuration for the load more chat list widget.
  final LoadMoreChatListConfig? loadMoreChatListConfig;

  /// Flag to enable or disable pagination in the chat list.
  final bool enablePagination;
}
