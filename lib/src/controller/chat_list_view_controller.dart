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
import '../values/enumeration.dart';
import '../values/typedefs.dart';

class ChatViewListController {
  ChatViewListController({
    required List<ChatViewListItem> initialChatList,
    required this.scrollController,
    this.disposeOtherResources = true,
    bool sortEnable = true,
    ChatSorter? chatSorter,
  }) {
    chatListStream = _chatListStreamController.stream.map(
      (chatMap) {
        final chatList = chatMap.values.toList();
        if (sortEnable) {
          chatList.sort(
            chatSorter ?? ChatViewListSortBy.pinFirstByPinTime.sort,
          );
        }
        return chatList;
      },
    );

    final chatListLength = initialChatList.length;

    final chatsMap = {
      for (var i = 0; i < chatListLength; i++)
        if (initialChatList[i] case final chat) chat.id: chat,
    };

    chatListMap
      ..clear()
      ..addAll(chatsMap);

    // Adds the current chat map to the stream controller
    // after the first frame render.
    Future.delayed(
      Duration.zero,
      () => _chatListStreamController.add(chatListMap),
    );
  }

  /// Stores and manages chat items by their unique IDs.
  /// A map is used for efficient lookup, update, and removal of chats
  /// by their unique id.
  final Map<String, ChatViewListItem> chatListMap = {};

  /// Provides scroll controller for chat list.
  final ScrollController scrollController;

  final bool disposeOtherResources;

  /// Stream controller to manage the chat list stream.
  final StreamController<Map<String, ChatViewListItem>>
      _chatListStreamController =
      StreamController<Map<String, ChatViewListItem>>.broadcast();

  late final Stream<List<ChatViewListItem>> chatListStream;

  /// Adds a chat to the chat list.
  void addChat(ChatViewListItem chat) {
    chatListMap[chat.id] = chat;
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
  }

  /// Function for loading data while pagination.
  void loadMoreChats(List<ChatViewListItem> chatList) {
    final chatListLength = chatList.length;
    chatListMap.addAll(
      {
        for (var i = 0; i < chatListLength; i++)
          if (chatList[i] case final chat) chat.id: chat,
      },
    );
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
  }

  /// Updates the chat entry in [chatListMap] for the given [chatId] using
  /// the provided [newChat] callback.
  ///
  /// If the chat with [chatId] does not exist, the method returns without
  /// making changes.
  void updateChat(String chatId, UpdateChatCallback newChat) {
    final chat = chatListMap[chatId];
    if (chat == null) return;

    chatListMap[chatId] = newChat(chat);
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
  }

  /// Removes the chat with the given [chatId] from the chat list.
  ///
  /// If the chat with [chatId] does not exist, the method returns without
  /// making changes.
  void removeChat(String chatId) {
    if (!chatListMap.containsKey(chatId)) return;
    chatListMap.remove(chatId);
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
  }

  /// Adds the given chat search results to the stream after the current frame.
  void setSearchChats(List<ChatViewListItem> searchResults) {
    final searchResultLength = searchResults.length;
    final searchResultMap = {
      for (var i = 0; i < searchResultLength; i++)
        if (searchResults[i] case final chat) chat.id: chat,
    };
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(searchResultMap);
  }

  /// Function to clear the search results and show the original chat list.
  void clearSearch() {
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
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
