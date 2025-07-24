import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'main.dart';

class ChatViewListScreen extends StatefulWidget {
  const ChatViewListScreen({super.key});

  @override
  State<ChatViewListScreen> createState() => _ChatViewListScreenState();
}

class _ChatViewListScreenState extends State<ChatViewListScreen> {
  final _searchController = TextEditingController();

  ChatViewListController? _chatListController;

  ScrollController? _scrollController;

  // Assign the controller in didChangeDependencies
  // to ensure PrimaryScrollController is available.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController = PrimaryScrollController.of(context);
    _chatListController ??= ChatViewListController(
      initialChatList: Data.chatList,
      scrollController: _scrollController!,
      disposeOtherResources: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _chatListController == null
          ? const Center(child: CircularProgressIndicator())
          : ChatViewList(
              controller: _chatListController!,
              appbar: ChatViewListAppBar(
                titleText: 'ChatView',
                centerTitle: false,
                scrolledUnderElevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Handle search action
                    },
                  ),
                ],
              ),
              config: ChatViewListConfig(
                tileConfig: ListTileConfig(
                  typingStatusConfig: const TypingStatusConfig(
                    showUserNames: true,
                  ),
                  unreadCountConfig: const UnreadCountConfig(
                    style: UnreadCountStyle.ninetyNinePlus,
                  ),
                  userAvatarConfig: UserAvatarConfig(
                    backgroundColor: Colors.red.shade100,
                  ),
                  onTap: (chat) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chat: chat,
                        ),
                      ),
                    );
                  },
                  onLongPress: (chat) {
                    debugPrint('Long pressed on chat: ${chat.name}');
                  },
                ),
                searchConfig: SearchConfig(
                  textEditingController: _searchController,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  onSearch: (value) async {
                    if (value.isEmpty) {
                      return null;
                    }
                    final list = _chatListController?.chatListMap.values
                        .where((chat) => chat.name
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                    return list;
                  },
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _chatListController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
