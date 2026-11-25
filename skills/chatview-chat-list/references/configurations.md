# chatview chat list: configuration reference

Defaults are the effective values: the constructor default in `chatview` or
`chatview_utils`, or the widget's fallback for `null` (`null` → …).
`primaryColor` is chatview's `Color(0xffEE5366)`.

## ChatListController

| Constructor parameter | Default | Notes |
|---|---|---|
| `initialChatList` | required | Emitted once, on the next event-loop turn |
| `scrollController` | required | Used by the list's `CustomScrollView` |
| `disposeOtherResources` | `true` | `dispose()` also disposes `scrollController` |
| `sortEnable` | `true` | Pinned first (newest `pinTime`), then newest `lastMessage.createdAt` |
| `chatSorter` | `null` | `int Function(ChatListItem, ChatListItem)`, replaces the default sort |

| Member | Behavior |
|---|---|
| `addChat(chat)` | New id only (an existing id breaks the list). Not shown while searching |
| `updateChat(id, (old) => new)` | Updates the chat and the search result; no-op for unknown ids |
| `removeChat(id)` | While searching, does nothing for chats not in the results |
| `loadMoreChats(list)` | Upserts by id and re-emits the **full** list, even during a search |
| `setSearchChats(list)` | Shows `list` (sorted) until `clearSearch()`; sets `isSearching` |
| `clearSearch()` | Shows the full list again |
| `chatList` / `chatListMap` | All chats, unsorted, never the search results |
| `isSearching` | `true` between `setSearchChats` and `clearSearch` |
| `dispose()` | Call after `ChatList` is unmounted |

## Data models

| `ChatListItem` field | Default | Notes |
|---|---|---|
| `id`, `name` | required | `id` unique |
| `chatRoomType` | `ChatRoomType.oneToOne` | or `group`; not read by `ChatList` (for your own filters) |
| `lastMessage` | `null` | `Message`; no time or preview without it |
| `imageUrl` | `null` | http(s) URL, `data:image/...;base64,` or file path; not assets |
| `unreadCount` | `null` | Badge only when `> 0` |
| `userActiveStatus` | `UserActiveStatus.offline` | `online` / `offline` |
| `typingUsers` | `{}` | `Set<ChatUser>`; non-empty replaces the preview |
| `settings` | `ChatSettings()` | Pin and mute |

| `ChatSettings` field | Default |
|---|---|
| `pinStatus` | `PinStatus.unpinned` |
| `pinTime` | `null` (set it when pinning, for ordering) |
| `muteStatus` | `MuteStatus.unmuted` |

`Message` (used as `lastMessage`): `message`, `createdAt`, `sentBy` required;
`id` `''`, `messageType` `MessageType.text`, `status` **`MessageStatus.pending`**.
`ChatUser` (for `typingUsers`): `id`, `name` required.

Both `ChatListItem.copyWith` and `ChatSettings.copyWith` leave omitted fields
unchanged and accept `null` for nullable fields.

## ChatList

| Parameter | Default | Notes |
|---|---|---|
| `controller` | required | |
| `appbar` | `null` | Must be a sliver (`ChatListAppBar`, `SliverAppBar`…) |
| `searchConfig` | `null` | No search field when null |
| `header` / `footer` | `null` | Box widgets, above / below the chats |
| `tileConfig` | `ListTileConfig()` | |
| `chatBuilder` | `null` | `(context, chat)`; replaces the tile, `tileConfig` unused |
| `separatorBuilder` | `null` | `(context, index)` |
| `menuConfig` | `ChatMenuConfig()` | |
| `stateConfig` | `ListStateConfig()` | |
| `enablePagination` | `false` | |
| `loadMoreChats` | `null` | `Future<void> Function()` |
| `isLastPage` | `null` | `bool Function()`; `true` stops load more |
| `loadMoreConfig` | `LoadMoreConfig()` | |
| `backgroundColor` | `Colors.white` | Only the tile in the mobile menu preview |
| `extraSpaceAtLast` | `32` | Bottom spacing |
| `scrollViewKeyboardDismissBehavior` | `onDrag` | |

## ChatListAppBar

Builds a `SliverAppBar`. `titleText` (String) or `title` (Widget, wins);
`titleTextStyle` 20 bold black; `titleMaxLines` 1; `titleTextOverflow`
ellipsis; `pinned` `true`; `centerTitle` `true`; `backgroundColor`
`Colors.white`; `surfaceTintColor` `Colors.black`; `scrolledUnderElevation`
1.0; `automaticallyImplyLeading` `true`; `primary` `true`; `stretch` / `snap`
`false`; `leading`, `actions`.

## ListTileConfig

| Field | Default | Notes |
|---|---|---|
| `onTap` | `null` | `(chat)`; avatar taps don't reach it |
| `padding` | `EdgeInsets.symmetric(vertical: 6, horizontal: 8)` | |
| `middleWidgetPadding` | `EdgeInsets.symmetric(horizontal: 12)` | Around name and preview |
| `userNameTextStyle` | `null` → 16 bold | |
| `userNameMaxLines` / `userNameTextOverflow` | `1` / ellipsis | |
| `userNameBuilder` | `null` | `(chat) → Widget` |
| `lastMessageTextStyle` | `TextStyle(fontSize: 14, fontWeight: FontWeight.normal)` | |
| `highlightTextStyle` | bold | Merged into `lastMessageTextStyle` when `unreadCount > 0`; `null` disables, and so does a `null` `lastMessageTextStyle` |
| `lastMessageMaxLines` / `lastMessageTextOverflow` | `1` / ellipsis | |
| `lastMessageIconColor` | `Colors.black` | Photo / mic icons |
| `lastMessageTileBuilder` | `null` | `(chat) → Widget`; replaces preview and status icon; required for `MessageType.custom` |
| `trailingBuilder` | `null` | Replaces time, pin, mute and unread badge |
| `showLastMessageStatus` | `true` | |
| `lastMessageStatusConfig` | `LastMessageStatusConfig()` | |
| `showUserActiveStatusIndicator` | `true` | Applies to groups too |
| `userActiveStatusConfig` | `UserActiveStatusConfig()` | |
| `userAvatarConfig` | `UserAvatarConfig()` | |
| `typingStatusConfig` | `TypingStatusConfig()` | |
| `timeConfig` | `LastMessageTimeConfig()` | |
| `unreadCountConfig` | `UnreadCountConfig()` | |
| `pinIconConfig` / `muteIconConfig` | size 18 | `widget`, `size`, `color`; shown when pinned / muted |

### Sub-configs

| Config | Field | Default / notes |
|---|---|---|
| `TypingStatusConfig` | `prefix` / `suffix` | `null` / `'...'` around the locale `typing` |
| | `showUserNames` | One typer is always named. `false`: two typers "Ann & 1 other is typing...", three or more "Ann & N others are typing...". `true`: up to three names, four or more "Ann, Bob & N others are typing..." |
| | `textStyle` | 14, w400, italic |
| | `maxLines` / `overflow` | `1` / ellipsis |
| | `textBuilder` | `(chat) → String?`; `null` falls back to the default text |
| | `widgetBuilder` | `(chat) → Widget?` |
| `LastMessageTimeConfig` | `dateFormatPattern` | `'dd/MM/yyyy'`, used for dates 7+ days old (today: `hh:mm a`, else weekday) |
| | `timeBuilder` | `(DateTime) → Widget` |
| | `textStyle` | `null` → size 12 |
| | `spaceBetweenTimeAndUnreadCount` | `5` |
| | `maxLines` / `overflow` | `1` / ellipsis |
| `LastMessageStatusConfig` | `showStatusFor` | `(Message) → bool`, e.g. only the current user's messages |
| | `icon` | `(status) → IconData`; default read/delivered `done_all`, pending `schedule`, undelivered `error_outline` |
| | `color` | `(status) → Color`; default read green, undelivered red, others grey |
| | `size` | `14` |
| | `statusBuilder` | `(status) → Widget`, replaces the icon |
| `UnreadCountConfig` | `style` | `UnreadCountStyle.dot`; also `count`, `ninetyNinePlus`, `none` |
| | `backgroundColor` / `textColor` | `primaryColor` / `Colors.white` |
| | `fontSize` | `12` |
| | `width` / `height` | dot `width` 12 (`height` unused); badge min 20 x 20 |
| | `decoration`, `textStyle`, `maxLines` 1, `textScaler` `noScaling` | `decoration` replaces `backgroundColor`; `textStyle` replaces `textColor` and `fontSize` |
| | `countWidgetBuilder` | `(count) → Widget`; when set, shown even for 0 |
| `UserActiveStatusConfig` | `showIndicatorFor` | `(UserActiveStatus) → bool` |
| | `color` | `(status) → Color`; default online green, offline grey |
| | `alignment` | `UserActiveStatusAlignment.bottomRight` |
| | `size` / `shape` / `border` | `14` / circle / 2 px white |
| | `statusBuilder` | Declared but never used by the tile |
| `UserAvatarConfig` | `radius` | `24` |
| | `backgroundColor`, `onBackgroundImageError` | `onBackgroundImageError` fails a `CircleAvatar` assert for chats without `imageUrl` |
| | `onProfileTap` | `(chat)`; set it or avatar taps do nothing |
| | `avatarBuilder` | `(chat) → Widget`; replaces avatar and status dot |

## ChatMenuConfig

| Field | Default | Notes |
|---|---|---|
| `enabled` | `true` | |
| `pinStatusCallback` | `null` | `(({ChatListItem chat, PinStatus status}) result)`, new status |
| `muteStatusCallback` | `null` | Same shape with `MuteStatus` |
| `deleteCallback` | `null` | `(chat)`; destructive "Delete Chat" item |
| `actions` | `null` | `(chat) → List<Widget>`, added before the built-in items; use `CupertinoContextMenuAction` |
| `builder` | `null` | `(context, chat, child) → Widget`; replaces the whole menu |
| `callbackDelayDuration` | 800 ms | Mobile only; `null` runs at once |
| `pinStatusIcon` / `muteStatusIcon` | `null` | `(status) → IconData`; defaults `push_pin(_outlined)`, `notifications(_off)_outlined` |
| `deleteIcon` | `null` → `Icons.delete_forever` | |
| `textStyle`, `maxLines` 1, `overflow` ellipsis | | Item text |
| `highlightColor` | `Color(0x1AEE5366)` | Web/desktop tile highlight while open |

## SearchConfig

| Field | Default | Notes |
|---|---|---|
| `textEditingController` | required | App disposes it |
| `onSearch` | `null` | `(query) → FutureOr<List<ChatListItem>?>` |
| `debounceDuration` | `null` | No debounce when null |
| `hintText` | locale "Search" | `hintStyle` default 16, grey |
| `padding` | `EdgeInsets.all(10)` | Around the field |
| `contentPadding` | `EdgeInsets.symmetric(horizontal: 6)` | |
| `textFieldBackgroundColor` | `Colors.white` | |
| `borderRadius` | `BorderRadius.circular(27)` | |
| `border` | `null` → transparent outline | |
| `prefixIcon` | `Icon(Icons.search)` | |
| `suffixIcon` | `null` | Replaces the clear button |
| `clearIcon` | `Icon(Icons.clear)` | Shown once the user types; clears text, unfocuses and calls `clearSearch()` |
| `decoration` | `null` | Replaces the whole `InputDecoration` |
| `textInputAction` | `TextInputAction.search` | |
| `textCapitalization` | `none` | |
| `maxLines` | `null` | Passed to `TextField`: the field grows with the text and gets a multiline keyboard; set `1` for one line |
| `textStyle`, `minLines`, `maxLength`, `textInputType`, `inputFormatters`, `enabled`, `onTapOutside` | `null` | Passed to `TextField` |

## ListStateConfig

| Field | Shown when |
|---|---|
| `noChatsWidgetConfig` | List empty, not searching |
| `noSearchChatsWidgetConfig` | Search active with no results (title default "No search results") |
| `loadingWidgetConfig` | Before the first emission only |
| `errorWidgetConfig` | Only if `chatSorter` throws; the controller emits no errors |
| `onReloadButtonTap` | Reload button in the no-chats and error states |

`ChatViewStateWidgetConfiguration`: `title`, `subTitle`, `titleTextStyle`
(size 22), `subTitleTextStyle`, `imageWidget`, `widget` (replaces
everything), `loadingWidget`, `loadingIndicatorColor`,
`loadingIndicatorSize` 36, `reloadButton`, `showDefaultReloadButton`
`true`, `reloadButtonColor` `primaryColor`.

## LoadMoreConfig

`loadMoreBuilder` (widget shown while loading; default adaptive spinner),
`color` `primaryColor`, `size` 36, `padding`
`EdgeInsets.symmetric(vertical: 16)`.
