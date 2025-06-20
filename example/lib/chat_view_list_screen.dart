import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class ChatViewListScreen extends StatefulWidget {
  const ChatViewListScreen({super.key});

  @override
  State<ChatViewListScreen> createState() => _ChatViewListScreenState();
}

class _ChatViewListScreenState extends State<ChatViewListScreen> {
  late final ChatViewListController controller;

  @override
  void initState() {
    final now = DateTime.now().toUtc();
    final fiveMinAgo = now.subtract(const Duration(minutes: 5));
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastMessageTime = DateTime.parse('2025-06-06T13:58:00.000Z');
    var initialUsersList = [
      ChatViewListModel(
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
        unreadCount: 1,
        imageUrl:
            'https://m.media-amazon.com/images/M/MV5BMzU5ZGYzNmQtMTdhYy00OGRiLTg0NmQtYjVjNzliZTg1ZGE4XkEyXkFqcGc@._V1_.jpg',
        chatType: ChatType.group,
      ),
      ChatViewListModel(
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
      ChatViewListModel(
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
      ChatViewListModel(
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
      ChatViewListModel(
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
    ];

    controller = ChatViewListController(
      initialUsersList: initialUsersList,
      scrollController: ScrollController(),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatViewList(
        controller: controller,
        appbar: const ChatViewListAppBar(
          title: 'Breaking Bad',
        ),
        config: ChatViewListConfig(
          chatViewListTileConfig: ChatViewListTileConfig(
            backgroundColor: Colors.blue,
            onTap: (user) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    user: user,
                  ),
                ),
              );
            },
            onLongPress: (user) {
              debugPrint('Long pressed on user: ${user.name}');
            },
          ),
          searchConfig: SearchConfig(
            textEditingController: TextEditingController(),
            onSearch: (value) async {
              if (value.isEmpty) {
                return null;
              }
              final list = controller.initialUsersList
                  .where((user) =>
                      user.name.toLowerCase().contains(value.toLowerCase()))
                  .toList();
              return list;
            },
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
