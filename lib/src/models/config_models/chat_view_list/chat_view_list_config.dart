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

import 'chat_view_list_tile_config.dart';
import 'load_more_config.dart';
import 'search_config.dart';

/// Configuration class for the chat list UI.
class ChatViewListConfig {
  /// Creates a configuration object for the chat list UI.
  const ChatViewListConfig({
    this.enablePagination = false,
    this.loadMoreConfig = const LoadMoreConfig(),
    this.tileConfig = const ChatViewListTileConfig(),
    this.separator = const Divider(height: 12),
    this.extraSpaceAtLast = 32,
    this.searchConfig,
  });

  /// Configuration for the search text field in the chat list.
  final ChatViewListSearchConfig? searchConfig;

  /// Widget to be used as a separator between chat items.
  ///
  /// Defaults to a `Divider` with a height of `12`.
  final Widget separator;

  /// Configuration for the chat tile widget in the chat list.
  final ChatViewListTileConfig tileConfig;

  /// Extra space at the last element of the chat list.
  ///
  /// Defaults to `32`.
  final double extraSpaceAtLast;

  /// Configuration for the load more chat list widget.
  final LoadMoreConfig loadMoreConfig;

  /// Flag to enable or disable pagination in the chat list.
  ///
  /// Defaults to `false`.
  final bool enablePagination;
}
