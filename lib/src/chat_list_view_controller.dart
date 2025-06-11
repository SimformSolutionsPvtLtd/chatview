import 'dart:async';

import 'package:flutter/material.dart';

import 'models/chat_list_user.dart';

class ChatViewListController {
  ChatViewListController({
    required this.chatViewListUsers,
    required this.scrollController,
  });

  /// Represents initial chat list users.
  List<ChatViewListUser> chatViewListUsers;

  /// Provides scroll controller for chat list.
  ScrollController scrollController;

  /// Represents chat list user stream
  StreamController<List<ChatViewListUser>> chatListStreamController =
      StreamController();

  /// Used to add user in the chat list.
  void addUser(ChatViewListUser user) {
    chatViewListUsers.add(user);
    if (chatListStreamController.isClosed) return;
    chatListStreamController.sink.add(chatViewListUsers);
  }

  /// Function for loading data while pagination.
  void loadMoreUsers(List<ChatViewListUser> userList) {
    chatViewListUsers.addAll(userList);
    if (chatListStreamController.isClosed) return;
    chatListStreamController.sink.add(chatViewListUsers);
  }

  /// Function to add search results of the chat list in the stream.
  void addSearchResults(List<ChatViewListUser> searchResults) {
    if (chatListStreamController.isClosed) return;
    chatListStreamController.sink.add(searchResults);
  }

  /// Function to clear the search results and show the original chat list.
  void clearSearch() {
    if (chatListStreamController.isClosed) return;
    chatListStreamController.sink.add(chatViewListUsers);
  }

  /// Used to dispose ValueNotifiers and Streams.
  void dispose() {
    scrollController.dispose();
    chatListStreamController.close();
  }
}
