import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

import 'chat_view_screen.dart';
import 'data.dart';

class ChatViewListScreen extends StatefulWidget {
  const ChatViewListScreen({super.key});

  @override
  State<ChatViewListScreen> createState() => _ChatViewListScreenState();
}

class _ChatViewListScreenState extends State<ChatViewListScreen> {
  ChatViewListController? controller;

  // Assign the controller in didChangeDependencies
  // to ensure PrimaryScrollController is available.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller ??= ChatViewListController(
      initialChatList: Data.chatList(),
      scrollController: PrimaryScrollController.of(context),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null
          ? const Center(child: CircularProgressIndicator())
          : ChatViewList(
              controller: controller!,
              appbar: const ChatViewListAppBar(
                title: 'Breaking Bad',
              ),
              loadMoreChats: () async =>
                  await Future.delayed(const Duration(seconds: 2)),
              menuConfig: ChatMenuConfig(
                enabled: true,
                muteStatusCallback: (result) {
                  controller?.updateChat(
                    result.chat.id,
                    (previousChat) => previousChat.copyWith(
                      settings: previousChat.settings.copyWith(
                        muteStatus: result.status,
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                pinStatusCallback: (result) {
                  controller?.updateChat(
                    result.chat.id,
                    (previousChat) => previousChat.copyWith(
                      settings: previousChat.settings.copyWith(
                        pinStatus: result.status,
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
              config: ChatViewListConfig(
                enablePagination: true,
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
                searchConfig: ChatViewListSearchConfig(
                  textEditingController: TextEditingController(),
                  debounceDuration: const Duration(milliseconds: 300),
                  onSearch: (value) async {
                    if (value.isEmpty) {
                      return null;
                    }
                    final list = controller?.chatListMap.values
                        .where((chat) => chat.name
                            .toLowerCase()
                            .contains(value.toLowerCase()))
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
