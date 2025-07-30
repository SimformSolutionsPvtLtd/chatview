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

/// Model class representing a user or group in the chat list.
class ChatViewListItem {
  /// Creates a user or group object for the chat list.
  const ChatViewListItem({
    required this.id,
    required this.name,
    this.chatType = ChatType.user,
    this.userActiveStatus = UserActiveStatus.offline,
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
}
