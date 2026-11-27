![Banner](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/main/preview/banner.png)

# ChatView

[![Build](https://github.com/SimformSolutionsPvtLtd/chatview/actions/workflows/flutter.yaml/badge.svg?branch=main)](https://github.com/SimformSolutionsPvtLtd/chatview/actions) 
[![chatview](https://img.shields.io/pub/v/chatview?label=chatview)](https://pub.dev/packages/chatview)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/SimformSolutionsPvtLtd/chatview/blob/main/LICENSE)

ChatView is a Flutter package that allows you to integrate a highly customizable chat UI in your
Flutter applications with [Flexible Backend Integration][chatViewConnect].

| ChatList                                                                                                         | ChatView                                                                                                         |
|------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| ![ChatList_Preview](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/main/preview/chatlist.gif) | ![ChatView Preview](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/main/preview/chatview.gif) |

## Features

### ChatList:

- Smooth animations for adding, removing, and pinning chats
- Pagination support for large chat histories
- Search functionality by name or other criteria
- Long press menu with options like pin and mute
- User online status indicators
- Typing indicators for active users
- Unread message count badges
- Header and Footer support for additional widgets
- Highly customizable UI components
- Plug-and-play backend support using [chatview_connect][chatViewConnect]

### ChatView:

- One-on-one and group chat support
- Message reactions with emoji
- Reply to messages functionality
- `@`-mentions / tagging (with an `@everyone` entry and customizable highlight)
- Link preview for URLs
- Voice messages support
- Image sharing capabilities
- Custom message types
- Typing indicators
- Reply suggestions
- Edit Message
- Message status indicators (sent, delivered, read)
- Highly customizable UI components
- Plug-and-play backend support using [chatview_connect][chatViewConnect]

For a live web demo, visit [Chat View Example](https://simformsolutionspvtltd.github.io/chatview/).

## Documentation

Visit our [documentation](https://simform-flutter-packages.web.app/chatView) site for all
implementation details, usage instructions, code examples, and advanced features.

## Installation

```yaml
dependencies:
  chatview: <latest-version>
```

## Mentions (tagging)

Type `@` in the message field to tag group members. A suggestion list of
`chatController.otherUsers` (plus an optional `@everyone` entry) appears; the
selected mention is highlighted in the text field and in the sent bubble.

Enable the feature with `FeatureActiveConfig(enableMention: true)` and customize
it via `mentionConfig`:

```dart
ChatView(
  chatController: chatController,
  featureActiveConfig: const FeatureActiveConfig(enableMention: true),
  mentionConfig: MentionConfiguration(
    // The highlight is fully customizable; it defaults to blue + bold (used in
    // the text field and both bubbles). Because a single color can't contrast
    // with both bubble backgrounds, style each direction independently so the
    // color contrasts with that bubble:
    outgoingMentionTextStyle: const TextStyle(
      color: Colors.white, // readable on a coloured/branded outgoing bubble
      fontWeight: FontWeight.bold,
    ),
    incomingMentionTextStyle: const TextStyle(
      color: Colors.blue, // readable on a light incoming bubble
      fontWeight: FontWeight.bold,
    ),
    // Or set a single `mentionTextStyle` used for both directions + the field.
    onMentionTap: (mention) {
      // Open the tapped user's profile, etc. `mention.isEveryone` flags @everyone.
    },
  ),
  // The sent message carries its resolved mentions, so you can react to them
  // (e.g. send notifications) without a separate callback:
  onSendMessage: (message) {
    if (message.mentions.isNotEmpty) {
      // message.mentions -> List<MentionedUser> (tagged users + @everyone).
      // `message.message` is the encoded form (`@[Name](id)`); de-tokenize it
      // to the visible `@Name` form before showing it in a notification:
      final body = MentionParser().toPlainText(message.message);
      // notify(to: message.mentions, body: body);
    }
    chatController.addMessage(message); // assign your own id if needed.
  },
  // ...
)
```

Everything about the mention UI is customizable via `MentionConfiguration`:
the highlight style (shared, per-direction, and in-field), the trigger
character, the `@everyone` entry (label/id/visibility), and the suggestion
dropdown through `MentionListConfig` (max height, decoration, padding, avatar,
per-row `itemBuilder`, empty-state builder, animation).

Mentions are persisted inside the message text as tokens
(`@[Display Name](userId)`), so they survive reloads and remain correct even if
a display name changes. Use `MentionParser().toPlainText(message.message)` to
get the plain `@name` form (e.g. for notification previews).

## Compatibility with [`chatview_connect`][chatViewConnect]

| `chatview` version | [`chatview_connect`][chatViewConnect] version |
|--------------------|-----------------------------------------------|
| `>=2.4.1 <3.0.0`   | `0.0.1`                                       |
| `>= 3.0.0`         | `3.0.0`                                       |

## ChatView with Backend Support

Make `ChatView` backend-ready with [chatview_connect][chatViewConnect]

- 🔌 Easy backend integration without boilerplate (🔥 Firebase)
- ⚙️ Setup in 3 steps: set **Service Type** -> **User ID** and get **`ChatManager`**
- 💬 Supports **1-on-1** and **group chats** with **media uploads** *(audio not supported).*

## Support

For questions, issues, or feature
requests, [create an issue](https://github.com/SimformSolutionsPvtLtd/chatview/issues) on GitHub or
reach out via the GitHub Discussions tab. We're happy to help and encourage community contributions.
To contribute documentation updates specifically, please make changes to the doc/documentation.md
file and submit a pull request.

## License

This project is licensed under the MIT License - see
the [LICENSE](https://simform-flutter-packages.web.app/chatView/license).

[chatViewConnect]: https://pub.dev/packages/chatview_connect
