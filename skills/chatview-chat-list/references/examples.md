# chatview chat list: more examples

Every example uses the imports of **Basic** in `SKILL.md`
(`package:chatview/chatview.dart` and `package:flutter/material.dart`).
Functions take the `ChatListController` as a parameter so they fit any state
management; call them from wherever the app receives the event.

## Backend events

Map socket, push or stream events to controller calls:

```dart
// New chat from the backend, or a full refresh of one chat.
void upsertChat(ChatListController controller, ChatListItem chat) {
  if (controller.chatListMap.containsKey(chat.id)) {
    controller.updateChat(chat.id, (_) => chat);
  } else {
    controller.addChat(chat); // only for ids not in the list yet
  }
}

// Incoming message: moves the chat up (sorting uses lastMessage.createdAt).
void onMessageReceived(
  ChatListController controller,
  String chatId,
  Message message,
) {
  controller.updateChat(
    chatId,
    (chat) => chat.copyWith(
      lastMessage: message,
      unreadCount: (chat.unreadCount ?? 0) + 1,
      typingUsers: const <ChatUser>{},
    ),
  );
}

// Typing indicator: a non-empty set replaces the last-message preview.
void onTypingChanged(
  ChatListController controller,
  String chatId,
  Set<ChatUser> typingUsers,
) {
  controller.updateChat(
    chatId,
    (chat) => chat.copyWith(typingUsers: typingUsers),
  );
}

void onPresenceChanged(
  ChatListController controller,
  String chatId, {
  required bool online,
}) {
  controller.updateChat(
    chatId,
    (chat) => chat.copyWith(
      userActiveStatus:
          online ? UserActiveStatus.online : UserActiveStatus.offline,
    ),
  );
}
```

## Search and filter chips

Pass a `SearchConfig` to `ChatList(searchConfig: ...)` and the chips to
`ChatList(header: ...)`. The app owns and disposes the
`TextEditingController`.

```dart
// Local search over the chats already in the controller.
SearchConfig localSearchConfig({
  required ChatListController controller,
  required TextEditingController textController,
}) {
  return SearchConfig(
    textEditingController: textController,
    debounceDuration: const Duration(milliseconds: 300),
    onSearch: (query) {
      final text = query.trim().toLowerCase();
      if (text.isEmpty) {
        controller.clearSearch();
        return null;
      }
      return controller.chatList
          .where((chat) => chat.name.toLowerCase().contains(text))
          .toList();
    },
  );
}

// Server search: results replace the list until the query is cleared.
SearchConfig serverSearchConfig({
  required ChatListController controller,
  required TextEditingController textController,
  required Future<List<ChatListItem>> Function(String query) searchChats,
}) {
  return SearchConfig(
    textEditingController: textController,
    debounceDuration: const Duration(milliseconds: 400),
    onSearch: (query) async {
      final text = query.trim();
      if (text.isEmpty) {
        controller.clearSearch();
        return null;
      }
      final results = await searchChats(text);
      // Drop stale responses: null with a non-empty query changes nothing.
      return textController.text.trim() == text ? results : null;
    },
  );
}

// Filter chips in the header share the search state with the search field.
Widget filterChips(ChatListController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Wrap(
      spacing: 8,
      children: [
        ActionChip(
          label: const Text('All'),
          onPressed: controller.clearSearch,
        ),
        ActionChip(
          label: const Text('Unread'),
          onPressed: () => controller.setSearchChats(
            controller.chatList
                .where((chat) => (chat.unreadCount ?? 0) > 0)
                .toList(),
          ),
        ),
        ActionChip(
          label: const Text('Groups'),
          onPressed: () => controller.setSearchChats(
            controller.chatList
                .where((chat) => chat.chatRoomType == ChatRoomType.group)
                .toList(),
          ),
        ),
      ],
    ),
  );
}
```

## Pagination with a first-page loader

The list starts empty and stays mounted; the empty state shows a spinner
until the first page arrives, because the controller can't show its own
loading state on demand.

```dart
class PaginatedChatList extends StatefulWidget {
  const PaginatedChatList({required this.fetchPage, super.key});

  /// Returns an empty list when there are no more chats.
  final Future<List<ChatListItem>> Function(int page) fetchPage;

  @override
  State<PaginatedChatList> createState() => _PaginatedChatListState();
}

class _PaginatedChatListState extends State<PaginatedChatList> {
  late final ChatListController _controller;
  var _page = 0;
  var _hasMore = true;
  var _loadingFirstPage = true;

  @override
  void initState() {
    super.initState();
    _controller = ChatListController(
      initialChatList: const [],
      scrollController: ScrollController(),
    );
    _loadMore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    // loadMoreChats() would replace visible search results with all chats.
    if (_controller.isSearching) return;
    final chats = await widget.fetchPage(_page);
    if (!mounted) return;
    _page++;
    _hasMore = chats.isNotEmpty;
    _controller.loadMoreChats(chats);
    if (_loadingFirstPage) setState(() => _loadingFirstPage = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatList(
        controller: _controller,
        appbar: const ChatListAppBar(titleText: 'Chats'),
        enablePagination: true,
        loadMoreChats: _loadMore,
        isLastPage: () => !_hasMore,
        loadMoreConfig: const LoadMoreConfig(color: Colors.blue),
        stateConfig: ListStateConfig(
          // The empty state doubles as the first-page loader.
          noChatsWidgetConfig: _loadingFirstPage
              ? const ChatViewStateWidgetConfiguration(
                  widget: CircularProgressIndicator(),
                )
              : const ChatViewStateWidgetConfiguration(
                  title: 'No chats yet',
                  showDefaultReloadButton: false,
                ),
        ),
      ),
    );
  }
}
```

## Custom menu action

Needs two more Flutter imports. Pass the result to
`ChatList(menuConfig: ...)`, with the screen's `context`.

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

ChatMenuConfig menuWithArchive({
  required BuildContext context,
  required ChatListController controller,
  required void Function(ChatListItem chat) archiveChat,
}) {
  final isMobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  return ChatMenuConfig(
    actions: (chat) => [
      CupertinoContextMenuAction(
        trailingIcon: Icons.archive_outlined,
        onPressed: () {
          // Mobile: close the context menu route yourself.
          // Web/desktop: the popup menu has already closed; popping again
          // would close the chat list screen.
          if (isMobile) Navigator.of(context, rootNavigator: true).pop();
          archiveChat(chat);
          controller.removeChat(chat.id);
        },
        child: const Text('Archive'),
      ),
    ],
    deleteCallback: (chat) => controller.removeChat(chat.id),
  );
}
```

## Tile customization

Pass to `ChatList(tileConfig: ...)`. All options and defaults:
`references/configurations.md`.

```dart
final tileConfig = ListTileConfig(
  showUserActiveStatusIndicator: true,
  userActiveStatusConfig: UserActiveStatusConfig(
    showIndicatorFor: (status) => status.isOnline,
  ),
  // `avatarBuilder: (chat) => ...` would replace the whole avatar, including
  // the active-status dot, and make `radius` and `showIndicatorFor` inert.
  userAvatarConfig: const UserAvatarConfig(radius: 26),
  typingStatusConfig: const TypingStatusConfig(showUserNames: true),
  timeConfig: const LastMessageTimeConfig(dateFormatPattern: 'dd MMM yyyy'),
  lastMessageStatusConfig: LastMessageStatusConfig(
    showStatusFor: (message) => message.sentBy == 'current-user-id',
  ),
  unreadCountConfig: const UnreadCountConfig(
    style: UnreadCountStyle.count,
    backgroundColor: Colors.green,
  ),
  // Required when a lastMessage has MessageType.custom; replaces the
  // preview (and status icon) for every chat.
  lastMessageTileBuilder: (chat) {
    final message = chat.lastMessage!;
    return Text(
      switch (message.messageType) {
        MessageType.text => message.message,
        MessageType.image => 'Photo',
        MessageType.voice => 'Voice message',
        MessageType.custom => 'Shared a location',
      },
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  },
);
```
