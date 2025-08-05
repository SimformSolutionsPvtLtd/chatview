import 'package:chatview/chatview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chat_view_screen.dart';
import 'data.dart';

class ChatViewListScreen extends StatefulWidget {
  const ChatViewListScreen({super.key});

  @override
  State<ChatViewListScreen> createState() => _ChatViewListScreenState();
}

class _ChatViewListScreenState extends State<ChatViewListScreen> {
  ChatViewListController? chatListController;

  // Assign the controller in didChangeDependencies
  // to ensure PrimaryScrollController is available.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chatListController ??= ChatViewListController(
      initialChatList: Data.chatList(),
      scrollController: PrimaryScrollController.of(context),
    );
  }

  @override
  void dispose() {
    chatListController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: chatListController == null
          ? const Center(child: CircularProgressIndicator())
          : ChatViewList(
              controller: chatListController!,
              appbar: ChatViewListAppBar(
                title: 'ChatView',
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Handle search action
                    },
                  ),
                ],
                scrolledUnderElevation: 0,
              ),
              header: SizedBox(
                height: 60,
                child: ListView(
                  padding: const EdgeInsetsGeometry.all(12),
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip.elevated(
                      backgroundColor: Colors.grey.shade200,
                      label: Text(
                          'All Chats (${chatListController?.chatListMap.length ?? 0})'),
                      onSelected: (bool value) =>
                          chatListController?.clearSearch(),
                    ),
                    const SizedBox(width: 12),
                    FilterChip.elevated(
                      backgroundColor: Colors.grey.shade200,
                      label: const Text('Pinned Chats'),
                      onSelected: (bool value) {
                        chatListController?.setSearchChats(
                          chatListController?.chatListMap.values
                                  .where((e) => e.settings.pinStatus.isPinned)
                                  .toList() ??
                              [],
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    FilterChip.elevated(
                      backgroundColor: Colors.grey.shade200,
                      label: const Text('Unread Chats'),
                      onSelected: (bool value) {
                        chatListController?.setSearchChats(
                          chatListController?.chatListMap.values
                                  .where((e) => (e.unreadCount ?? 0) > 0)
                                  .toList() ??
                              [],
                        );
                      },
                    ),
                  ],
                  // separatorBuilder: (_, __) => const SizedBox(width: 12),
                ),
              ),
              searchConfig: ChatViewListSearchConfig(
                textEditingController: TextEditingController(),
                debounceDuration: const Duration(milliseconds: 300),
                onSearch: (value) async {
                  if (value.isEmpty) {
                    return null;
                  }
                  final list = chatListController?.chatListMap.values
                      .where((chat) =>
                          chat.name.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                  return list;
                },
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              loadMoreChats: () async =>
                  await Future.delayed(const Duration(seconds: 2)),
              menuConfig: ChatMenuConfig(
                enabled: true,
                actions: (chat) => [
                  CupertinoContextMenuAction(
                    trailingIcon: Icons.delete_forever,
                    onPressed: () {
                      Future.delayed(
                        // Call this after the animation of menu is completed
                        // To show the pin status change animation
                        const Duration(milliseconds: 800),
                        () => chatListController?.removeChat(chat.id),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Delete Chat'),
                  ),
                ],
                pinStatusCallback: (result) {
                  Future.delayed(
                    // Call this after the animation of menu is completed
                    // To show the pin status change animation
                    const Duration(milliseconds: 800),
                    () => chatListController?.updateChat(
                      result.chat.id,
                      (previousChat) => previousChat.copyWith(
                        settings: previousChat.settings.copyWith(
                          pinStatus: result.status,
                        ),
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
              enablePagination: false,
              loadMoreConfig: const LoadMoreConfig(),
              tileConfig: ChatViewListTileConfig(
                pinIconConfig: const PinIconConfig(),
                muteIconConfig: const MuteIconConfig(),
                listTypeIndicatorConfig: const ListTypeIndicatorConfig(
                  showUserNames: true,
                ),
                unreadCountConfig: const UnreadCountConfig(
                  backgroundColor: Colors.red,
                  style: UnreadCountStyle.ninetyNinePlus,
                ),
                userActiveStatusConfig: const UserActiveStatusConfig(
                  color: Colors.red,
                ),
                userAvatarConfig: const UserAvatarConfig(
                  backgroundColor: Colors.blue,
                ),
                onTap: (chat) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatViewScreen(
                        chat: chat,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
