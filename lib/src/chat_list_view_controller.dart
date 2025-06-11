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

class ChatViewListController {
  ChatViewListController({
    required this.initialUsersList,
    required this.scrollController,
  });

  /// Represents initial chat list users.
  List<ChatViewListModel> initialUsersList = [];

  /// Provides scroll controller for chat list.
  ScrollController scrollController;

  /// Represents chat list user stream
  StreamController<List<ChatViewListModel>> chatListStreamController =
      StreamController.broadcast();

  /// Used to add user in the chat list.
  void addUser(ChatViewListModel user) {
    initialUsersList.add(user);
    if (chatListStreamController.isClosed) return;
    chatListStreamController.sink.add(initialUsersList);
  }

  /// Function for loading data while pagination.
  void loadMoreUsers(List<ChatViewListModel> userList) {
    initialUsersList.addAll(userList);
    if (chatListStreamController.isClosed) return;
    chatListStreamController.sink.add(initialUsersList);
  }

  /// Function to add search results of the chat list in the stream.
  void updateChatList(List<ChatViewListModel> searchResults) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (chatListStreamController.isClosed) return;
        chatListStreamController.sink.add(searchResults);
      },
    );
  }

  /// Function to clear the search results and show the original chat list.
  void clearSearch() {
    if (chatListStreamController.isClosed) return;
    chatListStreamController.sink.add(initialUsersList);
  }

  /// Used to dispose ValueNotifiers and Streams.
  void dispose() {
    scrollController.dispose();
    chatListStreamController.close();
  }
}
