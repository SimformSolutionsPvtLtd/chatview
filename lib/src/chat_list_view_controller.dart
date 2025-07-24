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

import 'models/chat_view_list_tile.dart';
import 'values/typedefs.dart';

class ChatViewListController {
  ChatViewListController({
    required List<ChatViewListModel> initialChatList,
    required this.scrollController,
  }) {
    final chatListLength = initialChatList.length;

    final chatsMap = {
      for (var i = 0; i < chatListLength; i++)
        if (initialChatList[i] case final chat) chat.id: chat,
    };

    initialChatMap = chatsMap;

    // Add the initial chat map to the stream controller after the first frame
    Future.delayed(
      Duration.zero,
      () => _chatListStreamController.sink.add(initialChatMap),
    );
  }

  /// Initial chat list to be displayed in the chat list view.
  Map<String, ChatViewListModel> initialChatMap = {};

  /// Provides scroll controller for chat list.
  ScrollController scrollController;

  /// Stream controller to manage the chat list stream.
  final StreamController<Map<String, ChatViewListModel>>
      _chatListStreamController =
      StreamController<Map<String, ChatViewListModel>>.broadcast();

  late final Stream<List<ChatViewListModel>> chatListStream =
      _chatListStreamController.stream.map(
    (chatMap) => chatMap.values.toList(),
  );

  /// Adds a chat to the chat list.
  void addChat(ChatViewListModel chat) {
    initialChatMap[chat.id] = chat;
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.sink.add(initialChatMap);
  }

  /// Function for loading data while pagination.
  void loadMoreChats(List<ChatViewListModel> chatList) {
    final chatListLength = chatList.length;
    initialChatMap.addAll(
      {
        for (var i = 0; i < chatListLength; i++)
          if (chatList[i] case final chat) chat.id: chat,
      },
    );
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.sink.add(initialChatMap);
  }

  void updateChat(String chatId, UpdateChatCallback newChat) {
    final chat = initialChatMap[chatId];
    if (chat == null) return;

    initialChatMap[chatId] = newChat(chat);
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.sink.add(initialChatMap);
  }

  /// Function to add search results of the chat list in the stream.
  void updateChatList(List<ChatViewListModel> searchResults) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_chatListStreamController.isClosed) return;
        final searchResultLength = searchResults.length;
        _chatListStreamController.sink.add(
          {
            for (var i = 0; i < searchResultLength; i++)
              if (searchResults[i] case final chat) chat.id: chat,
          },
        );
      },
    );
  }

  /// Function to clear the search results and show the original chat list.
  void clearSearch() {
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.sink.add(initialChatMap);
  }

  /// Used to dispose ValueNotifiers and Streams.
  void dispose() {
    scrollController.dispose();
    _chatListStreamController.close();
  }
}
