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
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/chat_view_list_item.dart';

class ChatViewListController {
  ChatViewListController({
    required this.initialChatList,
    required this.scrollController,
    this.disposeOtherResources = true,
  }) {
    // Add the initial chat list to the stream controller after the first frame.
    Future.delayed(
      Duration.zero,
      () => _chatListStreamController.add(initialChatList),
    );
  }

  /// Represents initial chat list.
  List<ChatViewListItem> initialChatList = [];

  /// Provides scroll controller for chat list.
  ScrollController scrollController;

  final bool disposeOtherResources;

  /// Represents chat list user stream
  final StreamController<List<ChatViewListItem>> _chatListStreamController =
      StreamController.broadcast();

  late final Stream<List<ChatViewListItem>> chatListStream =
      _chatListStreamController.stream;

  /// Adds a chat to the chat list.
  void addChat(ChatViewListItem chat) {
    initialChatList.add(chat);
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.sink.add(initialChatList);
  }

  /// Function for loading data while pagination.
  void loadMoreChats(List<ChatViewListItem> chatList) {
    initialChatList.addAll(chatList);
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.sink.add(initialChatList);
  }

  /// Adds the given chat search results to the stream after the current frame.
  void setSearchChats(List<ChatViewListItem> searchResults) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_chatListStreamController.isClosed) return;
        _chatListStreamController.sink.add(searchResults);
      },
    );
  }

  /// Function to clear the search results and show the original chat list.
  void clearSearch() {
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.sink.add(initialChatList);
  }

  /// Used to dispose ValueNotifiers and Streams.
  ///
  /// If [disposeOtherResources] is true,
  /// it will also dispose the scroll controller and text editing controller if provided.
  void dispose() {
    _chatListStreamController.close();
    if (disposeOtherResources) {
      scrollController.dispose();
    }
  }
}
