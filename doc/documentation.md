# Overview

ChatView is a Flutter package that allows you to integrate a highly customizable chat UI in your
Flutter applications with [Flexible Backend Integration](https://pub.dev/packages/chatview_connect).

## Preview

![Preview](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/main/preview/chatview.gif)

## Features

### ChatViewList:

- Smooth animations for adding, removing, and pinning chats
- Pagination support for large chat histories
- Search functionality by name or other criteria
- Long press menu with options like pin and mute
- User online status indicators
- Typing indicators for active users
- Unread message count badges
- Connect ChatView to any backend
  using [chatview_connect](https://pub.dev/packages/chatview_connect)
- And a wide range of configuration options to customize your chat.
- Internationalization support

### ChatView:

- One-on-one and group chat support
- Message reactions with emoji
- Reply to messages functionality
- Link preview
- Voice messages
- Image sharing
- Message styling
- Typing indicators
- Reply suggestions
- Two-way pagination with lazy loading
- Connect ChatView to any backend
  using [chatview_connect](https://pub.dev/packages/chatview_connect)
- And a wide range of configuration options to customize your chat.
- Internationalization support

For a live web demo, visit [Chat View Example](https://simformsolutionspvtltd.github.io/chatview/).

## Compatible Message Types

|  Message Types  | Android | iOS | MacOS | Web | Linux | Windows |
|:---------------:|:-------:|:---:|:-----:|:---:|:-----:|:-------:|
|  Text messages  |   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |
| Image messages  |   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |
| Voice messages  |   ✔️    | ✔️  |   ❌   |  ❌  |   ❌   |    ❌    |
| Custom messages |   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |


# Installation

## Adding the dependency

1. Add the package dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  chatview: <latest-version>
```

You can find the latest version on [pub.dev](https://pub.dev/packages/chatview) under the 'Installing' tab.

2. Import the package in your Dart code:

```dart
import 'package:chatview/chatview.dart';
```

## Platform-specific configurations

### For Image Picker

#### iOS
Add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used to capture audio for image picker plugin</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
```

### For Voice Messages

#### iOS
* Add this row in `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app requires Mic permission.</string>
```

* This plugin requires iOS 10.0 or higher. Add this line in `Podfile`:
```ruby
platform :ios, '10.0'
```

#### Android
* Change the minimum Android SDK version to 21 (or higher) in your `android/app/build.gradle` file:
```gradle
minSdkVersion 21
```

* Add RECORD_AUDIO permission in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

# Basic ChatViewList Usage

Here's how to integrate ChatViewList into your Flutter application with minimal setup:

## Step 1: Create a ChatView List Controller

```dart
ChatViewListController chatListController = ChatViewListController(
  initialChatList: chatList,
  scrollController: ScrollController(),
);
```

## Step 2: Add the ChatViewList Widget

```dart
ChatViewList(
  controller: chatListController,
  appbar: const ChatViewListAppBar(
    title: 'ChatViewList Demo',
  ),
  menuConfig: ChatMenuConfig(
    deleteCallback: (chat) => chatListController.removeChat(chat.id),
    muteStatusCallback: (result) => chatListController.updateChat(
      result.chat.id,
      (previousChat) => previousChat.copyWith(
        settings: previousChat.settings.copyWith(
          muteStatus: result.status,
        ),
      ),
    ),
    pinStatusCallback: (result) => chatListController.updateChat(
      result.chat.id,
      (previousChat) => previousChat.copyWith(
        settings: previousChat.settings.copyWith(
          pinStatus: result.status,
        ),
      ),
    ),
  ),
  tileConfig: ListTileConfig(
    onTap: (chat) {,
      // Handle chat tile tap
    },
  ),
)
```

## Step 3: Define Chat List

Define your initial chat list:

```dart

List<ChatViewListItem> chatList = [
  ChatViewListItem(
    id: '2',
    name: 'Simform',
    unreadCount: 2,
    lastMessage: Message(
      id: '12',
      sentBy: '2',
      message: "🤩🤩",
      createdAt: DateTime.now(),
      status: MessageStatus.delivered,
    ),
    settings: ChatSettings(
      pinTime: DateTime.now(),
      pinStatus: PinStatus.pinned,
    ),
  ),
  ChatViewListItem(
    id: '1',
    name: 'Flutter',
    userActiveStatus: UserActiveStatus.online,
    typingUsers: {const ChatUser(id: '1', name: 'Simform')},
  ),
];
```

# Advanced ChatViewList Usage

ChatViewList offers extensive customization options to tailor the chat list UI to your specific needs.

## Adding Custom Appbar

```dart
ChatViewList(
  // ...
  appbar: ChatViewListAppBar(
    title: 'ChatViewList Demo',
    centerTitle: false,
    actions: [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          // Handle search action
        },
      ),
    ],
  ),
  // ...
)
```

## Adding Search Functionality

```dart
ChatViewList(
  // ...
  searchConfig: SearchConfig(
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
     )
  ),
  // ...
)
```

## Adding Custom Header

```dart
ChatViewList(
  /// ...
  header: SizedBox(
   height: 60,
   child: ListView(
     padding: const EdgeInsetsGeometry.all(12),
     scrollDirection: Axis.horizontal,
     children: [
       FilterChip.elevated(
         backgroundColor: Colors.grey.shade200,
         label: Text(
             'All Chats (${chatListController.chatListMap.length ?? 0})'),
         onSelected: (bool value) => chatListController.clearSearch(),
       ),
       const SizedBox(width: 12),
       FilterChip.elevated(
         backgroundColor: Colors.grey.shade200,
         label: const Text('Pinned Chats'),
         onSelected: (bool value) {
           chatListController.setSearchChats(
             chatListController.chatListMap.values
                     .where((e) => e.settings.pinStatus.isPinned)
                     .toList(),
           );
         },
       ),
       const SizedBox(width: 12),
       FilterChip.elevated(
         backgroundColor: Colors.grey.shade200,
         label: const Text('Unread Chats'),
         onSelected: (bool value) {
           chatListController.setSearchChats(
             chatListController.chatListMap.values
                     .where((e) => (e.unreadCount ?? 0) > 0)
                     .toList(),
           );
         },
       ),
     ],
   ),
  // ...
)
```

## Adding Custom Actions in Menu

```dart
ChatViewList(
  // ...
  menuConfig: ChatMenuConfig(
    actions: (chat) => [
      CupertinoContextMenuAction(
        trailingIcon: Icons.favorite_outline_rounded,
        child: const Text(
          'Add to Favorite',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () {
          Future.delayed(
            const Duration(milliseconds: 800),
            () {
              // YOUR CODE HERE
            },
          );
          Navigator.pop(context);
        },
      ),
    ],
    deleteCallback: (chat) => chatListController.removeChat(chat.id),
    muteStatusCallback: (result) => chatListController.updateChat(
      result.chat.id,
      (previousChat) => previousChat.copyWith(
        settings: previousChat.settings.copyWith(
          muteStatus: result.status,
        ),
      ),
    ),
    pinStatusCallback: (result) => chatListController.updateChat(
      result.chat.id,
      (previousChat) => previousChat.copyWith(
        settings: previousChat.settings.copyWith(
          pinStatus: result.status,
        ),
      ),
    ),
    // ...
  ),
  // ...
)
```

## Chat Tile Configuration

```dart
ChatViewList(
  // ...
  tileConfig: ListTileConfig(
    // ...
    onTap: (chat) {
      // Handle chat tile tap
    },
    // Custom padding for chat tile
    padding: const EdgeInsets.all(12),
    middleWidgetPadding: const EdgeInsets.symmetric(horizontal: 12),
    // Custom text styles for chat tile
    lastMessageTextStyle: const TextStyle(color: Colors.red),
    userNameTextStyle: const TextStyle(fontWeight: FontWeight.bold),
    // Custom builders for various parts of the chat tile
    trailingBuilder: (chat) => const Placeholder(fallbackWidth: 40, fallbackHeight: 40),
    userNameBuilder: (chat) => const Placeholder(fallbackHeight: 20),
    lastMessageTileBuilder: (message) => const Placeholder(fallbackHeight: 20),
    // ...
  ),
  // ...
)
```

## Typing Indicator Configuration

```dart
ChatViewList(
  // ...
  tileConfig: ListTileConfig(
    // ...
    typingStatusConfig: TypingStatusConfig(
      // ...
      suffix: '.....',
      showUserNames: true,
      textBuilder: (chat) => 'typing...',
      widgetBuilder: (chat) => Placeholder(fallbackHeight: 12),
    ),
    // ...
  ),
  // ...
)
```

## Last Message Time Configuration

```dart
ChatViewList(
  // ...
  tileConfig: ListTileConfig(
    // ...
    timeConfig: LastMessageTimeConfig(
      // Specify to format dates older than yesterday
      dateFormatPattern: 'MMM dd, yyyy',
      spaceBetweenTimeAndUnreadCount: 8,
      timeBuilder: (time) => Placeholder(fallbackHeight: 20, fallbackWidth: 20),
    ),
    // ...
  ),
  // ...
)
```

## Last Message Status Configuration

```dart
ChatViewList(
  // ...
  tileConfig: ListTileConfig(
    // ...
    lastMessageStatusConfig: LastMessageStatusConfig(
      showStatusFor: (message) => message.sentBy == '2',
      color: (status) => switch (status) {
        MessageStatus.read => Colors.blue,
        MessageStatus.delivered ||
        MessageStatus.undelivered ||
        MessageStatus.pending =>
          Colors.grey,
      },
      icon: (status) => switch (status) {
        MessageStatus.read => Icons.done_all_rounded,
        MessageStatus.delivered => Icons.done_rounded,
        MessageStatus.undelivered => Icons.error_outline_rounded,
        MessageStatus.pending => Icons.schedule_rounded,
      },
    ),
    // ...
  ),
  // ...
)
```

## Unread Count Configuration

```dart
ChatViewList(
  // ...
  tileConfig: ListTileConfig(
    // ...
    unreadCountConfig: const UnreadCountConfig(
      backgroundColor: Colors.green,
      style: UnreadCountStyle.ninetyNinePlus,
    ),
    // ...
  ),
  // ...
)
```

## User Active Status Configuration

```dart
ChatViewList(
  // ...
  tileConfig: ListTileConfig(
    // ...
    userActiveStatusConfig: UserActiveStatusConfig(
      shape: BoxShape.rectangle,
      color: (status) => switch (status) {
        UserActiveStatus.online => Colors.green,
        UserActiveStatus.offline => Colors.red,
      },
      alignment: UserActiveStatusAlignment.topRight,
      showIndicatorFor: (status) => status.isOnline,
    ),
    // ...
  ),
  // ...
)
```

## User Avatar Configuration

```dart
ChatViewList(
  // ...
  tileConfig: ListTileConfig(
    // ...
    userAvatarConfig: UserAvatarConfig(
      backgroundColor: Colors.blue,
      radius: 20,
      onProfileTap: (value) {
        // Your code here
      },
    ),
    // ...
  ),
  // ...
)
```

## ChatViewList States Configuration 

```
ChatViewList(
  // ...
  stateConfig: const ListStateConfig(
    noChatsWidgetConfig: ChatViewStateWidgetConfiguration(
      title: 'No Chats',
      subTitle: 'Start a new chat now!',
      showDefaultReloadButton: false,
    ),
    noSearchChatsWidgetConfig: ChatViewStateWidgetConfiguration(
      title: 'No Chats Found',
      subTitle: 'Try searching with different keywords.',
      showDefaultReloadButton: false,
    ),
    // ...
  ),
  // ...
)
```

## Load More Chats Configuration

```
ChatViewList(
  // ...
  loadMoreConfig: LoadMoreConfig(
    size: 30,
    color: Colors.blue,
  ),
  // ...
)
```

# Basic ChatView Usage

Here's how to integrate ChatView into your Flutter application with minimal setup:

## Step 1: Create a Chat Controller

The `ChatController` manages the state of your chat view:

```dart
final chatController = ChatController(
  initialMessageList: messageList,
  scrollController: ScrollController(),
  currentUser: ChatUser(id: '1', name: 'Flutter'),
  otherUsers: [ChatUser(id: '2', name: 'Simform')],
);
```

## Step 2: Add the ChatView Widget

```dart
ChatView(
  chatController: chatController,
  onSendTap: onSendTap,
  chatViewState: ChatViewState.hasMessages, // Add this state once data is available
)
```

## Step 3: Define Message List

Define your initial message list:

```dart
List<Message> messageList = [
  Message(
    id: '1',
    message: "Hi",
    createdAt: DateTime.now(),
    sentBy: userId,
  ),
  Message(
    id: '2',
    message: "Hello",
    createdAt: DateTime.now(),
    sentBy: userId,
  ),
];
```

## Step 4: Implement onSendTap Callback

Handle the send message event:

```dart
void onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) {
  // Create a new message
  final newMessage = Message(
    id: '3',
    message: message,
    createdAt: DateTime.now(),
    sentBy: currentUser.id,
    replyMessage: replyMessage,
    messageType: messageType,
  );
  
  // Add message to chat controller
  chatController.addMessage(newMessage);
}
```

> Note: You can evaluate message type from the 'messageType' parameter and perform operations accordingly.

# Advanced ChatView Usage

ChatView offers extensive customization options to tailor the chat UI to your specific needs.

## Adding Custom Appbar

```dart
ChatView(
  // ...
  appBar: ChatViewAppBar(
    profilePicture: profileImage,
    chatTitle: "Simform",
    userStatus: "online",
    actions: [
      Icon(Icons.more_vert),
    ],
    defaultAvatarImage: defaultAvatar,
    imageType: ImageType.network,
    networkImageErrorBuilder: (context, url, error) {
      return Center(
        child: Text('Error $error'),
      );
    },
  ),
  // ...
)
```

## Adding Message Reactions

```dart
ChatView(
  // ...
  reactionPopupConfig: ReactionPopupConfiguration(
    backgroundColor: Colors.white,
    userReactionCallback: (message, emoji) {
      // Your code here
    },
    padding: EdgeInsets.all(12),
    shadow: BoxShadow(
      color: Colors.black54,
      blurRadius: 20,
    ),
  ),
  // ...
)
```

## Reply Message Configuration

```dart
ChatView(
  // ...
  repliedMessageConfig: RepliedMessageConfiguration(
    loadOldReplyMessage: (messageId) async {
      // Load older messages that contain the replied message
      await _loadMessagesAround(messageId);
    },
    backgroundColor: Colors.blue,
    verticalBarColor: Colors.black,
    repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
      enableHighlightRepliedMsg: true,
      highlightColor: Colors.grey,
      highlightScale: 1.1,
    ),
  ),
  // ...
)
```

### Loading Old Reply Messages

The `loadOldReplyMessage` callback is essential for handling replies to messages that aren't 
currently loaded in the chat view. When a user taps on a replied message, ChatView automatically 
searches for the original message in the current message list. If the original message isn't 
found (typically because it's an older message), this callback is triggered to load the 
necessary historical messages.

It is recommended to fetch messages such that the target message would fall in the middle of the 
loaded messages, i.e., if the target message id is 25 and page size is 20, then load messages 
with ids from 15 to 35.

#### Example:

```dart
repliedMessageConfig: RepliedMessageConfiguration(
  loadOldReplyMessage: (messageId) async {
    try {
      // 1. Fetch historical messages containing the target message
      // Ensure to handle loading UI state till messages are fetched
      final historicalMessages = await _apiService.getMessagesAroundId(
        messageId: messageId,
        limit: 20, // Load messages around the target
      );

      // 2. Update the message list with historical data
      _chatController.replaceMessageList(historicalMessages);
    } catch (error) {
      // Handle errors gracefully
      debugPrint('Failed to load old reply message: $error');
      // Optionally show user-friendly error message
    }
  },
  // Other configuration options...
),
```

## Chat Bubble Customization

```dart
ChatView(
  // ...
  chatBubbleConfig: ChatBubbleConfiguration(
    onDoubleTap: () {
      // Your code here
    },
    outgoingChatBubbleConfig: ChatBubble(
      color: Colors.blue,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
    ),
    inComingChatBubbleConfig: ChatBubble(
      color: Colors.grey.shade200,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    ),
  ),
  // ...
)
```

## Swipe to Reply Configuration

```dart
ChatView(
  // ...
  swipeToReplyConfig: SwipeToReplyConfiguration(
    onLeftSwipe: (message, sentBy) {
      // Your code here
    },
    onRightSwipe: (message, sentBy) {
      // Your code here
    },
  ),
  // ...
)
```

## Voice Message Configuration

```dart
ChatView(
  // ...
  sendMessageConfig: SendMessageConfiguration(
    voiceRecordingConfiguration: VoiceRecordingConfiguration(
      iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
      androidOutputFormat: AndroidOutputFormat.mpeg4,
      androidEncoder: AndroidEncoder.aac,
      bitRate: 128000,
      sampleRate: 44100,
      waveStyle: WaveStyle(
        showMiddleLine: false,
        waveColor: Colors.white,
        extendWaveform: true,
      ),
    ),
    cancelRecordConfiguration: CancelRecordConfiguration(
      icon: const Icon(
        Icons.cancel_outlined,
      ),
      onCancel: () {
        debugPrint('Voice recording cancelled');
      },
      iconColor: Colors.black,
    ),
  ),
  // ...
)
```

## Reply Suggestions

```dart
// Add reply suggestions
_chatController.addReplySuggestions([
  SuggestionItemData(text: 'Thanks.'),
  SuggestionItemData(text: 'Thank you very much.'),
  SuggestionItemData(text: 'Great.')
]);

// Remove reply suggestions
_chatController.removeReplySuggestions();

// Reply suggestions configuration
ChatView(
  // ...
  replySuggestionsConfig: ReplySuggestionsConfig(
    itemConfig: SuggestionItemConfig(
      decoration: BoxDecoration(),
      textStyle: TextStyle(),
      padding: EdgeInsets.all(8),
    ),
    listConfig: SuggestionListConfig(
      decoration: BoxDecoration(),
      padding: EdgeInsets.all(8),
      itemSeparatorWidth: 8,
      axisAlignment: SuggestionListAlignment.left
    ),
    onTap: (item) => _onSendTap(item.text, const ReplyMessage(), MessageType.text),
    autoDismissOnSelection: true,
    suggestionItemType: SuggestionItemsType.multiline,
  ),
  // ...
)
```

## Enabling/Disabling Features

```dart
ChatView(
  // ...
  featureActiveConfig: FeatureActiveConfig(
    enableSwipeToReply: true,
    enableSwipeToSeeTime: false,
    enablePagination: true,
    enableOtherUserName: false,
    lastSeenAgoBuilderVisibility: false,
    receiptsBuilderVisibility: false,
  ),
  // ...
)
```

## Two-Way Pagination

ChatView supports two-way pagination for efficiently loading messages in both directions - 
loading older messages when scrolling to the top and newer messages when scrolling to the bottom.
This feature enables lazy loading and memory optimization for large chat histories.

### Example

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ChatView(
      chatController: _chatController,
      // Enable pagination
      featureActiveConfig: FeatureActiveConfig(
        enablePagination: true,
      ),

      // Prevent further pagination when no more data is available.
      isLastPage: () => _messageCount >= _totalMessageCount,

      // Customize the loading indicator shown during pagination.
      loadingWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Loading messages...'),
        ],
      ),

      // Handle loading more data for pagination.
      loadMoreData: (ChatPaginationDirection direction, Message referenceMessage) async {
        // Call your API service to load messages based on the direction and reference message
        final newMessages = switch (direction) {
          // Load older messages (when user scrolls to top)
          // referenceMessage is the first message in the current list
          ChatPaginationDirection.previous => await _apiService.getOlderMessages(
            beforeMessageId: referenceMessage.id,
            limit: 20,
          ),
          // Load newer messages (when user scrolls to bottom)
          // referenceMessage is the last message in the current list
          ChatPaginationDirection.next => await _apiService.getNewerMessages(
            afterMessageId: referenceMessage.id,
            limit: 20,
          ),
        };
        
        // Add the loaded messages to the chat controller
        _chatController.loadMoreData(
          newMessages,
          direction: direction,
        );
      },
    ),
  );
}
```

### Best Practices

1. **Batch Size**: Load messages in reasonable batches (e.g., 20-50 messages per request)
2. **Error Handling**: Always handle API errors gracefully in your `loadMoreData` callback
3. **Loading States**: Use the built-in loading indicators or customize them for better UX
4. **Pagination State**: Properly manage `isLastPage` to prevent unnecessary API calls
5. **Reference Messages**: Use the provided reference message for cursor-based pagination for 
   better performance

## Link Preview Configuration

```dart
ChatView(
  // ...
  chatBubbleConfig: ChatBubbleConfiguration(
    linkPreviewConfig: LinkPreviewConfiguration(
      linkStyle: const TextStyle(
        color: Colors.white,
        decoration: TextDecoration.underline,
      ),
      backgroundColor: Colors.grey,
      bodyStyle: const TextStyle(
        color: Colors.grey.shade200,
        fontSize: 16,
      ),
      titleStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
      errorBody: 'Error encountered while parsing the link for preview'
    ),
  ),
  // ...
)
```

## Typing Indicator Configuration

```dart
ChatView(
  // ...
  typeIndicatorConfig: TypeIndicatorConfiguration(
    flashingCircleBrightColor: Colors.grey,
    flashingCircleDarkColor: Colors.black,
  ),
  // ...
)

// Show/hide typing indicator
_chatController.setTypingIndicator = true; // Show indicator
_chatController.setTypingIndicator = false; // Hide indicator
```

## Custom Message Reply View Builder

```dart
ChatView(
  // ...
  messageConfig: MessageConfiguration(
    customMessageBuilder: (ReplyMessage state) {
      return Text(
        state.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      );
    },
  ),
  // ...
)
```

## Custom Reply Message Builder

```dart
ChatView(
  // ...
  replyMessageBuilder: (context, state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(14),
        ),
      ),
      margin: const EdgeInsets.only(
        bottom: 17,
        right: 0.4,
        left: 0.4,
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    state.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                  onPressed: () => ChatView.closeReplyMessageView(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
  // ...
)
```

## Internationalization
ChatView supports internationalization (i18n) for various languages. You can set the locale using the `PackageString.setLocale('en')`.

```dart
PackageStrings.addLocaleObject(
  'es',
  const ChatViewLocale(
    today: 'Hoy',
    yesterday: 'Ayer',
    repliedToYou: 'Te respondió',
    repliedBy: 'Respondido por',
    more: 'Más',
    unsend: 'Desenviar',
    reply: 'Responder',
    replyTo: 'Responder a',
    message: 'Mensaje',
    reactionPopupTitle: 'Mantén presionado para multiplicar tu reacción',
    photo: 'Foto',
    send: 'Enviar',
    you: 'Tú',
    report: 'Reportar',
  ),
);

PackageStrings.setLocale('es');
```

## Send Image With Message
You can send images along with your messages by enabling the `shouldSendImageWithText` flag in `sendMessageConfig` all the other things will be handled by the package itself. Here's how to do it:

```dart
sendMessageConfig: SendMessageConfiguration(
  shouldSendImageWithText: true, // Enable sending images with text
),
```

You can also customize the view by using the `selectedImageViewBuilder` field of the `sendMessageConfig`:

```dart
sendMessageConfig: SendMessageConfiguration(
  shouldSendImageWithText: true,
  selectedImageViewBuilder: (images, onImageRemove) {
    if (images.isNotEmpty) {
      return SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Stack(
          children: [
            Image.file(
              File(images.first),
              height: 100,
            ),
            Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(
                Icons.close,
              ),
              onPressed: () {
                 onImageRemove.call(
                  imagePath: images.first,
                 );
               },
             ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  },
),
```

## Backend Integration

Easily connect Chatview UI to any backend using the [**Chatview Connect**](https://pub.dev/packages/chatview_connect)
package. It offers ready-to-use solutions for
real-time messaging with supporting media uploads.


# Migration Guide

## Migration Guide for ChatView 2.0.0
This guide will help you migrate your code from previous versions of ChatView to version 2.0.0.

## Key Changes

### Renamed Properties

- Renamed `sendBy` field to `sentBy` in `Message` class.
- Renamed `chatUsers` field to `otherUsers` in `ChatController` class.

### Moved Properties

- Moved `currentUser` field from `ChatView` widget to `ChatController` class.

### Updated Methods

- Updated `id` value in `copyWith` method of `Message` to have correct value.
- Removed `showTypingIndicator` field from `ChatView` and replaced it with `ChatController.showTypingIndicator`.

### JSON Serialization Changes

The format for `fromJson` and `toJson` methods changed for several classes:

#### ChatUser

**Before (`ChatUser.fromJson`):**
```dart
ChatUser.fromJson(
  { 
    // ...
    'imageType': ImageType.asset,
    // ...
  },
),
```

**After (`ChatUser.fromJson`):**
```dart
ChatUser.fromJson(
  {
    // ...
    'imageType': 'asset',
    // ...
  },
),
```

**Before (`ChatUser.toJson`):**
```dart
{
  // ...
  imageType: ImageType.asset,
  // ...
}
```

**After (`ChatUser.toJson`):**
```dart
{
  // ...
  imageType: asset,
  // ...
}
```

#### Message

**Before (`Message.fromJson`):**
```dart
Message.fromJson(
  {
    // ...
    'createdAt': DateTime.now(),
    'message_type': MessageType.text,
    'voice_message_duration': Duration(seconds: 5),
    // ...
  }
)
```

**After (`Message.fromJson`):**
```dart
Message.fromJson(
  {
    // ...
    'createdAt': '2024-06-13T17:32:19.586412',
    'message_type': 'text',
    'voice_message_duration': '5000000',
    // ...
  }
)
```

**Before (`Message.toJson`):**
```dart
{
  // ...
  createdAt: 2024-06-13 17:23:19.454789,
  message_type: MessageType.text,
  voice_message_duration: 0:00:05.000000,
  // ...
}
```

**After (`Message.toJson`):**
```dart
{
  // ...
  createdAt: 2024-06-13T17:32:19.586412,
  message_type: text,
  voice_message_duration: 5000000,
  // ...
}
```

#### ReplyMessage

**Before (`ReplyMessage.fromJson`):**
```dart
ReplyMessage.fromJson(
  {
    // ...
    'message_type': MessageType.text,  
    'voiceMessageDuration': Duration(seconds: 5),
    // ...
  }
)
```

**After (`ReplyMessage.fromJson`):**
```dart
ReplyMessage.fromJson(
  {
    // ...
    'message_type': 'text',  
    'voiceMessageDuration': '5000000',
    // ...
  }
)
```

**Before (`ReplyMessage.toJson`):**
```dart
{
  // ...
  message_type: MessageType.text,
  voiceMessageDuration: 0:00:05.000000,
  // ...
}
```

**After (`ReplyMessage.toJson`):**
```dart
{
  // ...
  message_type: text,
  voiceMessageDuration: 5000000,
  // ...
}
```

## Typing Indicator Changes

**Before:**
```dart
ChatView(
  showTypingIndicator: false,
),
```

**After:**
```dart
// Use it with your ChatController instance
_chatController.setTypingIndicator = true; // for showing indicator
_chatController.setTypingIndicator = false; // for hiding indicator
```

# Contributors

## Main Contributors

| ![img](https://avatars.githubusercontent.com/u/25323183?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/56400956?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/65003381?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/41247722?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/72062416?v=4&s=200) |
|:------------------------------------------------------------------:|:------------------------------------------------------------------:|:------------------------------------------------------------------:|:------------------------------------------------------------------:|:------------------------------------------------------------------:|
|           [Vatsal Tanna](https://github.com/vatsaltanna)           |        [Ujas Majithiya](https://github.com/Ujas-Majithiya)         |         [Apurva Kanthraviya](https://github.com/apurva780)         |         [Aditya Chavda](https://github.com/aditya-chavda)          |    [Yash Dhrangdhariya](https://github.com/Yash-Dhrangdhariya)     |

## How to Contribute

Contributions are welcome! If you'd like to contribute to this project, please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Report Issues

If you find any bugs or have feature requests, please create an issue in the [issue tracker](https://github.com/SimformSolutionsPvtLtd/chatview/issues).

## Project Resources

- GitHub Repository: [chatview](https://github.com/SimformSolutionsPvtLtd/chatview).
- Package on pub.dev: [chatview](https://pub.dev/packages/chatview).
- Web Demo: [Chat View Example](https://simformsolutionspvtltd.github.io/chatview/).
- Blog Post: [ChatView: A Cutting-Edge Chat UI Solution](https://medium.com/simform-engineering/chatview-a-cutting-edge-chat-ui-solution-7367b1f9d772).

# License

```
MIT License
Copyright (c) 2022 Simform Solutions
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
