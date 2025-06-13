import '../values/enumeration.dart';

/// Model class representing a user or group in the chat list.
class ChatViewListUser {
  /// Unique identifier for the user or group.
  final String id;

  /// Provides name of the user or group.
  final String name;

  /// Provides time for last message in chat list.
  final String? lastMessageTime;

  /// Provides text for last message in chat list.
  final String? lastMessageText;

  /// Provides image URL for user or group profile in chat list.
  final String? imageUrl;

  /// Provides unread message count for user or group in chat list.
  final int? unreadCount;

  /// Type of chat: user or group.
  final ChatType chatType;

  /// User's active status in the chat list.
  /// Defaults to [UserActiveStatus.offline].
  final UserActiveStatus userActiveStatus;

  /// Creates a user or group object for the chat list.
  const ChatViewListUser({
    required this.id,
    required this.name,
    this.lastMessageText,
    this.lastMessageTime,
    this.imageUrl,
    this.unreadCount,
    this.chatType = ChatType.user,
    this.userActiveStatus = UserActiveStatus.offline,
  });
}
