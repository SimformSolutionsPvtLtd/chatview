## [2.5.0]

* **Feat**: [275](https://github.com/SimformSolutionsPvtLtd/flutter_chatview/issues/275)
  Sending image with text message
* **Fix**: [294](https://github.com/SimformSolutionsPvtLtd/flutter_chatview/issues/294)
  Ensure onMessageRead is called correctly
* **Fix**: [332](https://github.com/SimformSolutionsPvtLtd/flutter_chatview/issues/332)
  Hide keyboard when tapping outside of the text field and add height field for the text field
* **Fix**: [266](https://github.com/SimformSolutionsPvtLtd/flutter_chatview/issues/266)
  Fix the keyboard overlapping the text field
* **Feat**: [296](https://github.com/SimformSolutionsPvtLtd/flutter_chatview/issues/296)
  Added support of internationalization for strings that are used in chat view
* **Fix**: [303](https://github.com/SimformSolutionsPvtLtd/flutter_chatview/issues/303)
  Hit ENTER button on PC keyboard, then send out message immediately
* **Fix**: [289](https://github.com/SimformSolutionsPvtLtd/flutter_chatview/issues/289)
  ScrollController is disposed when parent widget state changes

## [2.4.1]

* **Important**: Updated minimum SDK version to `3.4.0`
* **Refactor**: Use `chatview_utils` for data models & utils
* **Fix**: [317](https://github.com/SimformSolutionsPvtLtd/chatview/issues/317) Link Preview
  is attempted even after adding disableLinkPreview: true

## [2.4.0]

* **Feat**: [251](https://github.com/SimformSolutionsPvtLtd/chatview/issues/251) Add
  support to provide a type of suggestions item(Scrollable or Multi Line).
* **Fix**: [281](https://github.com/SimformSolutionsPvtLtd/chatview/issues/281) Fix date
  and time divider in between messages
* **Fix**: [282](https://github.com/SimformSolutionsPvtLtd/chatview/pull/282) Upgrade
  version of audio wave forms 1.2.0
* **Fix**: [276](https://github.com/SimformSolutionsPvtLtd/chatview/issues/276) link preview
  custom error message
* **Feat**: [280](https://github.com/SimformSolutionsPvtLtd/chatview/issues/280) ability to
  disable link preview
* **Fix**: [253](https://github.com/SimformSolutionsPvtLtd/chatview/issues/253)
  chatTextFieldViewKey key gets re-initialized every widget render

## [2.3.0]

* **Breaking**: [257](https://github.com/SimformSolutionsPvtLtd/chatview/issues/257) update
  onTap callback in ImageMessageConfiguration to use message object instead of image URL
* **Fix**: [254](https://github.com/SimformSolutionsPvtLtd/chatview/issues/254) Outgoing
  Message Alignment
* **Fix**: [266](https://github.com/SimformSolutionsPvtLtd/chatview/pull/266) Update
  dependencies
* **Fix**: [264](https://github.com/SimformSolutionsPvtLtd/chatview/issues/264) missing
  voice_message_configuration.dart export in models.dart
* **Fix**: [261](https://github.com/SimformSolutionsPvtLtd/chatview/issues/261)
  userReactionCallback not working
* **Fix**: [240](https://github.com/SimformSolutionsPvtLtd/chatview/issues/240)
  ScrollController Exception in ChatController.scrollToLastMessage

## [2.2.0]

* **Feat**: [246](https://github.com/SimformSolutionsPvtLtd/chatview/pull/246) add
  functionality to scroll to bottom button
* **Fix**: [247](https://github.com/SimformSolutionsPvtLtd/chatview/issues/247) fix mobile
  browser grey screen issue

## [2.1.1]

* **Fix**: [238](https://github.com/SimformSolutionsPvtLtd/chatview/issues/238) Clear
  initial message list - Exception Widget's Ancestor is unsafe

## [2.1.0]

* **Fix**: [226](https://github.com/SimformSolutionsPvtLtd/chatview/issues/226) Fixed
  the icons for starting and stopping recording were reversed
* **Fix**: [217](https://github.com/SimformSolutionsPvtLtd/chatview/pull/217) Fixed y
  position of reaction popup
* **Fix**: [233](https://github.com/SimformSolutionsPvtLtd/chatview/pull/233) swipe to reply
  gesture interaction update
* **Feat** [223](https://github.com/SimformSolutionsPvtLtd/chatview/issues/223) Ability to
  hide share icon in image view
* **Fix**: [232](https://github.com/SimformSolutionsPvtLtd/chatview/issues/232) The audio
  record cancelIcon is overflowed pixel
* **Feat** [228](https://github.com/SimformSolutionsPvtLtd/chatview/issues/228) Ability to
  completely override userReactionCallback
* **Fix**: [218](https://github.com/SimformSolutionsPvtLtd/chatview/pull/218) fix: handle
  snackBar queue while reacting on message

## [2.0.0]

* **Breaking**: [203](https://github.com/SimformSolutionsPvtLtd/chatview/pull/203) Dart
  Minimum Version 3.2.0.
* **Breaking**: [202](https://github.com/SimformSolutionsPvtLtd/chatview/pull/202)
  Message copyWith id value fix.
* **Breaking**: [173](https://github.com/SimformSolutionsPvtLtd/chatview/pull/173) Added
  callback to sort message in chat.
* **Breaking**: [178](https://github.com/SimformSolutionsPvtLtd/chatview/pull/178) Fixed
  json serializable of models and added copyWith method (Message, Reaction and Reply Message).
* **Breaking**: [181](https://github.com/SimformSolutionsPvtLtd/chatview/pull/181) Removed
  deprecated field `showTypingIndicator` from ChatView.
* **Breaking**: [188](https://github.com/SimformSolutionsPvtLtd/chatview/pull/188) update
  sendBy parameter name of Message class to sentBy
* **Breaking**: [190](https://github.com/SimformSolutionsPvtLtd/chatview/pull/190) Move
  currentUser into ChatController from ChatView widget and rename chatUsers to otherUsers
* **Feat**: [184](https://github.com/SimformSolutionsPvtLtd/chatview/pull/184) Added reply
  suggestions functionality
* **Feat**: [157](https://github.com/SimformSolutionsPvtLtd/chatview/pull/157) Added onTap
  of reacted user from reacted user list.
* **Feat**: [156](https://github.com/SimformSolutionsPvtLtd/chatview/pull/156) Added
  default avatar, error builder for asset, network and base64 profile image and
  cached_network_image for network images.
* **Feat**: [121](https://github.com/SimformSolutionsPvtLtd/chatview/pull/121) Added support
  for configuring the audio recording quality.
* **Feat**: [93](https://github.com/SimformSolutionsPvtLtd/chatview/issues/93) Added support
  that provide date pattern to change chat separation.
* **Fix**: [200](https://github.com/SimformSolutionsPvtLtd/chatview/pull/200) ChatView
  iOS Padding Issue Fix
* **Fix**: [139](https://github.com/SimformSolutionsPvtLtd/chatview/issues/139) Added
  support to customize view for the reply of any message.
* **Fix**: [174](https://github.com/SimformSolutionsPvtLtd/chatview/issues/174) Fix wrong
  username shown while replying to any messages.
* **Fix**: [134](https://github.com/SimformSolutionsPvtLtd/chatview/issues/134) Added a
  reply message view for custom message type.
* **Fix**: [137](https://github.com/SimformSolutionsPvtLtd/chatview/issues/137) Added
  support for cancel voice recording and field to provide cancel record icon.
* **Fix**: [142](https://github.com/SimformSolutionsPvtLtd/chatview/issues/142) Added field
  to provide base64 string data for profile picture.
* **Fix**: [161](https://github.com/SimformSolutionsPvtLtd/chatview/pull/161) Added field
  to set top padding of chat text field.
* **Fix**: [165](https://github.com/SimformSolutionsPvtLtd/chatview/issues/165) Fix issue of
  user reaction callback provides incorrect message object when user react on any message with
  double or from reaction sheet.
* **Fix**: [164](https://github.com/SimformSolutionsPvtLtd/chatview/issues/164) Add flag to
  enable/disable chat text field.
* **Fix**: [131](https://github.com/SimformSolutionsPvtLtd/chatview/issues/131) Fix
  unsupported operation while running on the web.
* **Fix**: [160](https://github.com/SimformSolutionsPvtLtd/chatview/pull/160) Added
  configuration for emoji picker sheet.
* **Fix**: [130](https://github.com/SimformSolutionsPvtLtd/chatview/issues/130) Added report
  button for receiver message and update onMoreTap, onReportTap callback.
* **Fix**: [126](https://github.com/SimformSolutionsPvtLtd/chatview/issues/126) Added flag
  to hide user name in chat.
* **Fix**: [182](https://github.com/SimformSolutionsPvtLtd/chatview/issues/182) Fix
  send message not working when user start texting after newLine.
* **Fix**: [191](https://github.com/SimformSolutionsPvtLtd/chatview/pull/191) Fix
  error when using `BuildContext` or `State` extensions when not mounted.
* **Fix**: [192](https://github.com/SimformSolutionsPvtLtd/chatview/pull/192) Fix
  send to closed socket or animate on `ScrollController` without clients.
* **Fix**: [194](https://github.com/SimformSolutionsPvtLtd/chatview/pull/194) Dispose
  all `ValueNotifier`s and `ScrollController`s in `ChatController`.
* **chore**: [168](https://github.com/SimformSolutionsPvtLtd/chatview/pull/168) Update
  intl to version 0.19.0.

## [1.3.1]

* **Feat**: [105](https://github.com/SimformSolutionsPvtLtd/chatview/pull/105) Allow user
  to get callback when image is picked so user can perform operation like crop. Allow user to pass
  configuration like height, width, image quality and preferredCameraDevice.
* **Fix**: [95](https://github.com/SimformSolutionsPvtLtd/chatview/issues/95) Fix issue of
  chat is added to bottom while `loadMoreData` callback.
* **Fix**: [109](https://github.com/SimformSolutionsPvtLtd/chatview/issues/109) Added
  support for the hiding/Un-hiding gallery and camera buttons

## [1.3.0]

* **Feat**: [71](https://github.com/SimformSolutionsPvtLtd/chatview/pull/71) Added Callback
  when a user starts/stops composing typing a message.
* **Fix**: [78](https://github.com/SimformSolutionsPvtLtd/chatview/pull/78) Fix issue of
  unmodifiable list.
* **Feat**: [76](https://github.com/SimformSolutionsPvtLtd/chatview/pull/76) Message
  Receipts.
* **Fix**: [81](https://github.com/SimformSolutionsPvtLtd/chatview/pull/81) Fix issue of
  TypingIndicator Rebuilding ChatView.
* **Fix**: [94](https://github.com/SimformSolutionsPvtLtd/chatview/pull/94) Fixed deprecated
  `showRecentsTab` property with new `recentTabBehavior`.
* Support for latest flutter version `3.10.5`.
* Update dependencies `http` to version `1.1.0` and `image_picker` to version
  range `'>=0.8.9 <2.0.0'`.

## [1.2.1]

* **Fix**: [60](https://github.com/SimformSolutionsPvtLtd/chatview/issues/60) Fix image from
  file is not loaded.
* **Fix**: [61](https://github.com/SimformSolutionsPvtLtd/chatview/issues/61) Fix issue of
  audio message is not working.
* **Feat**: [65](https://github.com/SimformSolutionsPvtLtd/chatview/issues/65) Add callback
  when user react on message.

## [1.2.0+1]

* **Feat**: [42](https://github.com/SimformSolutionsPvtLtd/chatview/issues/42) Ability to
  get callback on tap of profile circle avatar.
* **Breaking**: Add `messageType` in `onSendTap` callback for encountering messages.
* **Breaking**: Remove `onRecordingComplete` and you can get Recorded audio in `onSendTap` callback
  with `messageType`.
* **Breaking**: Remove `onImageSelected` from `ImagePickerIconsConfiguration` and can get selected
  image in `onSendTap` callback with `messageType`.
* **Feat**: [49](https://github.com/SimformSolutionsPvtLtd/chatview/issues/49)
  Add `onUrlDetect`
  callback for opening urls.
* **Feat**: [51](https://github.com/SimformSolutionsPvtLtd/chatview/issues/51) Ability to
  get callback on long press of profile circle avatar.

## [1.1.0]

* **Feat**: [37](https://github.com/SimformSolutionsPvtLtd/chatview/issues/37) Ability to
  enable or disable specific features.
* **Feat**: [34](https://github.com/SimformSolutionsPvtLtd/chatview/issues/34) Ability to
  add voice message.
* **Breaking**: Remove `onEmojiTap` from `ReactionPopupConfiguration`, it can be handled internally.
* **Breaking**: Remove `horizontalDragToShowMessageTime` from `ChatBackgroundConfiguration` and
  add `enableSwipeToSeeTime` parameter with same feature in `FeatureActiveConfig`.
* **Breaking**: Remove `showReceiverProfileCircle` and add `enableOtherUserProfileAvatar` parameter
  with same feature in `FeatureActiveConfig`.
*
    * **Breaking**: Move `enablePagination` parameter from `ChatView` to `FeatureActiveConfig`.

## [1.0.1]

* **Fix**: [32](https://github.com/SimformSolutionsPvtLtd/chatview/issues/32) Fix issue of
  while replying to image it highlights the link instead of the image.
* **Fix**: [35](https://github.com/SimformSolutionsPvtLtd/chatview/issues/35) Fix issue of
  removing reaction which is reacted accidentally.

## [1.0.0+1]

* **Breaking**: Remove `sender` and `receiver` from `ChatView`.
* **Breaking**: Add `currentUser` to chat view, which represent the sender.
* **Breaking**: Replace `title` and `titleTextStyle` with `chatTitle` and `chatTitleTextStyle`
  respectively in `ChatViewAppBar`
* **Breaking**: Add `profilePhoto` in `ChatUser` to show profile picture of sender.
* **Breaking**: Add `chatUsers` in `ChatController`.
* **Breaking**: Add `chatViewState` in `ChatView`.
* **Breaking**: Change type of `reaction` to `Reaction` in `Message`.
* [#8](https://github.com/SimformSolutionsPvtLtd/chatview/issues/8) Implement loading, error
  and no message UIs.
* [#13](https://github.com/SimformSolutionsPvtLtd/chatview/issues/13) Implement group chat
  and multiple reaction support.
* [#22](https://github.com/SimformSolutionsPvtLtd/chatview/issues/22) Add `TextInputType`
  for `TextField`.
* [#24](https://github.com/SimformSolutionsPvtLtd/chatview/issues/24)
  Add `MessageType.custom` for custom messages.
* **FEAT**: Auto scroll to replied message.

## [0.0.3]

* [#7](https://github.com/SimformSolutionsPvtLtd/chatview/issues/7) Add
  image-picker.

## [0.0.2]

* Fixed [#10](https://github.com/SimformSolutionsPvtLtd/chatview/issues/10) - emoji and
  text.

## [0.0.1]

* Initial release.


