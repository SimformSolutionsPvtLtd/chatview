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
        lastMessageText:
            'I am not in danger, Skyler. I am the danger. A guy opens his door and gets shot and you think that of me? No. I am the one who knocks!',
        lastMessageTime: now.toString(),
        unreadCount: 1,
        imageUrl:
            'https://m.media-amazon.com/images/M/MV5BMzU5ZGYzNmQtMTdhYy00OGRiLTg0NmQtYjVjNzliZTg1ZGE4XkEyXkFqcGc@._V1_.jpg',
        chatType: ChatType.group,
      ),
      ChatViewListModel(
        id: '2',
        name: 'Heisenberg',
        lastMessageText: 'Say my name!!',
        lastMessageTime: fiveMinAgo.toString(),
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzc87OtZ7mZe-kca89Mfi4o1--95dQI7Ne-w&s',
        unreadCount: 2,
        userActiveStatus: UserActiveStatus.online,
      ),
      ChatViewListModel(
        id: '3',
        name: 'Jessie Pinkman',
        lastMessageText: 'Yeah....!!!!',
        lastMessageTime: today.toString(),
        imageUrl: 'https://i.insider.com/5d9f454ee94e865e924818da?width=700',
      ),
      ChatViewListModel(
        id: '4',
        name: 'Walter White',
        lastMessageText: 'Whats up?',
        lastMessageTime: yesterday.toString(),
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Efw6_noLe4BzEsbgsfHIhvZNqWKaDtckdQ&s',
      ),
      ChatViewListModel(
        id: '5',
        name: 'Hank Schrader',
        lastMessageText: 'Hello... there?',
        lastMessageTime: lastMessageTime.toString(),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/d/db/Hank_Schrader_S5B.png',
      ),
      ChatViewListModel(
        id: '6',
        name: 'Gus Fring',
        lastMessageText: 'Hello, how are you?',
        lastMessageTime: lastMessageTime.toString(),
        unreadCount: 555,
        imageUrl:
            'https://static1.colliderimages.com/wordpress/wp-content/uploads/2024/04/giancarlo-esposito.jpg',
      ),
      ChatViewListModel(
        id: '7',
        name: 'Saul Goodman',
        lastMessageText: 'Hello, there?',
        lastMessageTime: lastMessageTime.toString(),
        unreadCount: 5,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/3/34/Jimmy_McGill_BCS_S3.png',
      ),
      ChatViewListModel(
        id: '8',
        name: 'Mike Ehrmantraut',
        lastMessageText: 'Hello, how are you?',
        lastMessageTime: lastMessageTime.toString(),
        unreadCount: 101,
        imageUrl:
            'https://www.nzherald.co.nz/resizer/v2/NHQQZRBM76J75YTKGET7TIMJWQ.jpg?auth=e27452261c7e9141481d40f30843a5f6099adaf64a7962140cc925340c637746&width=576&height=613&quality=70&smart=true',
      ),
      ChatViewListModel(
        id: '9',
        name: 'Skyler White',
        lastMessageText: 'Hey! Walter, I need to talk to you.',
        lastMessageTime: lastMessageTime.toString(),
        unreadCount: 1,
        imageUrl:
            'https://i.guim.co.uk/img/media/0cded676764fd68a0f426d2f489a3b2af90d7595/0_120_3600_2160/master/3600.jpg?width=700&quality=85&auto=format&fit=max&s=c565ca4ca2c481fc79893155617e0a1e',
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
