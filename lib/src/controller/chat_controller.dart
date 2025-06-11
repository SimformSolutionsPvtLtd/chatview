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

import 'package:chatview/src/widgets/suggestions/suggestion_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class ChatController {
  /// Represents initial message list in chat which can be add by user.
  List<Message> initialMessageList;

  ScrollController scrollController;

  /// Allow user to show typing indicator defaults to false.
  final ValueNotifier<bool> _showTypingIndicator = ValueNotifier(false);

  /// TypingIndicator as [ValueNotifier] for [GroupedChatList] widget's typingIndicator [ValueListenableBuilder].
  ///  Use this for listening typing indicators
  ///   ```dart
  ///    chatcontroller.typingIndicatorNotifier.addListener((){});
  ///  ```
  /// For more functionalities see [ValueNotifier].
  ValueListenable<bool> get typingIndicatorNotifier => _showTypingIndicator;

  /// Allow user to add reply suggestions defaults to empty.
  final ValueNotifier<List<SuggestionItemData>> _replySuggestion =
      ValueNotifier([]);

  /// newSuggestions as [ValueNotifier] for [SuggestionList] widget's [ValueListenableBuilder].
  ///  Use this to listen when suggestion gets added
  ///   ```dart
  ///    chatcontroller.newSuggestions.addListener((){});
  ///  ```
  /// For more functionalities see [ValueNotifier].
  ValueListenable<List<SuggestionItemData>> get newSuggestions =>
      _replySuggestion;

  /// Getter for typingIndicator value instead of accessing [_showTypingIndicator.value]
  /// for better accessibility.
  bool get showTypingIndicator => _showTypingIndicator.value;

  /// Setter for changing values of typingIndicator
  /// ```dart
  ///  chatContoller.setTypingIndicator = true; // for showing indicator
  ///  chatContoller.setTypingIndicator = false; // for hiding indicator
  ///  ````
  set setTypingIndicator(bool value) => _showTypingIndicator.value = value;

  /// Represents list of chat users
  List<ChatUser> otherUsers;

  /// Provides current user which is sending messages.
  final ChatUser currentUser;

  ChatController({
    required this.initialMessageList,
    required this.scrollController,
    required this.otherUsers,
    required this.currentUser,
  });

  /// Represents message stream of chat
  StreamController<List<Message>> messageStreamController = StreamController();

  /// Used to dispose ValueNotifiers and Streams.
  void dispose() {
    _showTypingIndicator.dispose();
    _replySuggestion.dispose();
    scrollController.dispose();
    messageStreamController.close();
  }

  /// Used to add message in message list.
  void addMessage(Message message) {
    initialMessageList.add(message);
    if (!messageStreamController.isClosed) {
      messageStreamController.sink.add(initialMessageList);
    }
  }

   /// Used to replace the last message in the list.
  /// Useful for streaming responses where content is updated incrementally.
  void replaceLastMessage(Message message) {
    if (initialMessageList.isNotEmpty) {
      initialMessageList[initialMessageList.length - 1] = message;
      if (!messageStreamController.isClosed) {
        messageStreamController.sink.add(initialMessageList);
      }
    } else {
      addMessage(message);
    }
  }
  /// Used to add reply suggestions.
  void addReplySuggestions(List<SuggestionItemData> suggestions) {
    _replySuggestion.value = suggestions;
  }

  /// Used to remove reply suggestions.
  void removeReplySuggestions() {
    _replySuggestion.value = [];
  }

  /// Function for setting reaction on specific chat bubble
  void setReaction({
    required String emoji,
    required String messageId,
    required String userId,
  }) {
    final message =
        initialMessageList.firstWhere((element) => element.id == messageId);
    final reactedUserIds = message.reaction.reactedUserIds;
    final indexOfMessage = initialMessageList.indexOf(message);
    final userIndex = reactedUserIds.indexOf(userId);
    if (userIndex != -1) {
      if (message.reaction.reactions[userIndex] == emoji) {
        message.reaction.reactions.removeAt(userIndex);
        message.reaction.reactedUserIds.removeAt(userIndex);
      } else {
        message.reaction.reactions[userIndex] = emoji;
      }
    } else {
      message.reaction.reactions.add(emoji);
      message.reaction.reactedUserIds.add(userId);
    }
    initialMessageList[indexOfMessage] = Message(
      id: messageId,
      message: message.message,
      createdAt: message.createdAt,
      sentBy: message.sentBy,
      replyMessage: message.replyMessage,
      reaction: message.reaction,
      messageType: message.messageType,
      status: message.status,
    );
    if (!messageStreamController.isClosed) {
      messageStreamController.sink.add(initialMessageList);
    }
  }

  /// Function to scroll to last messages in chat view
  void scrollToLastMessage() => Timer(
        const Duration(milliseconds: 300),
        () {
          if (!scrollController.hasClients) return;
          scrollController.animateTo(
            scrollController.positions.last.minScrollExtent,
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 300),
          );
        },
      );

  /// Function for loading data while pagination.
  void loadMoreData(List<Message> messageList) {
    /// Here, we have passed 0 index as we need to add data before first data
    initialMessageList.insertAll(0, messageList);
    if (!messageStreamController.isClosed) {
      messageStreamController.sink.add(initialMessageList);
    }
  }

  /// Function for getting ChatUser object from user id
  ChatUser getUserFromId(String userId) => userId == currentUser.id
      ? currentUser
      : otherUsers.firstWhere((element) => element.id == userId);
}
