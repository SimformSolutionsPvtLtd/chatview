---
name: chatview-migration
description: >-
  Upgrade a Flutter app from any older chatview version (0.0.x, 1.x, 2.x,
  3.0.x) to the latest release and fix every breaking change in order,
  including the ones missing from the CHANGELOG. Use when upgrading or
  bumping chatview, when `flutter analyze` fails after a chatview upgrade, or
  when code uses removed or renamed chatview API such as `sendBy:`,
  `ChatView(currentUser:`, `chatUsers:`, `showTypingIndicator:`,
  `sender:`/`receiver:`, `GroupedListOrder.ASC`, `enableCameraImagePicker`,
  `enableGalleryImagePicker`, `androidOutputFormat`, `AndroidEncoder.aac`,
  `VoiceRecordingConfiguration(sampleRate:`, `isLastPage: true`,
  `loadMoreData: () async`, `RepliedMessageConfiguration(` without
  `loadOldReplyMessage`, `playIcon: Icon(`, `message.key`,
  `PackageStrings.today`, `MessageCallBack`, `VoidCallBack`,
  `ChatBubbleConfiguration(receiptsWidgetConfig:`, `onEmojiTap` or
  `updateAt`.
---

# chatview: migrate to the latest version

chatview had breaking releases at 1.0.0, 1.1.0, 1.2.0, 2.0.0, 2.1.0,
2.3.0, 2.4.1, 2.5.0 and 3.0.0. Many breaks are not marked in the CHANGELOG,
and several compile but change behavior. The references list every change
with what to search for, before and after code.

## Workflow

1. **Detect the current version.** Read the resolved `chatview` version in
   `pubspec.lock` (fall back to the constraint in `pubspec.yaml`). In a
   monorepo, do this for every package that depends on chatview.
2. **Find usages.** Search the app (`lib/`, `test/`, `integration_test/`)
   for `package:chatview` imports and for the identifiers listed in each
   reference you will apply. Report the version, the releases to cross and
   what you found **before editing**.
3. **Upgrade the dependency:** `flutter pub upgrade --major-versions chatview`.
   Never hard-code a version. If resolution fails, see
   `references/3.0-to-latest.md` (exact dependency pins) and the SDK table
   below.
4. **Apply each release's changes in order**, starting with the first
   release after the app's version, using the version index below. Read the
   whole reference for every range you cross; within a reference, skip
   sections whose "From < X" is at or below the app's version.
5. Run `flutter analyze` and fix every remaining error and warning,
   including deprecations from chatview.
6. **Re-check platform setup** if you crossed a release that changed it (see
   "SDK and platform requirements").
7. Run `dart run skills@ get` so the app's coding agents get the skills of
   the new version. It needs Dart 3.10 or later: if the app's SDK is older,
   skip this step and tell the user to upgrade Flutter and run it later.
8. Report what changed, plus the behavior changes the user should test
   (listed under "Check after migrating").

For features added in the new version, use the `chatview-chat-screen`
(`ChatView`) and `chatview-chat-list` (`ChatList`) skills.

## Rules

- Import only `package:chatview/chatview.dart`. It re-exports
  `chatview_utils` (`ChatController`, `Message`, `ChatUser`, …), the
  `audio_waveforms` recorder types and `emoji_picker_flutter`. Replace any
  `package:chatview/src/...` import, and don't add `chatview_utils` as a
  direct dependency.
- The "after" snippets are written against the latest version. When a later
  release changes the same code again, writing the latest form directly is
  correct; still read every crossed reference, because each one also has
  changes the others don't.
- Don't stop at a clean `flutter analyze`. These changes compile but behave
  differently; check them whenever the range is crossed:
  - < 2.4.1: `chatController.otherUsers.add(...)` silently does nothing.
  - < 2.5.0: the app must call `chatController.dispose()`.
  - < 3.0.0: `SendMessageConfiguration.imagePickerConfiguration` is ignored,
    and the default camera/gallery buttons are disabled without a
    `textFieldConfig`.
  - < 2.0.0: stored message JSON uses old keys.
- Keep app behavior: when a default changed (reactions on custom messages,
  message grouping, voice duration), ask the user whether to keep the old
  look before adding the opt-out.
- Don't invent replacements for removed fields that had none; delete them
  and tell the user.

## Version index

| Crossing | Reference | Summary |
|---|---|---|
| 0.0.x → 1.3.x | `references/to-1.0.0.md` | `sender`/`receiver` → controller users, required `chatViewState`, `chatTitle`, `Reaction` model, named `setReaction`, `onEmojiTap` removed, flags moved to `FeatureActiveConfig`, image/voice sent through `onSendTap` with `MessageType` |
| 1.x → 2.0.0 | `references/1.x-to-2.0.0.md` | `currentUser` and `otherUsers` on `ChatController`, `sendBy` → `sentBy`, new JSON format, `showTypingIndicator` → `setTypingIndicator`, `GroupedListOrder.asc`, `ReplyPopupConfiguration` callbacks take the message |
| 2.0.x – 2.4.x → 2.5.0 | `references/2.x-to-2.5.0.md` | 2.1.0 swipe `animationDuration` removed; 2.3.0 image `onTap(message)`; 2.4.1 models in `chatview_utils`, read-only `otherUsers` and `statusNotifier`; 2.5.0 app disposes the controller, callback typedefs and `PackageStrings` constants removed, dead config fields removed |
| 2.5.x → 3.0.0 | `references/2.x-to-3.0.0.md` | required `loadOldReplyMessage`, two-way `loadMoreData`, `isLastPage` getter, text field actions replace picker flags, `RecorderSettings`, play/pause icon builders, `Message.key` removed, 16 new `ChatViewLocale` strings |
| 3.0.x → latest | `references/3.0-to-latest.md` | `updateAt` → `updatedAt`, exact dependency pins, message grouping and voice duration on by default, image `fit` and sending indicator defaults |

Example: an app on 2.3.0 applies `references/2.x-to-2.5.0.md` from the
"From < 2.4.1" section on, then `references/2.x-to-3.0.0.md`, then
`references/3.0-to-latest.md`.

## SDK and platform requirements

| Since | Requirement | Action |
|---|---|---|
| 1.3.0 | Dart ≥ 3.0.3 | |
| 2.0.0 | Dart ≥ 3.2.0 | |
| 2.4.1 | Dart ≥ 3.4.0 | raise `environment: sdk:` in the app's `pubspec.yaml` to at least `^3.4.0` and use a Flutter release that ships Dart ≥ 3.4 |
| 3.0.0 | iOS 13.0 (documented) | `platform :ios, '13.0'` in `ios/Podfile`, deployment target ≥ 13.0 |
| 3.1.0 | Android `minSdk` 24 | chatview pins `image_picker` 1.2.2, whose `image_picker_android` needs `minSdk` 24 (`audio_waveforms` alone needs 21). Set `minSdk = flutter.minSdkVersion` or 24 in `android/app/build.gradle` |

Unchanged since 1.x: iOS `NSCameraUsageDescription`,
`NSPhotoLibraryUsageDescription` and `NSMicrophoneUsageDescription` in
`Info.plist`, and the Android `RECORD_AUDIO` permission for voice messages.
Verify they are present if the app uses images or voice.

## Check after migrating

Tell the user to test these on a device, for the ranges crossed:

- Sending text, image (camera and gallery) and voice messages, and replying.
- Opening and leaving the chat screen repeatedly (controller disposal,
  < 2.5.0).
- Scrolling up through history and tapping a reply to an old message
  (pagination and `loadOldReplyMessage`, < 3.0.0).
- Messages loaded from storage or the backend (JSON keys, < 2.0.0).
- The look of custom messages, grouped bubbles, voice bubbles and image
  bubbles (default changes, < 3.0.0 and later).
