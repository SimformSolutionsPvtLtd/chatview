---
name: chatview-chat-screen
description: >-
  Build and customize a 1:1 or group chat screen with the chatview package:
  ChatView and ChatController, ChatUser and Message models, onSendTap for
  text, image and voice messages, custom messages, replies, reactions, message
  editing (onEditTap), text-field actions (CameraActionButton,
  GalleryActionButton, OverlayActionButton), two-way pagination (loadMoreData,
  isLastPage), ChatViewState, typing indicator, reply suggestions,
  FeatureActiveConfig, ChatViewAppBar, chat bubble theming and ChatViewLocale.
  Also covers pushing backend events into the controller (addMessage,
  updateMessage, setReaction, setTypingIndicator, message status). Use when
  adding a chat screen, wiring one to a backend, or debugging code that uses
  ChatView, ChatController, Message, MessageType, SendMessageConfiguration or
  ChatBubbleConfiguration.
---

# chatview: chat screen

`ChatView` draws a chat screen: message list, composer (text, camera,
gallery, voice), replies, reactions and edits. It holds no data. Your
`ChatController` owns the users and the message list. You build `Message`
objects in callbacks and push them into the controller. For the conversation
list (`ChatList`), use the `chatview-chat-list` skill.

## Workflow

1. **Inspect the project first.** Find the state management (setState, Bloc,
   Riverpod…) to decide where the controller lives, the app's user and
   message models (you will map them to `ChatUser` and `Message`), and the
   backend and its events (new, edited or deleted message, status, typing,
   reaction). For a ready-made backend, point the user to the separate
   [`chatview_connect`](https://pub.dev/packages/chatview_connect) package.
   Read its own docs; this skill does not cover its API.
2. **Add the dependency:** `flutter pub add chatview`. Never hard-code a
   version.
3. **Platform setup** (camera, gallery and voice are on by default):
   - iOS `ios/Runner/Info.plist`: `NSCameraUsageDescription`,
     `NSPhotoLibraryUsageDescription`, and `NSMicrophoneUsageDescription`
     for voice.
   - Android `android/app/src/main/AndroidManifest.xml`:
     `android.permission.RECORD_AUDIO` for voice and
     `android.permission.INTERNET`. The Flutter template only adds INTERNET
     to the debug and profile manifests, not `main`, so network images and
     avatars fail in release. `minSdk` 24 or higher: audio_waveforms alone
     needs 21, but the current `image_picker_android` needs 24 (use
     `flutter.minSdkVersion`).
   - No voice? Set `allowRecordingVoice: false` and skip the mic permission.
4. **Wire the controller and the widget** as in **Basic**, then add the
   requested features from the focused examples.
5. **Connect the backend:** map each event to a controller call
   (**Backend events**).
6. Run `flutter analyze`. On a device, send text, image and voice, then
   reply, react and edit.

Parameters and defaults: `references/chatview-parameters.md` (ChatView,
ChatController, Message, ChatUser) and `references/configurations.md` (the
configuration classes, `ChatViewAppBar`, theming, `ChatViewLocale`).

## Rules

- Import only `package:chatview/chatview.dart`. It re-exports
  `chatview_utils` (`ChatController`, `Message`, `ChatUser`, `ReplyMessage`,
  `MessageType`, `MessageStatus`, `ChatViewState`…), the audio_waveforms
  config types (`WaveStyle`, `PlayerWaveStyle`, `RecorderSettings`…) and
  `emoji_picker_flutter`.
- **You own the controller.** Create it once and call `dispose()`. `ChatView`
  never does. `ChatController.dispose()` also disposes the
  `scrollController` you gave it, so don't dispose or share that one. Cancel
  backend subscriptions first: in debug builds, setting a different typing
  value after `dispose()` fails an assert. `addMessage`, `updateMessage` and
  `setReaction` don't throw after `dispose()`.
- **ChatView never adds messages.** `onSendTap(message, replyMessage,
  messageType)` passes the text, or a local file path for `image` (camera,
  gallery) and `voice` (recording). Build a `Message` with
  `sentBy: controller.currentUser.id` and the given `replyMessage` and
  `messageType`, then call `addMessage`. `replyMessage` is an empty
  `ReplyMessage()` when the user is not replying. The built-in composer never
  sends `MessageType.custom`.
- **Message ids must be unique and non-empty.** The default is `''`. Bubbles
  are keyed by id, so a duplicate crashes with a GlobalKey error.
  `updateMessage` and `setReaction` throw `Message Not Found!` for an
  unknown id.
- **Users:** `currentUser` is the device user. A message is outgoing when
  `sentBy == currentUser.id`. Every other id in `sentBy`, in
  `replyMessage.replyBy` (when the reply has text and there is no
  `repliedMessageWidgetBuilder`) and in `reaction.reactedUserIds` must be in
  `otherUsers`, or rendering throws `User with ID … not found!`. Add
  participants with `updateOtherUser(user)`. A group chat has several
  `otherUsers`.
- **`initialMessageList`** must be growable (never `const []`) and oldest
  first. The controller mutates it in place: `addMessage` appends and
  `loadMoreData` (previous) inserts at index 0. Set
  `ChatBackgroundConfiguration(sortEnable: true)` to sort by `createdAt`
  instead.
- **`chatViewState` gates the list.** Messages, typing indicator and reply
  suggestions render only in `ChatViewState.hasMessages`, and only once the
  list has at least one message. The composer shows in every state while
  `FeatureActiveConfig.enableTextField` is true. When the first message arrives in `noData`, also switch to
  `hasMessages`, or it is stored but not shown.
- **Content per `MessageType`:** `text` is the text. `image` is an `http(s)`
  URL (cached), a `data:image/...;base64,` string or a local file path; asset
  paths don't work. `voice` is passed straight to audio_waveforms'
  `preparePlayer`: use a local audio file path. The plugin's Android player
  takes a URI, but its iOS player is `AVAudioPlayer(contentsOf:)`, so
  download remote audio first. `custom` is anything,
  drawn by `MessageConfiguration.customMessageBuilder`. Without that builder
  it renders empty.
- **Voice works on Android and iOS only.** A `voice` `Message` fails an
  assert (debug builds) elsewhere, and the mic button is hidden there.
- **Always pass `sendMessageConfig.textFieldConfig`.** Without it the
  default camera and gallery buttons do nothing. Set its `textStyle` (or
  `textFieldBackgroundColor`): by default the text is white on white.
- `textFieldConfig.trailingActions` replaces the default camera and gallery
  buttons (`[]` removes them). The mic stays while `allowRecordingVoice` is
  true. The default buttons ignore
  `SendMessageConfiguration.imagePickerConfiguration`. Pass
  `imagePickerConfiguration` to your own `CameraActionButton` or
  `GalleryActionButton` instead.
- **Status:** `Message.status` defaults to `pending`, so set it when mapping
  backend messages. To change it, set `message.setStatus` on the instance in
  `controller.initialMessageList`. It is a `ValueNotifier`, so no rebuild is
  needed. `ChatBubble.onMessageRead` (incoming config) is called from the
  incoming bubble's `initState` while its `status` is not `read`: send read
  receipts there, and set the message to `read` so it stops firing.
- **Reactions:** the long-press popup and double-tap (heart) call
  `setReaction` themselves. `ReactionPopupConfiguration.userReactionCallback`
  runs afterwards, for syncing. `overrideUserReactionCallback: true` skips
  the local update. Double-tap does not call `userReactionCallback`.
  `ChatBubbleConfiguration.onDoubleTap` replaces the built-in heart (both
  only while `FeatureActiveConfig.enableDoubleTapToLike` is true, the
  default), so call `setReaction` in it yourself, then sync. `setReaction` toggles
  (same user + same emoji removes it), so don't replay the current user's
  own reaction from the backend.
- **Editing** needs `FeatureActiveConfig(enableMessageEditing: true)` with
  `enableReplySnackBar` left true (Edit is a button in the reply popup),
  `onEditTap`, the built-in composer, and a text message sent by the current
  user (long-press shows "Edit"; without `onEditTap`, Send in edit mode
  clears the text and saves nothing). `onEditTap(original, updated)` gets a
  copy with the new text and `updatedAt`. Call `updateMessage`. Any text
  message with a non-null `updatedAt` shows "Edited".
- The reply popup (Reply, Edit, Unsend, Report, More) is a `SnackBar` shown
  when `enableReplySnackBar` is true, so `ChatView` needs a `Scaffold` above
  it. The emoji row is a separate overlay (`enableReactionPopup`) that needs
  no `Scaffold`. Long-press does nothing only when both flags are false. The
  popup's "Unsend", "Report" and "More" only call
  `ReplyPopupConfiguration` callbacks. There is no `removeMessage` (see
  **Backend events**).
- **Pagination** needs `enablePagination: true` and `loadMoreData`. It fires
  whenever the list is scrolled to an edge: `previous` at the top (reference
  = oldest message shown), `next` at the bottom (reference = newest). Call
  `controller.loadMoreData(page, direction: direction)` with the page oldest
  first. `isLastPage` returning `true` stops **both** directions, so track
  each direction yourself.
- With `sendMessageBuilder` (your own composer), `onSendTap` and
  `onEditTap` are never called. Use `ChatView.getReplyMessage(context)` and
  `ChatView.closeReplyMessageView(context)`.
- `addMessage` does not scroll. Call `scrollToLastMessage()` for incoming
  messages if needed (sending scrolls already).

## Examples

Basic (1:1 chat; add more `otherUsers` for a group):

```dart
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ChatScreen()));

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _controller;
  ChatViewState _state = ChatViewState.loading;

  @override
  void initState() {
    super.initState();
    _controller = ChatController(
      initialMessageList: [], // growable, oldest first
      scrollController: ScrollController(), // disposed by the controller
      currentUser: const ChatUser(id: 'me', name: 'Me'),
      otherUsers: const [ChatUser(id: 'ana', name: 'Ana')],
    );
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Replace with your backend call; map its models to Message.
    final history = [
      Message(
        id: 'm1',
        message: 'Hi!',
        createdAt: DateTime.now(),
        sentBy: 'ana',
        status: MessageStatus.read,
      ),
    ];
    if (!mounted) return;
    _controller.loadMoreData(history);
    setState(() => _state =
        history.isEmpty ? ChatViewState.noData : ChatViewState.hasMessages);
  }

  void _onSendTap(String text, ReplyMessage reply, MessageType type) {
    final message = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(), // or a server id
      message: text, // text, or a file path for image/voice
      createdAt: DateTime.now(),
      sentBy: _controller.currentUser.id,
      replyMessage: reply,
      messageType: type,
    );
    _controller.addMessage(message);
    if (_state != ChatViewState.hasMessages) {
      setState(() => _state = ChatViewState.hasMessages);
    }
    // When your backend confirms: message.setStatus = MessageStatus.delivered;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(
        chatController: _controller,
        chatViewState: _state,
        onSendTap: _onSendTap,
        appBar: const ChatViewAppBar(chatTitle: 'Ana', userStatus: 'online'),
        sendMessageConfig: const SendMessageConfiguration(
          textFieldConfig: TextFieldConfiguration(
            hintText: 'Message',
            textStyle: TextStyle(color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
```

The examples below use the imports from **Basic**.

Backend events (call these from your socket or stream listener):

```dart
void onMessageReceived(ChatController c, Map<String, dynamic> json) {
  // Message.fromJson keys are listed in references/chatview-parameters.md,
  // or build Message(...) from your own model.
  c.addMessage(Message.fromJson(json));
  c.scrollToLastMessage();
}

void onStatusChanged(ChatController c, String id, MessageStatus status) {
  for (final message in c.initialMessageList) {
    if (message.id == id) message.setStatus = status;
  }
}

void onMessageEdited(ChatController c, Message edited) =>
    c.updateMessage(messageId: edited.id, newMessage: edited);

void onMessageDeleted(ChatController c, String id) {
  c.initialMessageList.removeWhere((message) => message.id == id);
  c.messageStreamController.sink.add(c.initialMessageList);
}

void onReaction(ChatController c, String messageId, String userId, String emoji) =>
    c.setReaction(emoji: emoji, messageId: messageId, userId: userId);

void onTyping(ChatController c, bool isTyping) => c.setTypingIndicator = isTyping;

void onUserJoined(ChatController c, ChatUser user) => c.updateOtherUser(user);

void onSuggestions(ChatController c, List<String> replies) =>
    c.addReplySuggestions([for (final r in replies) SuggestionItemData(text: r)]);
```

Two-way pagination with an end flag per direction:

```dart
// Stands in for your backend. Both methods return pages oldest first.
abstract class MessageApi {
  Future<List<Message>> before(String messageId);
  Future<List<Message>> after(String messageId);
}

class PagedChat extends StatefulWidget {
  const PagedChat({required this.controller, required this.api, super.key});

  final ChatController controller;
  final MessageApi api;

  @override
  State<PagedChat> createState() => _PagedChatState();
}

class _PagedChatState extends State<PagedChat> {
  bool _noOlder = false;
  bool _noNewer = false;

  Future<void> _loadMore(ChatPaginationDirection direction, Message ref) async {
    final older = direction == ChatPaginationDirection.previous;
    if (older ? _noOlder : _noNewer) return;
    final page =
        older ? await widget.api.before(ref.id) : await widget.api.after(ref.id);
    if (page.isEmpty) {
      older ? _noOlder = true : _noNewer = true;
      return;
    }
    widget.controller.loadMoreData(page, direction: direction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(
        chatController: widget.controller,
        chatViewState: ChatViewState.hasMessages,
        featureActiveConfig: const FeatureActiveConfig(enablePagination: true),
        loadMoreData: _loadMore,
        isLastPage: () => _noOlder && _noNewer,
        sendMessageConfig: const SendMessageConfiguration(
          textFieldConfig: TextFieldConfiguration(),
        ),
      ),
    );
  }
}
```

Composer actions (camera, resized gallery picks, and an overlay menu that
sends a custom message), with the builder that draws custom messages:

```dart
Message newMessage(
        ChatController c, String content, MessageType type, ReplyMessage? reply) =>
    Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: content,
      createdAt: DateTime.now(),
      sentBy: c.currentUser.id,
      messageType: type,
      replyMessage: reply ?? const ReplyMessage(),
    );

ChatView chatWithActions(ChatController c, ChatViewState state) {
  return ChatView(
    chatController: c,
    chatViewState: state,
    onSendTap: (text, reply, type) => c.addMessage(newMessage(c, text, type, reply)),
    sendMessageConfig: SendMessageConfiguration(
      allowRecordingVoice: false,
      textFieldConfig: TextFieldConfiguration(
        textStyle: const TextStyle(color: Colors.black87),
        trailingActions: (context, textController) => [
          CameraActionButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: (path, reply) {
              if (path == null || path.isEmpty) return; // cancelled
              c.addMessage(newMessage(c, path, MessageType.image, reply));
              ChatView.closeReplyMessageView(context);
            },
          ),
          GalleryActionButton(
            icon: const Icon(Icons.photo_outlined),
            imagePickerConfiguration:
                const ImagePickerConfiguration(maxWidth: 1600, imageQuality: 80),
            onPressed: (path, reply) {
              if (path == null || path.isEmpty) return;
              c.addMessage(newMessage(c, path, MessageType.image, reply));
              ChatView.closeReplyMessageView(context);
            },
          ),
          OverlayActionButton(
            icon: const Icon(Icons.add),
            actions: [
              OverlayActionWidget(
                icon: const Icon(Icons.location_pin),
                label: 'Location',
                onTap: (reply) => c.addMessage(
                    newMessage(c, '48.85,2.35', MessageType.custom, reply)),
              ),
            ],
          ),
        ],
      ),
    ),
    messageConfig: MessageConfiguration(
      customMessageBuilder: (message) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('📍 ${message.message}'),
      ),
    ),
  );
}
```

Editing, unsend, reactions and reply suggestions:

```dart
ChatView chatWithInteractions(ChatController c, StringMessageCallBack onSend) {
  return ChatView(
    chatController: c,
    chatViewState: ChatViewState.hasMessages,
    onSendTap: onSend,
    featureActiveConfig: const FeatureActiveConfig(enableMessageEditing: true),
    onEditTap: (original, updated) {
      c.updateMessage(messageId: original.id, newMessage: updated);
      // Send updated.message to your backend.
    },
    replyPopupConfig: ReplyPopupConfiguration(
      onUnsendTap: (message) {
        c.initialMessageList.removeWhere((m) => m.id == message.id);
        c.messageStreamController.sink.add(c.initialMessageList);
      },
    ),
    reactionPopupConfig: ReactionPopupConfiguration(
      // Already applied locally by setReaction; sync it here.
      userReactionCallback: (message, emoji) {},
    ),
    replySuggestionsConfig: ReplySuggestionsConfig(
      onTap: (item) => onSend(item.text, const ReplyMessage(), MessageType.text),
    ),
    sendMessageConfig: const SendMessageConfiguration(
      textFieldConfig: TextFieldConfiguration(),
    ),
  );
}
```

Theming (bubbles, background, receipts, state screens, typing indicator) and
translating the built-in strings with `ChatViewLocale` are shown in
`references/configurations.md`.

## Troubleshooting

- Sent message doesn't appear → `onSendTap` doesn't call `addMessage`, or
  `chatViewState` is still `noData` or `loading`.
- `User with ID … not found!` → an id in `sentBy`, a reply or a reaction is
  missing from `otherUsers`.
- "Multiple widgets used the same GlobalKey" → duplicate or empty message
  ids.
- `Cannot add to an unmodifiable list` → `initialMessageList` is `const`.
- Camera or gallery icon does nothing → no `textFieldConfig`. Typed text
  invisible → set `textFieldConfig.textStyle`.
- No reply popup on long-press → no `Scaffold` above `ChatView`, or
  `enableReplySnackBar` is false. No emoji row → `enableReactionPopup` is
  false.
- `loadMoreData` fires again and again → it fires at every scroll edge.
  Return early when a direction is exhausted.
- "Failed to find message with id" after tapping a reply →
  `RepliedMessageConfiguration.loadOldReplyMessage` must load that message
  into the list: fetch every message from it up to the oldest one shown and
  call `controller.loadMoreData(page)`. Avoid `replaceMessageList`: its
  cache is never cleared, so later sends reset the list and drop messages.
- Voice message shows `00:00` → it came from `Message.fromJson` without
  `voice_message_duration`, which sets a zero duration instead of letting
  the player detect it.
- "Edited" label or voice duration lost after a reaction → `setReaction`
  rebuilds the message without `updatedAt`, `update` and
  `voiceMessageDuration`.
- `version solving failed` → chatview pins exact versions of
  `any_link_preview`, `audio_waveforms`, `cached_network_image`,
  `chatview_utils`, `emoji_picker_flutter`, `image_picker`, `intl` and
  `url_launcher`. Align the app's constraints.
- Upgrading from an older chatview → use the `chatview-migration` skill.
