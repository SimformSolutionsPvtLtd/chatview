import 'package:chatview/chatview.dart';

class Data {
  static const profileImage =
      "https://github.com/SimformSolutionsPvtLtd/chatview/blob/main/example/assets/images/simform.png?raw=true";

  static final chatList = [
    ChatViewListItem(
      id: '2',
      name: 'Simform',
      unreadCount: 2,
      imageUrl: Data.profileImage,
      lastMessage: Message(
        id: '12',
        sentBy: '2',
        message: "🤩🤩",
        createdAt: DateTime.now().toUtc(),
        status: MessageStatus.delivered,
      ),
      settings: ChatSettings(
        pinStatus: PinStatus.pinned,
        pinTime: DateTime.now().toUtc(),
      ),
    ),
    ChatViewListItem(
      id: '1',
      name: 'Flutter',
      imageUrl: Data.profileImage,
      userActiveStatus: UserActiveStatus.online,
      lastMessage: Message(
        id: '13',
        sentBy: '1',
        message: "https://example.com/image.png",
        messageType: MessageType.image,
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toUtc(),
        status: MessageStatus.delivered,
      ),
    ),
    ChatViewListItem(
      id: '3',
      name: 'Flutter Dev Group',
      imageUrl: Data.profileImage,
      chatRoomType: ChatRoomType.group,
      userActiveStatus: UserActiveStatus.online,
      lastMessage: Message(
        id: '13',
        sentBy: '2',
        message: "https://example.com/image.png",
        messageType: MessageType.image,
        createdAt: DateTime.now().subtract(const Duration(days: 7)).toUtc(),
        status: MessageStatus.delivered,
      ),
    ),
  ];

  static final messageList = [
    Message(
      id: '1',
      message: "Hi!",
      createdAt: DateTime.now(),
      // userId of who sends the message
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '2',
      message: "Hi!",
      createdAt: DateTime.now(),
      sentBy: '2',
      status: MessageStatus.read,
    ),
    Message(
      id: '3',
      message: "We can meet?I am free",
      createdAt: DateTime.now(),
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '4',
      message: "Can you write the time and place of the meeting?",
      createdAt: DateTime.now(),
      sentBy: '1',
      status: MessageStatus.read,
    ),
    Message(
      id: '5',
      message: "That's fine",
      createdAt: DateTime.now(),
      sentBy: '2',
      reaction: Reaction(reactions: ['\u{2764}'], reactedUserIds: ['1']),
      status: MessageStatus.read,
    ),
    Message(
      id: '6',
      message: "When to go ?",
      createdAt: DateTime.now(),
      sentBy: '3',
      status: MessageStatus.read,
    ),
    Message(
      id: '7',
      message: "I guess Simform will reply",
      createdAt: DateTime.now(),
      sentBy: '4',
      status: MessageStatus.read,
    ),
    Message(
      id: '8',
      message: "https://bit.ly/3JHS2Wl",
      createdAt: DateTime.now(),
      sentBy: '2',
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{1F44D}', '\u{1F44D}'],
        reactedUserIds: ['2', '3', '4'],
      ),
      status: MessageStatus.read,
      replyMessage: const ReplyMessage(
        message: "Can you write the time and place of the meeting?",
        replyTo: '1',
        replyBy: '2',
        messageId: '4',
      ),
    ),
    Message(
      id: '9',
      message: "Done",
      createdAt: DateTime.now(),
      sentBy: '1',
      status: MessageStatus.read,
      reaction: Reaction(
        reactions: [
          '\u{2764}',
          '\u{2764}',
          '\u{2764}',
        ],
        reactedUserIds: ['2', '3', '4'],
      ),
    ),
    Message(
      id: '10',
      message: "Thank you!!",
      status: MessageStatus.read,
      createdAt: DateTime.now(),
      sentBy: '1',
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{2764}', '\u{2764}', '\u{2764}'],
        reactedUserIds: ['2', '4', '3', '1'],
      ),
    ),
    Message(
      id: '11',
      message: "https://miro.medium.com/max/1000/0*s7of7kWnf9fDg4XM.jpeg",
      createdAt: DateTime.now(),
      messageType: MessageType.image,
      sentBy: '1',
      reaction: Reaction(reactions: ['\u{2764}'], reactedUserIds: ['2']),
      status: MessageStatus.read,
    ),
    Message(
      id: '12',
      message: "🤩🤩",
      createdAt: DateTime.now(),
      sentBy: '2',
      status: MessageStatus.read,
    ),
    Message(
      id: '13',
      message: "Check this out",
      createdAt: DateTime.now(),
      replyMessage: const ReplyMessage(
        messageId: '140',
        replyTo: '2',
        replyBy: '1',
        message: "This",
      ),
      sentBy: '1',
      status: MessageStatus.read,
    ),
    for (int i = 14; i <= 19; i++)
      Message(
        id: i.toString(),
        message: "This is message number $i",
        createdAt:
            DateTime.now().subtract(Duration(hours: i % 2 == 0 ? i : i * 2)),
        sentBy: (i % 2 == 0) ? '1' : '2',
        status: MessageStatus.read,
      ),
  ];
}
