# 0.0.x → 1.3.x

Apply the sections whose "from" range contains the app's current version, in
order. The "after" code is written against the **latest** chatview, so later
renames (for example `sendBy` → `sentBy` in 2.0.0) are already applied. Still
read every later reference for the releases you cross.

## From < 0.0.3

### Text field style moved to `TextFieldConfiguration`

Search: `hintText:`, `hintStyle:`, `textStyle:` directly inside
`SendMessageConfiguration(`.

Before:

```dart
sendMessageConfig: SendMessageConfiguration(
  hintText: 'Type here',
  hintStyle: TextStyle(color: Colors.grey),
  textStyle: TextStyle(color: Colors.black),
),
```

After:

```dart
sendMessageConfig: const SendMessageConfiguration(
  textFieldConfig: TextFieldConfiguration(
    hintText: 'Type here',
    hintStyle: TextStyle(color: Colors.grey),
    textStyle: TextStyle(color: Colors.black),
  ),
),
```

## From < 1.0.0

### `sender` / `receiver` removed from `ChatView`

Search: `sender:`, `receiver:` inside `ChatView(`.

In 1.0.0 these became `ChatView(currentUser:)` plus
`ChatController(chatUsers:)`; since 2.0.0 both users live on the controller.
Go straight to the latest form:

Before:

```dart
ChatView(
  sender: ChatUser(id: '1', name: 'Me'),
  receiver: ChatUser(id: '2', name: 'Alex'),
  chatController: ChatController(
    initialMessageList: messages,
    scrollController: ScrollController(),
  ),
)
```

After:

```dart
final chatController = ChatController(
  initialMessageList: messages,
  scrollController: ScrollController(),
  currentUser: const ChatUser(id: '1', name: 'Me'),
  otherUsers: const [ChatUser(id: '2', name: 'Alex')],
);

ChatView(
  chatController: chatController,
  chatViewState: ChatViewState.hasMessages,
)
```

Every `Message.sentBy` (`sendBy` before 2.0.0) must be the `id` of
`currentUser` or of a user in `otherUsers`, or `getUserFromId` throws.

### `chatViewState` is required

Search: `ChatView(` without `chatViewState:`.

Add `chatViewState: ChatViewState.hasMessages` (or `loading`, `noData`,
`error`). Drive it from the app's loading state: with `loading`, `noData` or
`error` the message list is not shown.

### `ChatViewAppBar` title renamed

Search: `ChatViewAppBar(` with `title:` / `titleTextStyle:`.

Before:

```dart
ChatViewAppBar(title: 'Alex', titleTextStyle: TextStyle(fontSize: 18))
```

After:

```dart
const ChatViewAppBar(
  chatTitle: 'Alex', // now required
  chatTitleTextStyle: TextStyle(fontSize: 18),
)
```

### `Message.reaction` is a `Reaction`, not a `String`

Search: `reaction:` in `Message(`, `.reaction` reads that expect a string.

Before:

```dart
Message(message: 'Hi', createdAt: now, sendBy: '2', reaction: '❤')
```

After:

```dart
Message(
  message: 'Hi',
  createdAt: now,
  sentBy: '2',
  reaction: Reaction(reactions: ['❤'], reactedUserIds: ['1']),
)
```

`reactions[i]` is the emoji of the user `reactedUserIds[i]`. Omit `reaction`
for none.

### `ChatController.setReaction` takes named arguments and a user id

Search: `setReaction(`.

Before: `chatController.setReaction('❤', message.id);`

After:

```dart
chatController.setReaction(
  emoji: '❤',
  messageId: message.id,
  userId: chatController.currentUser.id,
);
```

Calling it again with the same emoji for the same user removes the reaction.

### `MessageType` gained values

`MessageType` is now `image, text, voice, custom`. Exhaustive `switch`
statements on it need cases for `custom` (1.0.0) and `voice` (1.1.0).

## From < 1.1.0

### `ReactionPopupConfiguration.onEmojiTap` removed

Search: `onEmojiTap:`.

The package stores the reaction itself (`ChatController.setReaction`). Delete
`onEmojiTap`, and any `setReaction` call inside it. To sync reactions to a
backend, use `userReactionCallback` (since 1.2.1):

```dart
reactionPopupConfig: ReactionPopupConfiguration(
  userReactionCallback: (message, emoji) {
    // Send the reaction to your backend.
  },
),
```

Set `overrideUserReactionCallback: true` only if the app updates
`Message.reaction` itself; then the reaction popup no longer calls
`setReaction`. Double-tap-to-like still calls `setReaction` (and does not fire
`userReactionCallback`) unless you set
`FeatureActiveConfig(enableDoubleTapToLike: false)` or provide
`ChatBubbleConfiguration.onDoubleTap`.

### Swipe-to-see-time and pagination moved to `FeatureActiveConfig`

Search: `horizontalDragToShowMessageTime:` (in `ChatBackgroundConfiguration`)
and `enablePagination:` (on `ChatView(`).

Before:

```dart
ChatView(
  enablePagination: true,
  chatBackgroundConfig: ChatBackgroundConfiguration(
    horizontalDragToShowMessageTime: false,
  ),
  // ...
)
```

After:

```dart
ChatView(
  featureActiveConfig: const FeatureActiveConfig(
    enablePagination: true,
    enableSwipeToSeeTime: false,
  ),
  // ...
)
```

## From < 1.2.0

### `showReceiverProfileCircle` removed

Search: `showReceiverProfileCircle:`.

Replace with `featureActiveConfig: FeatureActiveConfig(enableOtherUserProfileAvatar: false)`
(default `true`). The CHANGELOG lists this under 1.1.0, but the parameter was
removed in 1.2.0+1.

### `onSendTap` receives the message type; image and voice go through it

Search: `onSendTap:`, `onRecordingComplete:`, `onImageSelected:`.

`onSendTap` gained a third `MessageType` parameter. `ChatView.onRecordingComplete`
and `ImagePickerIconsConfiguration.onImageSelected` were removed: recorded
audio and picked images arrive in `onSendTap` with `MessageType.voice` /
`MessageType.image`, and the first argument is the file path.

Before:

```dart
ChatView(
  onSendTap: (message, replyMessage) => send(message, replyMessage),
  onRecordingComplete: (path, replyMessage) => sendVoice(path),
  sendMessageConfig: SendMessageConfiguration(
    imagePickerIconsConfig: ImagePickerIconsConfiguration(
      onImageSelected: (path, error) => sendImage(path),
    ),
  ),
  // ...
)
```

After:

```dart
ChatView(
  onSendTap: (message, replyMessage, messageType) {
    chatController.addMessage(
      Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message, // text, or file path for image/voice
        createdAt: DateTime.now(),
        sentBy: chatController.currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
    );
  },
  // ...
)
```

## From < 1.3.0

- The Dart SDK minimum rose from 2.12 to 3.0.3 (and later to 3.4.0, see
  `SKILL.md`).
- `ChatView.showTypingIndicator` was deprecated and is removed in 2.0.0:
  follow `references/1.x-to-2.0.0.md`.
