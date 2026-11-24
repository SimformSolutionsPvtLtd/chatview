# Configuration classes

Defaults are what the app sees in chatview 3.x: the constructor default, or
the value the widget falls back to when the field is `null`. Plain `null`
means a built-in look. The examples use the imports from **Basic** in
`SKILL.md`.

## FeatureActiveConfig (`featureActiveConfig`)

| Field | Default | Notes |
|---|---|---|
| `enableTextField` | `true` | `false` hides the composer, including `sendMessageBuilder` |
| `enableSwipeToReply` | `true` | |
| `enableReplySnackBar` | `true` | Long-press popup (Reply, Unsend, Edit, Report, More) |
| `enableReactionPopup` | `true` | Long-press emoji row |
| `enableDoubleTapToLike` | `true` | Double-tap adds ❤ via `setReaction`. `false` also disables `ChatBubbleConfiguration.onDoubleTap` |
| `enableMessageEditing` | `false` | "Edit" in the popup for your own text messages |
| `enablePagination` | `false` | Needed for `loadMoreData` |
| `enableSwipeToSeeTime` | `true` | Ignored when `showTimeInChatBubble` is true |
| `showTimeInChatBubble` | `false` | Time inside bubbles |
| `enableCurrentUserProfileAvatar` | `false` | |
| `enableOtherUserProfileAvatar` | `true` | |
| `enableOtherUserName` | `true` | Sender name above incoming groups |
| `enableChatSeparator` | `true` | Date separators |
| `lastSeenAgoBuilderVisibility` | `true` | "Seen …" label (not localized) under the last message when it is yours and `read` |
| `receiptsBuilderVisibility` | `true` | Status indicator of outgoing messages |
| `enableScrollToBottomButton` | `false` | Built-in composer only (not shown with `sendMessageBuilder`) |
| `enableTextSelection` | `false` | Uses `ChatBubble.textSelectionConfig` |
| `enableMessageGrouping` | `true` | Consecutive messages from one sender |
| `messageGroupingThresholdMinutes` | `1` | Messages less than this many minutes apart are grouped |
| `chainedCornerRadius` | `null` → 30 % of the bubble radius | Not applied when `ChatBubble.borderRadius` (or `ImageMessageConfiguration.borderRadius`) is set |
| `messageGroupSpacing` | `null` → `2.0` | Ignored when `ChatBubbleConfiguration.margin` is set |

## SendMessageConfiguration (`sendMessageConfig`)

| Field | Default | Notes |
|---|---|---|
| `textFieldConfig` | `null` | Pass one, or the default camera and gallery buttons do nothing |
| `textFieldBackgroundColor` | `null` → white | |
| `allowRecordingVoice` | `true` | Mic button (Android/iOS only) |
| `voiceRecordingConfiguration` | `const VoiceRecordingConfiguration()` | |
| `cancelRecordConfiguration` | `null` | Shows a cancel button while recording |
| `shouldSendImageWithText` | `false` | Picked images wait above the field. Send (shown only once text is typed) sends them as separate image messages, then the text |
| `imagePickerIconsConfig` | `null` | Icons and colors of the default camera and gallery buttons |
| `imagePickerConfiguration` | `null` | Declared but never read. Pass `imagePickerConfiguration` to your own `CameraActionButton` / `GalleryActionButton` |
| `defaultSendButtonColor`, `sendButtonIcon`, `sendButtonStyle` | `null` | Color falls back to green, icon to `Icons.send` |
| `replyDialogColor`, `replyTitleColor`, `replyMessageColor`, `closeIconColor`, `micIconColor` | `null` | Reply bar above the field |
| `selectedImageViewBuilder`, `selectedImageViewHeight`, `selectedImageMargin`, `imageBorderRadius`, `removeImageIcon`, `removeImageIconColor`, `removeImageIconSize` | `null` | With `shouldSendImageWithText` |
| `editLabel` | `null` → locale `editing` | Edit bar title |

### TextFieldConfiguration (`textFieldConfig`)

| Field | Default | Notes |
|---|---|---|
| `enabled` | `true` | `false` disables the field, send, mic and the default camera and gallery buttons |
| `hintText` | `null` → locale `message` | |
| `textStyle` | `null` → white text | Set it |
| `hintStyle`, `hintMaxLines` | `null`, `1` | |
| `maxLines`, `minLines` | `5`, `1` | |
| `leadingActions`, `trailingActions` | `null` | `List<Widget> Function(BuildContext, TextEditingController)`. `trailingActions` replaces the default camera and gallery buttons |
| `hideLeadingActionsOnType` | `true` | |
| `onMessageTyping` | `null` | `ValueSetter<TypeWriterStatus>`: send typing events |
| `compositionThresholdTime` | `1 s` | Delay before `typed` |
| `padding`, `margin`, `contentPadding`, `borderRadius`, `textInputType`, `inputFormatters`, `textCapitalization` | `null` | Capitalization falls back to `sentences`, `borderRadius` to 27, `padding` and `contentPadding` to 6 horizontal |
| `height` | `null` | Declared but never read |

### Action buttons (for `leadingActions` / `trailingActions`)

- `CameraActionButton({required icon, required onPressed, imagePickerConfiguration, color, style})`
  and `GalleryActionButton(...)`: `onPressed(String? path, ReplyMessage? reply)`.
  `path` is `null` when the pick is cancelled or fails.
- `EmojiPickerActionButton({required icon, required onPressed, required context, emojiPickerSheetConfig, height})`:
  `onPressed(String? emoji, ReplyMessage? reply)`.
- `OverlayActionButton({required icon, required actions, isLeading = false,
  onPressed, color, style})`: setting `onPressed` replaces the overlay, so
  leave it unset to show the `actions`. Each action is an
  `OverlayActionWidget({required icon, required label, required onTap})`,
  where `onTap(ReplyMessage? reply)`.
- `TextFieldActionButton({required icon, onPressed, color, style})`: a
  generic button, `onPressed(BuildContext)`.
- None of them adds a message or clears the reply bar: call `addMessage` and
  `ChatView.closeReplyMessageView(context)` yourself.

### ImagePickerConfiguration

`maxWidth`, `maxHeight`, `imageQuality`, `preferredCameraDevice` (default
rear), and `onImagePicked`: `Future<String?> Function(String? path)`, which
can return a new path (for example after cropping; `null` keeps the
original).

### VoiceRecordingConfiguration

`recorderSettings` (default `const RecorderSettings()`; holds `bitRate`,
`sampleRate`, `androidEncoderSettings`, `iosEncoderSettings`), `waveStyle`,
`padding`, `margin`, `decoration`, `backgroundColor`, `micIcon`, `stopIcon`,
`recorderIconColor`.

## ChatBubbleConfiguration (`chatBubbleConfig`)

| Field | Default | Notes |
|---|---|---|
| `outgoingChatBubbleConfig`, `inComingChatBubbleConfig` | `null` | `ChatBubble` per side |
| `onDoubleTap` | `null` | `ValueSetter<Message>`. Replaces the default ❤ reaction |
| `maxWidth` | `null` → 75 % of screen width | Applies to text and emoji-only messages only, not to image, voice or custom bubbles |
| `padding`, `margin`, `longPressAnimationDuration` | `null` | Fall back to 5 left padding, 10 bottom margin (`messageGroupSpacing` inside a group) and 250 ms |
| `disableLinkPreview` | `false` | |

`ChatBubble`: `color`, `borderRadius`, `border`, `boxShadow`, `textStyle`,
`messageTimeTextStyle`, `padding`, `margin`, `senderNameTextStyle`,
`linkPreviewConfig` (`LinkPreviewConfiguration`),
`textSelectionConfig`, `receiptsWidgetConfig` (only read on the outgoing
config), and `onMessageRead` (`ValueSetter<Message>`, called when an
incoming bubble that is not `read` is built; only used on the incoming
config).

`ReceiptsWidgetConfig`: `showReceiptsIn` (default
`ShowReceiptsIn.lastMessage`; ignored for text, image and voice bubbles when
`sendingAnimationType` is `clockToTick`), `sendingAnimationType` (default
`SendingMessageAnimationType.slideOut`), `sendingIndicatorColor`,
`receiptsBuilder` (`Widget Function(MessageStatus)`), `lastSeenAgoBuilder`
(`Widget Function(Message, String formattedDate)`).

## ChatBackgroundConfiguration (`chatBackgroundConfig`)

`backgroundColor` (default white), `backgroundImage` (URL, asset path or
`data:image` base64), `backgroundImageFit` (default `BoxFit.fill`),
`backgroundImageRepeat` (default `noRepeat`), `groupSeparatorBuilder`
(`Widget Function(String separator)`, where the string is a
`DateTime.toString()`), `defaultGroupSeparatorConfig`, `sortEnable` (default
`false`), `messageSorter` and `groupedListOrder` (default `asc`; both used
only with `sortEnable`), `messageTimeTextStyle`, `messageTimeIconColor` and
`messageTimeAnimationCurve` (default `Curves.decelerate`) for the
swipe-to-see-time label, `loadingWidget`, `padding`, `margin`, `height`,
`width`.

## MessageConfiguration (`messageConfig`)

| Field | Notes |
|---|---|
| `customMessageBuilder` | `Widget Function(Message)`. Required to show `MessageType.custom` |
| `customMessageReplyViewBuilder` | `Widget Function(ReplyMessage)`: preview of a custom message in the reply bar above the composer |
| `showReactionsOnCustomMessages` | Default `true` |
| `imageMessageConfig` | `ImageMessageConfiguration`: `onTap`, `height` (200), `width` (150), `fit` (default `BoxFit.cover`), `borderRadius`, `border`, `padding`, `margin`, `errorBuilder`, `hideShareIcon` (default `false`; the share icon does nothing until `shareIconConfig.onPressed` is set), `shareIconConfig` (`onPressed` gets the image string) |
| `voiceMessageConfig` | `VoiceMessageConfiguration`: `playerMode` (default `PlayerMode.multi`; `single` = one at a time), `showDuration` (default `true` once a `VoiceMessageConfiguration` is passed; without one the duration shows only when `Message.voiceMessageDuration` is set, and `showDuration: false` doesn't hide it in that case either), `durationFormat`, `outgoingPlayerWaveStyle`, `inComingPlayerWaveStyle` (the older `playerWaveStyle` is deprecated), `playIcon`, `pauseIcon` (`Icon Function(bool isMessageBySender)`), `enableSeekGesture` (default `true`), `durationTextStyle`, `durationTextStyleBuilder`, `decoration`, `padding` (default 8 horizontal), `margin`, `waveformPadding`, `waveformMargin`, `animationCurve` (default `Curves.easeIn`), `animationDuration` (default 500 ms) |
| `emojiMessageConfig` | `EmojiMessageConfiguration`: emoji-only messages are drawn large without a bubble. `maxOutSideBubbleEmojis` (`null` = no limit), `textStyle`, `padding` |
| `messageReactionConfig` | `MessageReactionConfiguration`: reaction chip and its bottom sheet (`reactionsBottomSheetConfig.reactedUserCallback`) |

## Popups, replies and suggestions

- `ReactionPopupConfiguration`: `userReactionCallback(Message, String emoji)`,
  `overrideUserReactionCallback` (default `false`), `emojiConfig`
  (`EmojiConfiguration(emojiList: [...], size: ...)`),
  `showGlassMorphismEffect` (default `false`), `glassMorphismConfig`,
  `backgroundColor`, `shadow`, `animationDuration`, `padding`, `margin`,
  `maxWidth`.
- `ReplyPopupConfiguration`: `onReplyTap`, `onEditTap`, `onUnsendTap`,
  `onReportTap` (all `ValueSetter<Message>`), `onMoreTap(Message, bool
  sentByCurrentUser)`, `replyPopupBuilder`, `backgroundColor`,
  `buttonTextStyle`, `topBorderColor`. "Unsend" shows for your own messages,
  "Report" for others'.
- `RepliedMessageConfiguration`: `loadOldReplyMessage` (required,
  `Future<void> Function(String messageId)`: load the replied message into
  the list when it isn't loaded), `repliedMsgAutoScrollConfig`
  (`enableScrollToRepliedMsg` and `enableHighlightRepliedMsg` default
  `true`), `repliedMessageWidgetBuilder`, colors and sizes. Without a
  `RepliedMessageConfiguration`, tapping a reply does not scroll.
- `SwipeToReplyConfiguration`: `onLeftSwipe` (your messages),
  `onRightSwipe` (others') (`(String message, String sentBy)`), icon
  colors. The reply bar opens either way.
- `ReplySuggestionsConfig`: `onTap(SuggestionItemData)` (does not send by
  itself), `autoDismissOnSelection` (default `true`; also clears the
  suggestions when the composer sends), `suggestionItemType` (default
  `scrollable`, but `multiline` when no `ReplySuggestionsConfig` is passed),
  `itemConfig`, `spaceBetweenSuggestionItemRow` (default 10, used by the
  `multiline` layout), `listConfig` (`SuggestionListConfig`: `axisAlignment`
  default `right`, `decoration`, `padding`, `margin`, `itemSeparatorWidth`
  default 8).
- `TypeIndicatorConfiguration`: `customIndicator`, `flashingCircleDarkColor`,
  `flashingCircleBrightColor`, `indicatorSize` (10), `indicatorSpacing` (4),
  `padding`.
- `ScrollToBottomButtonConfig`: `icon`, `alignment`
  (`ScrollButtonAlignment`, default `center`), `onClick`,
  `buttonDisplayOffset` (default 300: scroll distance before it shows),
  `scrollAnimationDuration`, `backgroundColor`, `border`, `borderRadius`,
  `boxShadow`, `padding`, `insidePadding`.
- `ProfileCircleConfiguration`: `onAvatarTap`, `onAvatarLongPress`
  (`ValueSetter<ChatUser>`), `circleRadius` (default 16), `padding`,
  `bottomPadding`. Bubble avatars use `ChatUser.profilePhoto`;
  `profileImageUrl`, `imageType`, `defaultAvatarImage` and the three image
  builders (`assetImageErrorBuilder`, `networkImageErrorBuilder`,
  `networkImageProgressIndicatorBuilder`) only affect the typing indicator's
  avatar. `defaultAvatarImage` is never shown, and without `profileImageUrl`
  there is no typing avatar.

## States (`chatViewStateConfig`)

`ChatViewStateConfiguration({noMessageWidgetConfig, errorWidgetConfig,
loadingWidgetConfig, onReloadButtonTap})`. Each is a
`ChatViewStateWidgetConfiguration`: `title` (default: locale `noMessage` /
`somethingWentWrong`), `subTitle`, `titleTextStyle` (default font size 22),
`subTitleTextStyle`, `imageWidget`, `widget` (replaces everything),
`loadingWidget`, `loadingIndicatorColor`, `loadingIndicatorSize` (36),
`reloadButton`, `showDefaultReloadButton` (default `true`; shown in `noData`
and `error`), `reloadButtonColor` (default `0xffEE5366`).

## ChatViewAppBar (`appBar`)

`ChatViewAppBar({required chatTitle, userStatus, profilePicture, imageType
(default network), defaultAvatarImage, actions, leading, showLeading = true,
onBackPress (default Navigator.pop), backGroundColor (default white),
backArrowColor, chatTitleTextStyle, userStatusTextStyle, elevation (default
1), padding, assetImageErrorBuilder, networkImageErrorBuilder,
networkImageProgressIndicatorBuilder})`. Without `padding` it adds the top
safe-area padding itself; a custom `padding` replaces it.

## Theming example

```dart
ChatView themedChat(ChatController c, ChatViewState state, VoidCallback retry) {
  return ChatView(
    chatController: c,
    chatViewState: state,
    appBar: const ChatViewAppBar(
      chatTitle: 'Team',
      userStatus: '3 members',
      backGroundColor: Colors.indigo,
      backArrowColor: Colors.white,
      chatTitleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
    ),
    chatBackgroundConfig:
        const ChatBackgroundConfiguration(backgroundColor: Color(0xFFF4F4F8)),
    chatBubbleConfig: const ChatBubbleConfiguration(
      outgoingChatBubbleConfig: ChatBubble(
        color: Colors.indigo,
        textStyle: TextStyle(color: Colors.white),
        receiptsWidgetConfig: ReceiptsWidgetConfig(
          sendingAnimationType: SendingMessageAnimationType.clockToTick,
        ),
      ),
      inComingChatBubbleConfig: ChatBubble(
        color: Colors.white,
        textStyle: TextStyle(color: Colors.black87),
      ),
    ),
    chatViewStateConfig: ChatViewStateConfiguration(
      onReloadButtonTap: retry,
      noMessageWidgetConfig:
          const ChatViewStateWidgetConfiguration(title: 'Say hi 👋'),
    ),
    typeIndicatorConfig: const TypeIndicatorConfiguration(
      flashingCircleDarkColor: Colors.grey,
    ),
    sendMessageConfig: const SendMessageConfiguration(
      textFieldBackgroundColor: Colors.white,
      textFieldConfig: TextFieldConfiguration(
        textStyle: TextStyle(color: Colors.black87),
      ),
    ),
  );
}
```

## Localization (ChatViewLocale)

`PackageStrings` is global. Register a locale, then select it before the
chat screen builds (`setLocale` asserts that the locale was added). The
default is `ChatViewLocale.en`. `ChatViewLocale` has 33 required strings and
no `copyWith`. `ChatViewLocale.fromMap` exists but turns missing required
keys into empty strings. The same strings are used by `ChatList`.

```dart
void useSpanish() {
  PackageStrings.addLocaleObject(
    'es',
    const ChatViewLocale(
      today: 'Hoy',
      yesterday: 'Ayer',
      repliedToYou: 'Te respondió',
      repliedBy: 'Respondido por',
      more: 'Más',
      unsend: 'Anular envío',
      reply: 'Responder',
      replyTo: 'Respondiendo a',
      message: 'Mensaje',
      reactionPopupTitle: 'Mantén pulsado para reaccionar',
      photo: 'Foto',
      send: 'Enviar',
      you: 'Tú',
      report: 'Reportar',
      noMessage: 'Sin mensajes',
      somethingWentWrong: 'Algo salió mal',
      reload: 'Recargar',
      search: 'Buscar',
      now: 'Ahora',
      minAgo: 'min',
      voice: 'Voz',
      typing: 'escribiendo',
      isVerb: 'está',
      areVerb: 'están',
      other: 'otro',
      others: 'otros',
      mute: 'Silenciar',
      unmute: 'Activar sonido',
      pin: 'Fijar',
      unpin: 'Desfijar',
      deleteChat: 'Eliminar chat',
      noChats: 'Sin chats',
      noSearchResults: 'Sin resultados',
      // Optional, default to English:
      edit: 'Editar',
      edited: 'Editado',
      editing: 'Editando',
      sending: 'Enviando...',
      sent: 'Enviado',
      read: 'Leído',
      notDelivered: 'No entregado',
    ),
  );
  PackageStrings.setLocale('es');
}
```
