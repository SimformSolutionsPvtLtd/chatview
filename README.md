![Banner](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/main/preview/banner.png)

# ChatView

[![chatview](https://img.shields.io/pub/v/chatview?label=chatview)](https://pub.dev/packages/chatview)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/SimformSolutionsPvtLtd/chatview/blob/main/LICENSE)

ChatView is a Flutter package that allows you to integrate a highly customizable chat UI in your
Flutter applications with [Flexible Backend Integration][chatViewConnect].

![Preview](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/main/preview/chatview.gif)

## Features

- One-on-one and group chat support
- Message reactions with emoji
- Reply to messages functionality
- Link preview for URLs
- Voice messages support
- Image sharing capabilities
- Custom message types
- Typing indicators
- Reply suggestions
- Message status indicators (sent, delivered, read)
- Highly customizable UI components
- Plug-and-play backend support using [chatview_connect][chatViewConnect]

## Documentation

Visit our [documentation](https://simform-flutter-packages.web.app/chatView) site for all
implementation details, usage instructions, code examples, and advanced features.

## Installation

- Moved `currentUser` field from `ChatView` widget to `ChatController` class

- Updated `id` value in `copyWith` method of `Message` to have correct value.

- Removed `showTypingIndicator` field from `ChatView` and replaced it with `ChatController.showTypingIndicator`.

  Before:

  ```dart
  ChatView(
    showTypingIndicator:false,
  ),
  ```

  After:

  ```dart
  /// use it with your [ChatController] instance.
  _chatContoller.setTypingIndicator = true; // for showing indicator
  _chatContoller.setTypingIndicator = false; // for hiding indicator
  ```

- Updated `ChatUser`, `Message` and `ReplyMessage` Data Model's `fromJson` and `toJson` methods:

  ##### in `ChatUser.fromJson`:

  Before:

  ```dart
  ChatUser.fromJson(
    {
      ...
      'imageType': ImageType.asset,
      ...
    },
  ),
  ```

  After:

  ```dart
  ChatUser.fromJson(
    {
      ...
      'imageType': 'asset',
      ...
    },
  ),
  ```

  ##### in `ChatUser.toJson`:

  Before:

  ```dart
  {
    ...
    imageType: ImageType.asset,
    ...
  }
  ```

  After:

  ```dart
  {
    ...
    imageType: asset,
    ...
  }
  ```

  ##### in `Message.fromJson`:

  Before:

  ```dart
  Message.fromJson(
    {
      ...
      'createdAt': DateTime.now(),
      'message_type': MessageType.text,
      'voice_message_duration': Duration(seconds: 5),
      ...
    }
  )
  ```

  After:

  ```dart
  Message.fromJson(
    {
      ...
      'createdAt': '2024-06-13T17:32:19.586412',
      'message_type': 'text',
      'voice_message_duration': '5000000',
      ...
    }
  )
  ```

  ##### in `Message.toJson`:

  Before:

  ```dart
  {
    ...
    createdAt: 2024-06-13 17:23:19.454789,
    message_type: MessageType.text,
    voice_message_duration: 0:00:05.000000,
    ...
  }
  ```

  After:

  ```dart
  {
    ...
    createdAt: 2024-06-13T17:32:19.586412,
    message_type: text,
    voice_message_duration: 5000000,
    ...
  }
  ```

  ##### in `ReplyMessage.fromJson`:

  Before:

  ```dart
  ReplyMessage.fromJson(
    {
      ...
      'message_type': MessageType.text,
      'voiceMessageDuration': Duration(seconds: 5),
      ...
    }
  )
  ```

  After:

  ```dart
  ReplyMessage.fromJson(
    {
      ...
      'message_type': 'text',
      'voiceMessageDuration': '5000000',
      ...
    }
  )
  ```

  in `ReplyMessage.toJson`:

  Before:

  ```dart
  {
    ...
    message_type: MessageType.text,
    voiceMessageDuration: 0:00:05.000000,
    ...
  }
  ```

  After:

  ```dart
  {
    ...
    message_type: text,
    voiceMessageDuration: 5000000,
    ...
  }
  ```

## Installing

1.  Add dependency to `pubspec.yaml`

```dart
dependencies:
  chatview: <latest-version>
```

_Get the latest version in the 'Installing' tab on [pub.dev](https://pub.dev/packages/chatview)_

2.  Import the package

```dart
import 'package:chatview/chatview.dart';
```

3. Adding a chat controller.

```dart
final chatController = ChatController(
  initialMessageList: messageList,
  scrollController: ScrollController(),
  currentUser: ChatUser(id: '1', name: 'Flutter'),
  otherUsers: [ChatUser(id: '2', name: 'Simform')],
);
```

4. Adding a `ChatView` widget.

```dart
ChatView(
  chatController: chatController,
  onSendTap: onSendTap,
  chatViewState: ChatViewState.hasMessages, // Add this state once data is available.
)
```

5. Adding a messageList with `Message` class.

```dart
List<Message> messageList = [
  Message(
    id: '1',
    message: "Hi",
    createdAt: createdAt,
    sentBy: userId,
  ),
  Message(
    id: '2',
    message: "Hello",
    createdAt: createdAt,
    sentBy: userId,
  ),
];
```

6. Adding a `onSendTap`.

```dart
void onSendTap(String message, ReplyMessage replyMessage, MessageType messageType){
  final message = Message(
    id: '3',
    message: "How are you",
    createdAt: DateTime.now(),
    sentBy: currentUser.id,
    replyMessage: replyMessage,
    messageType: messageType,
  );
  chatController.addMessage(message);
}
```

Note: you can evaluate message type from `messageType` parameter, based on that you can perform operations.

## Messages types compability

|  Message Types  | Android | iOS | MacOS | Web | Linux | Windows |
| :-------------: | :-----: | :-: | :---: | :-: | :---: | :-----: |
|  Text messages  |   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |
| Image messages  |   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |
| Voice messages  |   ✔️    | ✔️  |  ❌   | ❌  |  ❌   |   ❌    |
| Custom messages |   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |

## Platform specific configuration

### For image Picker

#### iOS

- Add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```
    <key>NSCameraUsageDescription</key>
    <string>Used to demonstrate image picker plugin</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Used to capture audio for image picker plugin</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Used to demonstrate image picker plugin</string>
```

### For voice messages

#### iOS

- Add this two rows in `ios/Runner/Info.plist`

```
    <key>NSMicrophoneUsageDescription</key>
    <string>This app requires Mic permission.</string>
```

- This plugin requires ios 10.0 or higher. So add this line in `Podfile`

```
    platform :ios, '10.0'
```

#### Android

- Change the minimum Android sdk version to 21 (or higher) in your android/app/build.gradle file.

```
    minSdkVersion 21
```

- Add RECORD_AUDIO permission in `AndroidManifest.xml`

```
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

## Some more optional parameters

1. Enable and disable specific features with `FeatureActiveConfig`.

```dart
ChatView(
  ...
  featureActiveConfig: FeatureActiveConfig(
    enableSwipeToReply: true,
    enableSwipeToSeeTime: false,
  ),
  ...
)
```

2. Adding an appbar with `ChatViewAppBar`.

```dart
ChatView(
  ...
  appBar: ChatViewAppBar(
    profilePicture: profileImage,
    chatTitle: "Simform",
    userStatus: "online",
    actions: [
      Icon(Icons.more_vert),
    ],
  ),
  ...
)
```

3. Adding a message list configuration with `ChatBackgroundConfiguration` class.

```dart
ChatView(
  ...
  chatBackgroundConfig: ChatBackgroundConfiguration(
    backgroundColor: Colors.white,
    backgroundImage: backgroundImage,
  ),
  ...
)
```

4. Adding a send message configuration with `SendMessageConfiguration` class.

```dart
ChatView(
  ...
  sendMessageConfig: SendMessageConfiguration(
    replyMessageColor: Colors.grey,
    replyDialogColor:Colors.blue,
    replyTitleColor: Colors.black,
    closeIconColor: Colors.black,
  ),
  ...
)
```

5. Adding a chat bubble configuration with `ChatBubbleConfiguration` class.

```dart
ChatView(
  ...
  chatBubbleConfig: ChatBubbleConfiguration(
    onDoubleTap: (){
       // Your code goes here
    },
    outgoingChatBubble: ChatBubble(      // Sender's message chat bubble
      color: Colors.blue,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
    ),
    incomingChatBubble: ChatBubble(      // Receiver's message chat bubble
      color: Colors.grey.shade200,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    ),
  )
  ...
)
```

6. Adding swipe to reply configuration with `SwipeToReplyConfiguration` class.

```dart
ChatView(
  ...
  swipeToReplyConfig: SwipeToReplyConfiguration(
    onLeftSwipe: (message, sentBy){
        // Your code goes here
    },
    onRightSwipe: (message, sentBy){
        // Your code goes here
    },
  ),
  ...
)
```

7. Adding messages configuration with `MessageConfiguration` class.

```dart
ChatView(
  ...
  messageConfig: MessageConfiguration(
    messageReactionConfig: MessageReactionConfiguration(),      // Emoji reaction configuration for single message
    imageMessageConfig: ImageMessageConfiguration(
      onTap: (){
          // Your code goes here
      },
      shareIconConfig: ShareIconConfiguration(
        onPressed: (){
           // Your code goes here
        },
      ),
    ),
  ),
  ...
)
```

8. Adding reaction pop-up configuration with `ReactionPopupConfiguration` class.

```dart
ChatView(
  ...
  reactionPopupConfig: ReactionPopupConfiguration(
    backgroundColor: Colors.white,
    userReactionCallback: (message, emoji){
      // Your code goes here
    }
    padding: EdgeInsets.all(12),
    shadow: BoxShadow(
      color: Colors.black54,
      blurRadius: 20,
    ),
  ),
  ...
)
```

9. Adding reply pop-up configuration with `ReplyPopupConfiguration` class.

```dart
ChatView(
  ...
  replyPopupConfig: ReplyPopupConfiguration(
    backgroundColor: Colors.white,
    onUnsendTap:(message){                   // message is 'Message' class instance
       // Your code goes here
    },
    onReplyTap:(message){                    // message is 'Message' class instance
       // Your code goes here
    },
    onReportTap:(){
       // Your code goes here
    },
    onMoreTap:(){
       // Your code goes here
    },
  ),
  ...
)
```

10. Adding replied message configuration with `RepliedMessageConfiguration` class.

```dart
ChatView(
   ...
   repliedMessageConfig: RepliedMessageConfiguration(
     backgroundColor: Colors.blue,
     verticalBarColor: Colors.black,
     repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(),
   ),
   ...
)
```

11. For customizing typing indicators use `typingIndicatorConfig` with `TypeIndicatorConfig`.

```dart
ChatView(
  ...

  typingIndicatorConfig: TypingIndicatorConfiguration(
    flashingCircleBrightColor: Colors.grey,
    flashingCircleDarkColor: Colors.black,
  ),
  ...
)

```

12. For showing hiding typeIndicatorwidget use `ChatController.setTypingIndicaor`, for more info see `ChatController`.

```dart
/// use it with your [ChatController] instance.
_chatContoller.setTypingIndicator = true; // for showing indicator
_chatContoller.setTypingIndicator = false; // for hiding indicator
```

13. Adding linkpreview configuration with `LinkPreviewConfiguration` class.

```dart
ChatView(
  ...
  chatBubbleConfig: ChatBubbleConfiguration(
    linkPreviewConfig: LinkPreviewConfiguration(
      linkStyle: const TextStyle(
        color: Colors.white,
        decoration: TextDecoration.underline,
      ),
      backgroundColor: Colors.grey,
      bodyStyle: const TextStyle(
        color: Colors.grey.shade200,
        fontSize:16,
      ),
      titleStyle: const TextStyle(
        color: Colors.black,
        fontSize:20,
      ),
    ),
  )
  ...
)
```

14. Adding pagination.

```dart
ChatView(
  ...
  isLastPage: false,
  featureActiveConfig: FeatureActiveConfig(
    enablePagination: true,
  ),
  loadMoreData: chatController.loadMoreData,
  ...
)
```

15. Add image picker configuration.

```dart
ChatView(
  ...
  sendMessageConfig: SendMessageConfiguration(
    enableCameraImagePicker: false,
    enableGalleryImagePicker: true,
    imagePickerIconsConfig: ImagePickerIconsConfiguration(
      cameraIconColor: Colors.black,
      galleryIconColor: Colors.black,
    )
  )
  ...
)
```

16. Add `ChatViewState` customisations.

```dart
ChatView(
  ...
  chatViewStateConfig: ChatViewStateConfiguration(
    loadingWidgetConfig: ChatViewStateWidgetConfiguration(
      loadingIndicatorColor: Colors.pink,
    ),
    onReloadButtonTap: () {},
  ),
  ...
)
```

17. Setting auto scroll and highlight config with `RepliedMsgAutoScrollConfig` class.

```dart
ChatView(
    ...
    repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
      enableHighlightRepliedMsg: true,
      highlightColor: Colors.grey,
      highlightScale: 1.1,
    )
    ...
)
```

18. Callback when a user starts/stops typing in `TextFieldConfiguration`

```dart
ChatView(
    ...
      sendMessageConfig: SendMessageConfiguration(

          textFieldConfig: TextFieldConfiguration(
            onMessageTyping: (status) {
                // send composing/composed status to other client
                // your code goes here
            },


        /// After typing stopped, the threshold time after which the composing
        /// status to be changed to [TypeWriterStatus.typed].
        /// Default is 1 second.
            compositionThresholdTime: const Duration(seconds: 1),

        ),
    ...
  )
)
```

19. Passing customReceipts builder or handling stuffs related receipts see `ReceiptsWidgetConfig` in outgoingChatBubble.

```dart
ChatView(
   ...
      featureActiveConfig: const FeatureActiveConfig(
            /// Controls the visibility of message seen ago receipts default is true
            lastSeenAgoBuilderVisibility: false,
            /// Controls the visibility of the message [receiptsBuilder]
            receiptsBuilderVisibility: false),
       ChatBubbleConfiguration(
          incomingChatBubble: ChatBubble(
            onMessageRead: (message) {
              /// send your message reciepts to the other client
              debugPrint('Message Read');
            },

          ),
          outgoingChatBubble: ChatBubble(
              receiptsWidgetConfig: ReceiptsWidgetConfig(
                      /// custom receipts builder
                      receiptsBuilder: _customReceiptsBuilder,
                      /// whether to display receipts in all
                      /// message or just at the last one just like instagram
                      showReceiptsIn: ShowReceiptsIn.lastMessage
              ),
            ),
        ),

  ...

)
```

20. Flag `enableOtherUserName` to hide user name in chat.

```dart
ChatView(
   ...
      featureActiveConfig: const FeatureActiveConfig(
        enableOtherUserName: false,
      ),
   ...

)
```

21. Added report button for receiver message and update `onMoreTap` and `onReportTap` callbacks.

```dart
ChatView(
   ...
      replyPopupConfig: ReplyPopupConfiguration(
        onReportTap: (Message message) {
          debugPrint('Message: $message');
        },
        onMoreTap: (Message message, bool sentByCurrentUser) {
          debugPrint('Message : $message');
        },
      ),
   ...
)
```

22. Added `emojiPickerSheetConfig` for configuration of emoji picker sheet.

```dart
ChatView(
   ...
      emojiPickerSheetConfig: Config(
        emojiViewConfig: EmojiViewConfig(
          columns: 7,
          emojiSizeMax: 32,
          recentsLimit: 28,
          backgroundColor: Colors.white,
        ),
        categoryViewConfig: const CategoryViewConfig(
          initCategory: Category.RECENT,
          recentTabBehavior: RecentTabBehavior.NONE,
        ),
  ...

)
```

23. Configure the styling & audio recording quality using `VoiceRecordingConfiguration` in sendMessageConfig.

```dart
ChatView(
    ...
      sendMessageConfig: SendMessageConfiguration(

            voiceRecordingConfiguration: VoiceRecordingConfiguration(
            iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
            androidOutputFormat: AndroidOutputFormat.mpeg4,
            androidEncoder: AndroidEncoder.aac,
            bitRate: 128000,
            sampleRate: 44100,
            waveStyle: WaveStyle(
                showMiddleLine: false,
                waveColor: theme.waveColor ?? Colors.white,
                extendWaveform: true,
            ),
        ),

    ...
  )
)
```

24. Added `enabled` to enable/disable chat text field.

```dart
ChatView(
   ...
      sendMessageConfig: SendMessageConfiguration(
      ...
        textFieldConfig: TextFieldConfig(
          enabled: true // [false] to disable text field.
        ),
      ...
      ),
  ...

)
```

25. Added flag `isProfilePhotoInBase64` that defines whether provided image is url or base64 data.

```dart
final chatController = ChatController(
  ...
    chatUsers: [
      ChatUser(
        id: '1',
        name: 'Simform',
        isProfilePhotoInBase64: false,
        profilePhoto: 'ImageNetworkUrl',
      ),
    ],
  ...
);

ChatView(
   ...
      profileCircleConfig: const ProfileCircleConfiguration(
        isProfilePhotoInBase64: false,
        profileImageUrl: 'ImageNetworkUrl',
      ),
   ...
)
```

26. Added `chatSeparatorDatePattern` in `DefaultGroupSeparatorConfiguration` to separate chats with provided pattern.

```dart
ChatView(
    ...
      chatBackgroundConfig: ChatBackgroundConfiguration(
        ...
          defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
            chatSeparatorDatePattern: 'MMM dd, yyyy'
          ),
        ...
      ),
    ...
)
```

27. Field `cancelRecordConfiguration` to provide an configuration to cancel voice record message.

```dart
ChatView(
   ...
      sendMessageConfig: SendMessageConfiguration(
        ...
           cancelRecordConfiguration: CancelRecordConfiguration(
            icon: const Icon(
              Icons.cancel_outlined,
            ),
            onCancel: () {
              debugPrint('Voice recording cancelled');
            },
            iconColor: Colors.black,
           ),
        ...
      ),
   ...

)
```

28. Added callback of onTap on list of reacted users in reaction sheet `reactedUserCallback`.

```dart

ChatView(
   ...
      messageConfig: MessageConfiguration(
      ...
        messageReactionConfig: MessageReactionConfiguration(
          reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
            reactedUserCallback: (reactedUser, reaction) {
              debugPrint(reaction);
            },
          ),
        ),
      ...
      ),
  ...
),
```

29. Added a `customMessageReplyViewBuilder` to customize reply message view for custom type message.

```dart
ChatView(
  ...
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
  ...
)
```

30. Add default avatar for profile image `defaultAvatarImage`,
    error builder for asset and network profile image `assetImageErrorBuilder` `networkImageErrorBuilder`,
    Enum `ImageType` to define image as asset, network or base64 data.

```dart
ChatView(
  ...
      appBar: ChatViewAppBar(
        defaultAvatarImage: defaultAvatar,
        imageType: ImageType.network,
        networkImageErrorBuilder: (context, url, error) {
          return Center(
            child: Text('Error $error'),
          );
        },
        assetImageErrorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text('Error $error'),
          );
        },
      ),
  ...
),
```

31. Added a `customMessageReplyViewBuilder` to customize reply message view for custom type message.

```dart
ChatView(
  ...
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
  ...
)
```

32. Added a `replyMessageBuilder` to customize view for the reply.

```dart
ChatView(
  ...
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
  ...
)
```

33. Reply Suggestions functionalities.

- Add reply suggestions

```dart
_chatController.addReplySuggestions([
      SuggestionItemData(text: 'Thanks.'),
      SuggestionItemData(text: 'Thank you very much.'),
      SuggestionItemData(text: 'Great.')
    ]);
```

- Remove reply suggestions

```dart
_chatController.removeReplySuggestions();
```

- Update suggestions Config

```dart
replySuggestionsConfig: ReplySuggestionsConfig(
    itemConfig: SuggestionItemConfig(
        decoration: BoxDecoration(),
        textStyle: TextStyle(),
        padding: EdgetInsets.all(8),
        customItemBuilder: (index, suggestionItemData) => Container()
    ),
    listConfig: SuggestionListConfig(
        decoration: BoxDecoration(),
        padding: EdgetInsets.all(8),
        itemSeparatorWidth: 8,
        axisAlignment: SuggestionListAlignment.left
    )
    onTap: (item) =>
        _onSendTap(item.text, const ReplyMessage(), MessageType.text),
    autoDismissOnSelection: true
),
```

34. Added callback `messageSorter` to sort message in `ChatBackgroundConfiguration`.

```dart
ChatView(
   ...
      chatBackgroundConfig: ChatBackgroundConfiguration(
      ...
        messageSorter: (message1, message2) {
          return message1.createdAt.compareTo(message2.createdAt);
        }
      ...
     ),
  ...
),
```

35. Use `ScrollToBottomButtonConfig` to change the configuration of scroll to bottom button.

```dart
ChatView(
  ...
    scrollToBottomButtonConfig: ScrollToBottomButtonConfig(

),
  ...
),
```

## How to use

Check out [blog](https://medium.com/simform-engineering/chatview-a-cutting-edge-chat-ui-solution-7367b1f9d772) for better understanding and basic implementation.

Also, for whole example, check out the **example** app in the [example](https://github.com/SimformSolutionsPvtLtd/flutter_chatview/tree/main/example) directory or the 'Example' tab on pub.dartlang.org for a more complete example.

## Main Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/vatsaltanna"><img src="https://avatars.githubusercontent.com/u/25323183?s=100" width="100px;" alt=""/><br /><sub><b>Vatsal Tanna</b></sub></a></td>
    <td align="center"><a href="https://github.com/DhvanitVaghani"><img src="https://avatars.githubusercontent.com/u/64645989?v=4" width="100px;" alt=""/><br /><sub><b>Dhvanit Vaghani</b></sub></a></td>
    <td align="center"><a href="https://github.com/Ujas-Majithiya"><img src="https://avatars.githubusercontent.com/u/56400956?v=4" width="100px;" alt=""/><br /><sub><b>Ujas Majithiya</b></sub></a></td>
    <td align="center"><a href="https://github.com/apurva780"><img src="https://avatars.githubusercontent.com/u/65003381?v=4" width="100px;" alt=""/><br /><sub><b>Apurva Kanthraviya</b></sub></a></td>
    <td align="center"><a href="https://github.com/aditya-chavda"><img src="https://avatars.githubusercontent.com/u/41247722?v=4" width="100px;" alt=""/><br /><sub><b>Aditya Chavda</b></sub></a></td>
  </tr>
</table>
<br/>

## License

This project is licensed under the MIT License - see
the [LICENSE](https://simform-flutter-packages.web.app/chatView/license).

[chatViewConnect]: https://pub.dev/packages/chatview_connect
