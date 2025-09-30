import 'package:chatview/chatview.dart';

class Data {
  static const profileImage =
      "https://github.com/SimformSolutionsPvtLtd/chatview/blob/main/example/assets/images/simform.png?raw=true";

  static List<ChatViewListItem> getChatList() {
    final now = DateTime.now();
    return [
      ChatViewListItem(
        id: '1',
        name: 'Weekend',
        imageUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        chatRoomType: ChatRoomType.group,
        lastMessage: Message(
          id: '1',
          message: 'Who is up for a hike this weekend?',
          createdAt: now.subtract(const Duration(days: 1)),
          sentBy: '2',
          status: MessageStatus.read,
        ),
        settings: const ChatSettings(pinStatus: PinStatus.pinned),
      ),
      ChatViewListItem(
        id: '2',
        name: 'Andrius Schneider',
        imageUrl:
            'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        typingUsers: {const ChatUser(id: '3', name: 'Andrius')},
        unreadCount: 2,
        lastMessage: Message(
          id: '2',
          message: 'typing...',
          createdAt: DateTime(now.year, now.month, now.day, 9, 45),
          sentBy: '3',
          status: MessageStatus.delivered,
        ),
      ),
      ChatViewListItem(
        id: '3',
        name: 'Anna Payet',
        imageUrl:
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        lastMessage: Message(
          id: '3',
          message: 'Best breakfast ever',
          createdAt: DateTime(now.year, now.month, now.day, 9, 37),
          sentBy: '4',
          messageType: MessageType.image,
          status: MessageStatus.undelivered,
        ),
      ),
      ChatViewListItem(
        id: '4',
        name: 'Family',
        unreadCount: 4,
        chatRoomType: ChatRoomType.group,
        imageUrl:
            'https://images.pexels.com/photos/1081685/pexels-photo-1081685.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        lastMessage: Message(
          id: '4',
          message: 'See you at the dinner table!',
          createdAt: now.subtract(const Duration(days: 1)),
          sentBy: '5',
          status: MessageStatus.pending,
        ),
      ),
      ChatViewListItem(
        id: '5',
        name: 'Maria',
        imageUrl:
            'https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        lastMessage: Message(
          id: '5',
          message: 'It was great to see you! Let\'s catch up again soon',
          createdAt: now.subtract(const Duration(hours: 1)),
          sentBy: 'me',
          status: MessageStatus.read,
        ),
      ),
      ChatViewListItem(
        id: '6',
        name: 'Lunch club!',
        chatRoomType: ChatRoomType.group,
        imageUrl:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        lastMessage: Message(
          id: '6',
          message: 'Can we reschedule our lunch to Thursday?',
          createdAt: now.subtract(const Duration(days: 1)),
          sentBy: '7',
          status: MessageStatus.delivered,
        ),
        settings: const ChatSettings(muteStatus: MuteStatus.muted),
      ),
      ChatViewListItem(
        id: '7',
        name: "Jasper's market",
        imageUrl:
            'https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        unreadCount: 1,
        lastMessage: Message(
          id: '7',
          message: 'It will be ready on Thursday!',
          createdAt: now.subtract(const Duration(hours: 12)),
          sentBy: '8',
          status: MessageStatus.read,
        ),
      ),
      ChatViewListItem(
        id: '8',
        name: 'Work',
        chatRoomType: ChatRoomType.group,
        imageUrl:
            'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        lastMessage: Message(
          id: '8',
          message: 'Please review the latest project updates.',
          createdAt: now.subtract(const Duration(days: 2)),
          sentBy: '9',
          status: MessageStatus.read,
        ),
      ),
      ChatViewListItem(
        id: '9',
        name: 'Evelyn Harper',
        imageUrl:
            'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        lastMessage: Message(
          id: '9',
          message: 'Let\'s plan our next trip!',
          createdAt: now.subtract(const Duration(days: 3)),
          sentBy: '10',
          status: MessageStatus.read,
        ),
      ),
      ChatViewListItem(
        id: '10',
        name: 'Book club',
        chatRoomType: ChatRoomType.group,
        imageUrl:
            'https://images.pexels.com/photos/159711/book-books-bookstore-book-reading-159711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        lastMessage: Message(
          id: '10',
          message: 'Next meeting is on Friday at 6 PM.',
          createdAt: now.subtract(const Duration(days: 4)),
          sentBy: '11',
          status: MessageStatus.read,
        ),
      ),
    ];
  }

  static const currentUser = ChatUser(
    id: '1',
    name: 'Flutter',
    profilePhoto: Data.profileImage,
  );

  static const otherUsers = [
    ChatUser(
      id: '2',
      name: 'Simform',
      profilePhoto: Data.profileImage,
    ),
    ChatUser(
      id: '3',
      name: 'Jhon',
      profilePhoto: Data.profileImage,
    ),
    ChatUser(
      id: '4',
      name: 'Mike',
      profilePhoto: Data.profileImage,
    ),
    ChatUser(
      id: '5',
      name: 'Rich',
      profilePhoto: Data.profileImage,
    ),
  ];

  static getMessageList({bool isExampleOne = true}) => [
        Message(
          id: '1',
          message: "How's it going?",
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          sentBy: '1',
          status: MessageStatus.read,
        ),
        Message(
          id: '2',
          message: "I'm doing great, thanks for asking! How about you?",
          createdAt:
              DateTime.now().subtract(const Duration(days: 30, minutes: 5)),
          sentBy: '2',
          status: MessageStatus.read,
          reaction: Reaction(reactions: ['\u{1F44D}'], reactedUserIds: ['1']),
        ),
        Message(
          id: '3',
          message: "I'm good too. Just got back from a vacation.",
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          sentBy: '1',
          status: MessageStatus.read,
        ),
        Message(
          id: '4',
          message: "That's awesome! Where did you go?",
          createdAt:
              DateTime.now().subtract(const Duration(days: 7, minutes: 5)),
          sentBy: '2',
          status: MessageStatus.read,
        ),
        Message(
          id: '5',
          message: "I went to the mountains. It was beautiful. Here's a pic:",
          createdAt:
              DateTime.now().subtract(const Duration(days: 7, minutes: 10)),
          sentBy: '1',
          status: MessageStatus.read,
        ),
        Message(
          id: '6',
          message:
              "https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
          createdAt:
              DateTime.now().subtract(const Duration(days: 7, minutes: 10)),
          messageType: MessageType.image,
          sentBy: '1',
          status: MessageStatus.read,
          reaction: Reaction(reactions: ['\u{2764}'], reactedUserIds: ['2']),
        ),
        Message(
          id: '7',
          message: "Wow, that's breathtaking!",
          createdAt:
              DateTime.now().subtract(const Duration(days: 7, minutes: 12)),
          sentBy: '2',
          status: MessageStatus.read,
          replyMessage: const ReplyMessage(
            message:
                "https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
            replyTo: '1',
            replyBy: '2',
            messageId: '6',
            messageType: MessageType.image,
          ),
        ),
        Message(
          id: '8',
          message: "We should go together sometime.",
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          sentBy: '1',
          status: MessageStatus.read,
        ),
        Message(
          id: '9',
          message: "I'd love that! Let's plan it.",
          createdAt:
              DateTime.now().subtract(const Duration(days: 1, minutes: 5)),
          sentBy: '2',
          status: MessageStatus.read,
        ),
        Message(
          id: '10',
          message: "Are you free this weekend?",
          createdAt: DateTime.now(),
          sentBy: '1',
          status: MessageStatus.read,
        ),
        if (isExampleOne)
          Message(
            id: '11',
            message: 'Message unavailable',
            createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
            sentBy: '2',
            status: MessageStatus.delivered,
            messageType: MessageType.custom,
          )
        else
          Message(
            id: '18',
            message: 'Twin Pines Mall - Hill Valley',
            createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
            sentBy: '2',
            status: MessageStatus.delivered,
            messageType: MessageType.custom,
          ),
        Message(
          id: '12',
          message: "I think so. Let me check my calendar.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          sentBy: '2',
          status: MessageStatus.read,
        ),
        Message(
          id: '13',
          message: "Yep, I'm free on Saturday.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          sentBy: '2',
          status: MessageStatus.read,
          reaction: Reaction(reactions: ['\u{1F44D}'], reactedUserIds: ['1']),
          replyMessage: const ReplyMessage(
            message: "Are you free this weekend?",
            replyTo: '1',
            replyBy: '2',
            messageId: '10',
          ),
        ),
        Message(
          id: '14',
          message: "Great! Let's do something fun.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          sentBy: '1',
          status: MessageStatus.read,
        ),
        Message(
          id: '19',
          message: 'https://bit.ly/3JHS2Wl',
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
          sentBy: '2',
          status: MessageStatus.read,
          messageType: MessageType.text,
        ),
        Message(
          id: '20',
          message: "Check this out! We can meet here.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          sentBy: '2',
          status: MessageStatus.read,
        ),
      ];

  static final oldMessageList = [
    Message(
      id: '101',
      message: "Hey!",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      sentBy: '2',
      status: MessageStatus.read,
    ),
    Message(
      id: '102',
      message: "Hi there!",
      createdAt: DateTime.now().subtract(const Duration(days: 1, minutes: 5)),
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '103',
      message: "How was your weekend?",
      createdAt: DateTime.now().subtract(const Duration(days: 1, minutes: 10)),
      sentBy: '2',
      status: MessageStatus.read,
    ),
    Message(
      id: '104',
      message: "It was great! I went hiking.",
      createdAt: DateTime.now().subtract(const Duration(days: 1, minutes: 15)),
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '105',
      message: "Sounds fun! Did you take any pictures?",
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      sentBy: '2',
      status: MessageStatus.read,
    ),
    Message(
      id: '106',
      message: "I'll send it in a moment.",
      createdAt: DateTime.now().subtract(const Duration(minutes: 17)),
      messageType: MessageType.text,
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '107',
      message: "https://www.fillmurray.com/640/360",
      createdAt: DateTime.now().subtract(const Duration(minutes: 16)),
      messageType: MessageType.image,
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '108',
      message: "Haha, nice one!",
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      sentBy: '2',
      status: MessageStatus.read,
      reaction: Reaction(reactions: ['\u{1F602}'], reactedUserIds: ['2']),
    ),
    Message(
      id: '109',
      message: "What are you up to?",
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      sentBy: '1',
      status: MessageStatus.read,
      replyMessage: const ReplyMessage(
        message: "Haha, nice one!",
        replyTo: '1',
        replyBy: '2',
        messageId: '9',
      ),
    ),
  ];
}
