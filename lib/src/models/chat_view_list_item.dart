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
import 'package:chatview_utils/chatview_utils.dart';

import '../values/enumeration.dart';
import '../values/typedefs.dart';
import 'config_models/chat_view_list/chat_settings.dart';
import 'omit.dart';

/// Model class representing a user or group in the chat list.
class ChatViewListItem {
  /// Creates a user or group object for the chat list.
  const ChatViewListItem({
    required this.id,
    required this.name,
    this.chatType = ChatType.user,
    this.typingUsers = const <ChatUser>{},
    this.userActiveStatus = UserActiveStatus.offline,
    this.settings = const ChatSettings(),
    this.lastMessage,
    this.imageUrl,
    this.unreadCount,
  });

  /// Unique identifier for the user or group.
  final String id;

  /// Provides name of the user or group.
  final String name;

  /// Provides last message in chat list.
  final Message? lastMessage;

  /// Provides image URL for user or group profile in chat list.
  final String? imageUrl;

  /// Provides unread message count for user or group in chat list.
  final int? unreadCount;

  /// Type of chat: user or group.
  ///
  /// Defaults to [ChatType.user].
  final ChatType chatType;

  /// User's active status in the chat list.
  ///
  /// Defaults to [UserActiveStatus.offline].
  final UserActiveStatus userActiveStatus;

  /// Set of users currently typing in the chat.
  final Set<ChatUser> typingUsers;

  /// Settings for the chat list view.
  final ChatSettings settings;

  ChatViewListItem copyWith({
    Defaulted<String> id = const Omit(),
    Defaulted<String> name = const Omit(),
    Defaulted<ChatType> chatType = const Omit(),
    Defaulted<Set<ChatUser>> typingUsers = const Omit(),
    Defaulted<UserActiveStatus> userActiveStatus = const Omit(),
    Defaulted<ChatSettings> settings = const Omit(),
    Defaulted<Message>? lastMessage = const Omit(),
    Defaulted<String>? imageUrl = const Omit(),
    Defaulted<int>? unreadCount = const Omit(),
  }) {
    return ChatViewListItem(
      id: id is Omit ? this.id : id as String,
      name: name is Omit ? this.name : name as String,
      chatType: chatType is Omit ? this.chatType : chatType as ChatType,
      typingUsers:
          typingUsers is Omit ? this.typingUsers : typingUsers as Set<ChatUser>,
      userActiveStatus: userActiveStatus is Omit
          ? this.userActiveStatus
          : userActiveStatus as UserActiveStatus,
      settings: settings is Omit ? this.settings : settings as ChatSettings,
      lastMessage:
          lastMessage is Omit ? this.lastMessage : lastMessage as Message?,
      imageUrl: imageUrl is Omit ? this.imageUrl : imageUrl as String?,
      unreadCount: unreadCount is Omit ? this.unreadCount : unreadCount as int?,
    );
  }
}
