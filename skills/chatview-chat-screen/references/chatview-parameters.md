# ChatView, ChatController and data models

Defaults come from the constructors in chatview 3.x and chatview_utils 3.x.
Configuration classes are in `references/configurations.md`.

## ChatView

| Parameter | Type | Default | Notes |
|---|---|---|---|
| `chatController` | `ChatController` | required | Not disposed by `ChatView` |
| `chatViewState` | `ChatViewState` | required | `hasMessages`, `noData`, `loading`, `error`. Only `hasMessages` shows the list |
| `onSendTap` | `StringMessageCallBack?` | `null` | `(String message, ReplyMessage replyMessage, MessageType messageType)`, for text, image and voice. Not called with `sendMessageBuilder`. The list scrolls to the newest message after it |
| `onEditTap` | `EditMessageCallback?` | `null` | `(Message message, Message updatedMessage)`; `updatedMessage` has the new text and `updatedAt: DateTime.now()`. Needs `enableMessageEditing`; Edit is offered only on the current user's text messages and not with `sendMessageBuilder`. Without a callback, Send clears the field and edits nothing |
| `loadMoreData` | `PaginationCallback?` | `null` | `Future<void> Function(ChatPaginationDirection direction, Message message)`; `message` is the oldest (`previous`) or newest (`next`) message shown. Needs `enablePagination` |
| `isLastPage` | `ValueGetter<bool>?` | `null` | `true` stops pagination in both directions |
| `loadingWidget` | `Widget?` | `null` | Pagination loader |
| `appBar` | `Widget?` | `null` | Any widget, usually `ChatViewAppBar`, placed above the list |
| `featureActiveConfig` | `FeatureActiveConfig` | `const FeatureActiveConfig()` | Feature toggles |
| `sendMessageConfig` | `SendMessageConfiguration` | `const SendMessageConfiguration()` | Composer. Pass `textFieldConfig` |
| `sendMessageBuilder` | `ReplyMessageWithReturnWidget?` | `null` | `Widget Function(ReplyMessage?)`: replaces the whole composer |
| `replyMessageBuilder` | `CustomViewForReplyMessage?` | `null` | `Widget Function(BuildContext, ReplyMessage)`: the "replying to" bar above the built-in composer (unused with `sendMessageBuilder`) |
| `chatBackgroundConfig` | `ChatBackgroundConfiguration?` | `const ChatBackgroundConfiguration()` | Background, separators, sorting |
| `chatBubbleConfig` | `ChatBubbleConfiguration?` | `null` | Bubbles |
| `messageConfig` | `MessageConfiguration?` | `null` | Image, voice, emoji, reactions, custom builder |
| `repliedMessageConfig` | `RepliedMessageConfiguration?` | `null` | Reply preview inside bubbles. `loadOldReplyMessage` is required |
| `swipeToReplyConfig` | `SwipeToReplyConfiguration?` | `null` | |
| `replyPopupConfig` | `ReplyPopupConfiguration?` | `null` | Long-press SnackBar (Reply, Edit, Unsend, Report, More) |
| `reactionPopupConfig` | `ReactionPopupConfiguration?` | `null` | Long-press emoji row |
| `profileCircleConfig` | `ProfileCircleConfiguration?` | `null` | Avatars next to bubbles |
| `typeIndicatorConfig` | `TypeIndicatorConfiguration` | `const TypeIndicatorConfiguration()` | |
| `chatViewStateConfig` | `ChatViewStateConfiguration?` | `const ChatViewStateConfiguration()` | Loading, empty and error screens |
| `replySuggestionsConfig` | `ReplySuggestionsConfig?` | `null` | |
| `scrollToBottomButtonConfig` | `ScrollToBottomButtonConfig?` | `null` | Needs `enableScrollToBottomButton`. The button is part of the built-in composer, so it is not shown with `sendMessageBuilder` |
| `emojiPickerSheetConfig` | `Config?` | `null` | emoji_picker_flutter `Config` |
| `onChatListTap` | `VoidCallback?` | `null` | Tap on the message list |

Static helpers, called with a `context` below `ChatView` (for example inside
`trailingActions` or `sendMessageBuilder`):
`ChatView.getReplyMessage(context)` returns the reply being composed
(`ReplyMessage?`: an empty `ReplyMessage()` when not replying, `null` when
`enableTextField` is false), and
`ChatView.closeReplyMessageView(context)` clears the reply and edit bars.

## ChatController

```text
ChatController({
  required List<Message> initialMessageList, // growable, oldest first
  required ScrollController scrollController, // disposed by dispose()
  required List<ChatUser> otherUsers,
  required ChatUser currentUser,
})
```

| Member | Behavior |
|---|---|
| `initialMessageList` | The live list, mutated in place. After changing it directly, call `messageStreamController.sink.add(initialMessageList)` |
| `addMessage(Message)` | Reverts a `replaceMessageList` list, appends and refreshes. Does not scroll itself (the built-in Send scrolls after `onSendTap`) |
| `updateMessage({required messageId, required newMessage})` | Replaces by id. Throws `Exception('Message Not Found!')` |
| `loadMoreData(List<Message>, {direction = previous})` | `previous` inserts at index 0, `next` appends. On `next`, if the page overlaps only part of the list cached by `replaceMessageList`, the cached messages it lacks are appended too and the cache is dropped. With no overlap or a full overlap the cache is kept |
| `replaceMessageList(List<Message>)` | Shows a temporary list (e.g. around an old replied message). The previous list is cached and restored by `revertToInitialMessageList({shouldStream = true})`, `addMessage` or `scrollToLastMessage()`; `canRevertToInitialMessageList` is true while a cache exists. Reverting does not clear the cache, so every later `addMessage` or `scrollToLastMessage()` resets the list to that snapshot again and drops messages added after the first revert |
| `setReaction({required emoji, required messageId, required userId})` | Adds, changes or (same emoji) removes that user's reaction, mutating the message's `Reaction` lists in place (they must be growable, not `const []`). Throws `Exception('Message Not Found!')`. Rebuilds the message without `updatedAt`, `update` and `voiceMessageDuration` |
| `setTypingIndicator = bool` / `showTypingIndicator` / `typingIndicatorNotifier` | Typing bubble at the bottom of the list |
| `addReplySuggestions(List<SuggestionItemData>)` / `removeReplySuggestions()` / `newSuggestions` | Quick replies. Auto-removed on send and on tapping a suggestion while `ReplySuggestionsConfig.autoDismissOnSelection` is true (default) |
| `scrollToLastMessage({waitFor = 300 ms, scrollFor = 300 ms})` | Waits `waitFor`, reverts a `replaceMessageList` list, then animates to the newest message over `scrollFor` (or resets the list when it is too far to animate). No-op without scroll clients |
| `currentUser`, `otherUsers`, `otherUsersMap` | Users. `otherUsers` and `otherUsersMap` return copies |
| `getUserFromId(id)` | Returns `currentUser` or an other user. Throws `Exception('User with ID $userId not found!')` |
| `updateOtherUser(ChatUser)` | Adds or replaces a participant by id. Notifies nothing; the change shows on the next rebuild |
| `messageStreamController` | Broadcast stream the list listens to |
| `dispose()` | Disposes notifiers and `scrollController`, closes the stream |

There is no `removeMessage`. Remove from `initialMessageList`, then push the
list to `messageStreamController.sink`.

## Message

| Field | Type | Default | Notes |
|---|---|---|---|
| `id` | `String` | `''` | Must be unique and non-empty |
| `message` | `String` | required | Text, image URL/path/base64, voice file path, or custom payload |
| `createdAt` | `DateTime` | required | Used for date separators, grouping and optional sorting |
| `sentBy` | `String` | required | A `ChatUser.id` |
| `messageType` | `MessageType` | `text` | `text`, `image`, `voice` (Android/iOS only), `custom` |
| `replyMessage` | `ReplyMessage` | `const ReplyMessage()` | Empty = not a reply |
| `status` | `MessageStatus` | `pending` | `pending`, `delivered`, `read`, `undelivered`. Read with `status`, change with the setter `message.setStatus = MessageStatus.read`, listen with `statusNotifier` |
| `reaction` | `Reaction` | empty | Constructor takes `Reaction?`; `null` gives empty growable lists. `Reaction(reactions: [...emojis], reactedUserIds: [...ids])`, parallel lists |
| `voiceMessageDuration` | `Duration?` | `null` | `null` lets the player detect it |
| `updatedAt` | `DateTime?` | `null` | Non-null shows "Edited" above text bubbles. The `updateAt` parameter and getter are deprecated aliases |
| `update` | `Map<String, dynamic>?` | `null` | Free-form extra data |

`copyWith(...)` (pass `forceNullValue: true` to null out
`voiceMessageDuration`, `updatedAt` and `update` when not passed),
`toJson({includeNullValues = true})` (writes the date both as `updated_at`
and `update_at`; `false` omits empty and null optional keys), and
`Message.fromJson(json)` with these keys: `id`, `message`, `sentBy` (missing →
`''`), `createdAt` (ISO 8601; missing or invalid → `DateTime.now()`), `status`
(enum name, case-insensitive; missing or unknown → `pending`), `message_type`
(enum name, case-insensitive; missing or unknown → `text`), `reply_message`
(map; otherwise empty), `reaction` (map with `reactions`, `reactedUserIds`;
otherwise empty), `voice_message_duration` (microseconds; missing →
`Duration.zero`), `updated_at` (falls back to `update_at`), `update` (map;
otherwise `null`).

## ReplyMessage

| Field | Default | Notes |
|---|---|---|
| `messageId` | `''` | Id of the message replied to |
| `message` | `''` | Its content (text, image path, …) |
| `replyBy` | `''` | Who is replying (a user id) |
| `replyTo` | `''` | Author of the original message (a user id) |
| `messageType` | `text` | Type of the original message |
| `voiceMessageDuration` | `null` | |

`ReplyMessage.fromJson` and `toJson` keys: `id`, `message`, `replyBy`,
`replyTo`, `message_type`, `voiceMessageDuration` (microseconds; missing →
`Duration.zero`). Missing strings become `''`, a missing or unknown
`message_type` becomes `text`.

## ChatUser

| Field | Default | Notes |
|---|---|---|
| `id` | required | Unique |
| `name` | required | Shown above incoming bubbles (`enableOtherUserName`) and in replies |
| `profilePhoto` | `null` | URL, asset path or base64, per `imageType` |
| `imageType` | `ImageType.network` | `network`, `asset`, `base64` |
| `defaultAvatarImage` | a GitHub-hosted image URL | Passed to the avatar widget but never displayed: a null or empty `profilePhoto` renders no avatar |
| `assetImageErrorBuilder`, `networkImageErrorBuilder`, `networkImageProgressIndicatorBuilder` | `null` | |

`ChatUser` is immutable: use `copyWith` and `controller.updateOtherUser`.
`copyWith` does not copy the three builders; pass them to a new `ChatUser`
instead.

## Other enums and types

- `ChatPaginationDirection.previous` / `.next` (`isPrevious`, `isNext`).
- `TypeWriterStatus.typing` / `.typed`, from
  `TextFieldConfiguration.onMessageTyping`. Use it to send your own typing
  events.
- `SuggestionItemData(text: ..., config: SuggestionItemConfig(...))`.
- `ShowReceiptsIn.all` / `.lastMessage`,
  `SendingMessageAnimationType.slideOut` / `.textLabel` / `.clockToTick`.
