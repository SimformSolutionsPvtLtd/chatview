import 'package:chatview/chatview.dart';

class Data {
  static const profileImage =
      "https://github.com/SimformSolutionsPvtLtd/chatview/blob/main/example/assets/images/simform.png?raw=true";

  static List<ChatViewListItem> chatList() {
    final now = DateTime.now().toUtc();
    final fiveMinAgo = now.subtract(const Duration(minutes: 5));
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastMessageTime = DateTime.parse('2025-06-06T13:58:00.000Z');
    return [
      ChatViewListItem(
        id: '1',
        name: 'Breaking Bad',
        lastMessage: Message(
          message:
              'I am not in danger, Skyler. I am the danger. A guy opens his door and gets shot and you think that of me? No. I am the one who knocks!',
          createdAt: now,
          sentBy: '2',
          id: '1',
          status: MessageStatus.read,
        ),
        unreadCount: 150,
        imageUrl:
            'https://m.media-amazon.com/images/M/MV5BMzU5ZGYzNmQtMTdhYy00OGRiLTg0NmQtYjVjNzliZTg1ZGE4XkEyXkFqcGc@._V1_.jpg',
        chatType: ChatType.group,
      ),
      ChatViewListItem(
        id: '2',
        name: 'Heisenberg',
        lastMessage: Message(
          message: 'Say my name!!',
          createdAt: fiveMinAgo,
          sentBy: '3',
          id: '2',
          status: MessageStatus.read,
        ),
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzc87OtZ7mZe-kca89Mfi4o1--95dQI7Ne-w&s',
        unreadCount: 2,
        userActiveStatus: UserActiveStatus.online,
      ),
      ChatViewListItem(
        id: '3',
        name: 'Jessie Pinkman',
        lastMessage: Message(
          message: 'Yeah....!!!!',
          createdAt: today,
          sentBy: '4',
          id: '3',
          status: MessageStatus.read,
        ),
        imageUrl: 'https://i.insider.com/5d9f454ee94e865e924818da?width=700',
      ),
      ChatViewListItem(
        id: '4',
        name: 'Walter White',
        lastMessage: Message(
          message: 'Whats up?',
          createdAt: yesterday,
          sentBy: '4',
          id: '4',
          status: MessageStatus.read,
        ),
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Efw6_noLe4BzEsbgsfHIhvZNqWKaDtckdQ&s',
      ),
      ChatViewListItem(
        id: '5',
        name: 'Hank Schrader',
        lastMessage: Message(
          message: 'Hello',
          createdAt: lastMessageTime,
          sentBy: '6',
          id: '5',
          status: MessageStatus.read,
        ),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/d/db/Hank_Schrader_S5B.png',
      ),
      ChatViewListItem(
        id: '6',
        name: 'Saul Goodman',
        lastMessage: Message(
          message: 'Better Call Saul',
          createdAt: now,
          sentBy: '7',
          id: '6',
          status: MessageStatus.read,
        ),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/9/9c/Saul_Goodman_S5B.png',
      ),
      ChatViewListItem(
        id: '7',
        name: 'Gus Fring',
        lastMessage: Message(
          message: 'I hide in plain sight.',
          createdAt: now,
          sentBy: '8',
          id: '7',
          status: MessageStatus.read,
        ),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/0/0c/Gustavo_Fring_S5B.png',
      ),
      ChatViewListItem(
        id: '8',
        name: 'Mike Ehrmantraut',
        lastMessage: Message(
          message: 'I do what I do best. I take care of my family.',
          createdAt: now,
          sentBy: '9',
          id: '8',
          status: MessageStatus.read,
        ),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/3/3c/Mike_Ehrmantraut_S5B.png',
      ),
      ChatViewListItem(
        id: '9',
        name: 'Lydia Rodarte-Quayle',
        lastMessage: Message(
          message: 'I have a business to run.',
          createdAt: now,
          sentBy: '10',
          id: '9',
          status: MessageStatus.read,
        ),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/2/2c/Lydia_Rodarte-Quayle_S5B.png',
      ),
      ChatViewListItem(
        id: '10',
        name: 'Todd Alquist',
        lastMessage: Message(
          message: 'Yeah, I can do that.',
          createdAt: now,
          sentBy: '11',
          id: '10',
          status: MessageStatus.read,
        ),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/3/3b/Todd_Alquist_S5B.png',
      ),
    ];
  }

  static final messageList = [
    Message(
      id: '1',
      message: "Hi!",
      createdAt: DateTime.now(),
      sentBy: '1', // userId of who sends the message
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
  ];
}
