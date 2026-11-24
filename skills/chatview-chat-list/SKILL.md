---
name: chatview-chat-list
description: >-
  Build and customize a conversation list (inbox) with chatview's ChatList
  widget and ChatListController: define chats with ChatListItem, ChatSettings
  and Message; add, update, remove, pin and mute chats; local or server search
  (SearchConfig); filter chips; long-press/right-click menus (ChatMenuConfig);
  tile styling (ListTileConfig, TypingStatusConfig, UnreadCountConfig,
  LastMessageTimeConfig, LastMessageStatusConfig, UserActiveStatusConfig,
  UserAvatarConfig); app bar, header and footer; empty/loading states
  (ListStateConfig); load-more pagination (LoadMoreConfig); and opening a chat
  from a tile. Use when adding, configuring or debugging a chat list, or when
  code uses ChatList, ChatListController, ChatListItem, ChatListAppBar or any
  of these configs.
---

# chatview: chat list

`ChatList` renders a sorted, animated list of conversations inside a
`CustomScrollView`. All data lives in a `ChatListController`: the widget only
shows what the controller emits, and every change (new message, pin, mute,
delete, search) goes through controller methods. `ChatListController`,
`ChatListItem`, `ChatSettings`, `Message` and `ChatUser` come from
`chatview_utils` and are re-exported by `package:chatview/chatview.dart`.

The chat screen itself is `ChatView`: use the `chatview-chat-screen` skill.
For a ready-made backend, see the `chatview_connect` package.

## Workflow

1. **Inspect the project first.** Find the state management (setState,
   Bloc, Riverpod…), the app's chat and user models, how it navigates
   (Navigator, go_router…), and where chats come from (REST, sockets,
   Firebase, `chatview_connect`). Map the app's models to `ChatListItem` in
   one place; don't replace them.
2. **Add the dependency** if missing: `flutter pub add chatview`. Never
   hard-code a version.
3. **Wire the controller and widget** as in **Basic**, then route backend
   events to controller methods (`references/examples.md`: events, search,
   pagination, menu actions, tile styling).
4. Look up options and defaults in `references/configurations.md`.
5. Run `flutter analyze`, then run the app: long-press a tile (right-click
   on desktop), search, and tap a tile.

## Rules

Controller and lifecycle:

- Import only `package:chatview/chatview.dart` (plus Flutter libraries).
- The controller emits its initial list once, on the next event-loop turn,
  over a broadcast stream with no last value. A `ChatList` that subscribes
  later shows a spinner until the next change. Create the controller in
  `initState` of the `State` whose `build` returns `ChatList`
  unconditionally; don't put `ChatList` behind a loader or in a tab that is
  unmounted and rebuilt (use `IndexedStack` or keep-alive).
- `controller.dispose()` also disposes the `ScrollController` unless
  `disposeOtherResources: false` (pass it for a shared controller such as
  `PrimaryScrollController.of(context)`). Dispose only after `ChatList` is
  unmounted; the owning `State.dispose` is fine.

Data:

- `ChatListItem.id` must be unique. `addChat` is for new ids only: an
  existing id duplicates the tile under the same internal `GlobalKey` and
  throws framework assertions.
  Use `updateChat(id, (chat) => chat.copyWith(...))` for existing chats
  (no-op for unknown ids) and `loadMoreChats(list)` to upsert many.
- Default order: pinned chats first, newest `settings.pinTime` first (no
  `pinTime` = after those with one), then the rest by newest
  `lastMessage.createdAt`. Set `pinTime: DateTime.now()` when pinning.
  Override with `chatSorter`, or keep insertion order with
  `sortEnable: false`.
- `Message.status` defaults to `MessageStatus.pending` (clock icon): set the
  real status, or filter with `lastMessageStatusConfig.showStatusFor`.
- `imageUrl` takes an http(s) URL, a `data:image/...;base64,` string or a
  file path, not an asset path (use `userAvatarConfig.avatarBuilder`).
- A non-empty `typingUsers` replaces the preview with "Name is
  typing...". Clear it when the message arrives.

Search and filters:

- `setSearchChats(list)` shows `list` until `clearSearch()`; filter chips
  and the search field share this state. `chatList` / `chatListMap` always
  hold all chats, unsorted.
- `SearchConfig.onSearch` returning a list shows it; `null` clears the
  search only when the query is empty, otherwise nothing changes. Call
  `controller.clearSearch()` yourself for a blank query.
- During a search, `addChat` doesn't update the screen until
  `clearSearch()`, and `loadMoreChats` shows the full list while
  `isSearching` stays `true`: skip load more while `controller.isSearching`.
- The app owns and disposes `SearchConfig.textEditingController`.

Widget:

- `appbar` must be a sliver (`ChatListAppBar`, `SliverAppBar`,
  `CupertinoSliverNavigationBar`); `header` and `footer` must not be.
- `ChatList.backgroundColor` only colors the tile in the mobile menu
  preview; set the screen color on the `Scaffold`. Defaults are light
  colors (white app bar and search field, black icons): set them for dark
  mode.
- `tileConfig.onTap(chat)` handles tile taps, but taps on the avatar never
  reach it: the avatar always consumes them. Set
  `userAvatarConfig.onProfileTap` to handle them (for example open the same
  chat) or replace the avatar with `userAvatarConfig.avatarBuilder`.
  `chatBuilder` replaces the whole tile, `onTap` included.
- The unread badge shows only for `unreadCount > 0`, as a **dot** by
  default; use `UnreadCountStyle.count` or `ninetyNinePlus` for numbers.
- The active-status dot shows for every chat, groups included; filter with
  `userActiveStatusConfig.showIndicatorFor` (receives only the status).
- `MessageType.custom` previews need `tileConfig.lastMessageTileBuilder`
  (debug assert); it replaces the preview of every chat, so handle all
  types.

Menu, states and pagination:

- Mobile: long-press opens a `CupertinoContextMenu`; web: long-press;
  desktop: right-click (popup menu). There is no menu unless `builder`,
  `actions` or a pin/mute/delete callback is set.
- Menu callbacks only report `result.status` (the toggled value): apply it
  with `updateChat`/`removeChat`. On mobile they run 800 ms after the tap
  (`callbackDelayDuration`).
- In custom `actions`, close the menu on mobile only, with
  `Navigator.of(context, rootNavigator: true).pop()`. On web/desktop the
  popup closes itself and an extra pop closes your screen.
- Empty list → `noChatsWidgetConfig`; empty search →
  `noSearchChatsWidgetConfig`. Both show a "Reload" button by default, which
  is disabled when no callback is set (always so in the search state): set
  `showDefaultReloadButton: false` or `stateConfig.onReloadButtonTap`. Loading and error states can't be driven
  through the controller; switch `noChatsWidgetConfig` from your own state.
- Load more needs `enablePagination: true` and `loadMoreChats`. It runs
  within 50 px of the end, one call at a time, until `isLastPage()` is
  `true`, and never if the first page doesn't fill the screen. Append with
  `controller.loadMoreChats(newChats)`.

## Examples

Basic: list with pin, mute and delete, and a tap that opens the chat.

```dart
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatListController _controller;

  @override
  void initState() {
    super.initState();
    // Created here, in the State whose build() returns ChatList.
    _controller = ChatListController(
      initialChatList: [
        ChatListItem(
          id: 'chat-1',
          name: 'Design team',
          chatRoomType: ChatRoomType.group,
          imageUrl: 'https://example.com/design-team.png',
          unreadCount: 3,
          lastMessage: Message(
            id: 'msg-41',
            message: 'Mockups are ready',
            createdAt: DateTime.now(),
            sentBy: 'user-2',
            status: MessageStatus.delivered,
          ),
        ),
        ChatListItem(
          id: 'chat-2',
          name: 'Ana',
          userActiveStatus: UserActiveStatus.online,
          settings: ChatSettings(
            pinStatus: PinStatus.pinned,
            pinTime: DateTime.now(),
          ),
        ),
      ],
      scrollController: ScrollController(),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // also disposes its ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ChatList paints no background
      body: ChatList(
        controller: _controller,
        appbar: const ChatListAppBar(titleText: 'Chats', centerTitle: false),
        tileConfig: ListTileConfig(
          onTap: _openChat,
          unreadCountConfig: const UnreadCountConfig(
            style: UnreadCountStyle.ninetyNinePlus,
          ),
        ),
        menuConfig: ChatMenuConfig(
          pinStatusCallback: (result) => _controller.updateChat(
            result.chat.id,
            (chat) => chat.copyWith(
              settings: chat.settings.copyWith(
                pinStatus: result.status,
                pinTime: result.status.isPinned ? DateTime.now() : null,
              ),
            ),
          ),
          muteStatusCallback: (result) => _controller.updateChat(
            result.chat.id,
            (chat) => chat.copyWith(
              settings: chat.settings.copyWith(muteStatus: result.status),
            ),
          ),
          deleteCallback: (chat) => _controller.removeChat(chat.id),
        ),
        stateConfig: const ListStateConfig(
          noChatsWidgetConfig: ChatViewStateWidgetConfiguration(
            title: 'No chats yet',
            showDefaultReloadButton: false,
          ),
        ),
      ),
    );
  }

  Future<void> _openChat(ChatListItem chat) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatScreen(chat: chat)),
    );
    if (!mounted) return;
    // Mark as read when the user comes back.
    _controller.updateChat(chat.id, (c) => c.copyWith(unreadCount: 0));
  }
}

// Stands in for the app's chat screen (see the chatview-chat-screen skill).
class ChatScreen extends StatelessWidget {
  const ChatScreen({required this.chat, super.key});

  final ChatListItem chat;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text(chat.name)));
}
```

## Troubleshooting

- Spinner forever, or the list stays empty until something changes →
  `ChatList` subscribed after the controller's first emission. Create the
  controller in the same `State` and keep `ChatList` mounted. Last resort:
  `controller.loadMoreChats(const [])` re-emits the current list.
- "AnimationController.stop() called after AnimationController.dispose()"
  → the controller was disposed while `ChatList` was still mounted.
- Menu pin/mute/delete does nothing → the callback must call
  `updateChat`/`removeChat`.
- Search results replaced by all chats while scrolling → `loadMoreChats`
  ran during a search.
- "expected a child of type RenderSliver" (or "RenderBox") → `appbar` must
  be a sliver; `header` and `footer` must not be.
- Translating built-in strings ("Search", "No Chats", "Pin", "typing"…) →
  `ChatViewLocale` with `PackageStrings`, covered by the
  `chatview-chat-screen` skill.
