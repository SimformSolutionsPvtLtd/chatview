/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

class FeatureActiveConfig {
  const FeatureActiveConfig({
    this.enableSwipeToReply = true,
    this.enableReactionPopup = true,
    this.enableTextField = true,
    this.enableSwipeToSeeTime = true,
    this.showTimestamp = false,
    this.enableCurrentUserProfileAvatar = false,
    this.enableOtherUserProfileAvatar = true,
    this.enableReplySnackBar = true,
    this.enablePagination = false,
    this.enableChatSeparator = true,
    this.enableDoubleTapToLike = true,
    this.lastSeenAgoBuilderVisibility = true,
    this.receiptsBuilderVisibility = true,
    this.enableOtherUserName = true,
    this.enableScrollToBottomButton = false,
    this.enableTextSelection = false,
  }) : assert(
         !(enableSwipeToSeeTime && showTimestamp),
         'FeatureActiveConfig: enableSwipeToSeeTime and showTimestamp cannot '
         'both be true at the same time. '
         'Use showTimestamp: true to display the time inside each bubble, '
         'or enableSwipeToSeeTime: true to reveal it on swipe — not both.',
       );

  /// Used for enable/disable swipe to reply.
  final bool enableSwipeToReply;

  /// Used for enable/disable reaction pop-up.
  final bool enableReactionPopup;

  /// Used for enable/disable text field.
  final bool enableTextField;

  /// Used for enable/disable swipe whole chat to see message created time.
  ///
  /// **Mutually exclusive with `showTimestamp`.**
  /// Setting both `enableSwipeToSeeTime: true` and `showTimestamp: true` will
  /// throw an [AssertionError] in debug mode.
  final bool enableSwipeToSeeTime;

  /// Used to globally control whether message timestamps are shown inside chat bubbles.
  /// Defaults to `false`.
  ///
  /// **Mutually exclusive with `enableSwipeToSeeTime`.**
  /// Setting both `showTimestamp: true` and `enableSwipeToSeeTime: true` will
  /// throw an [AssertionError] in debug mode.
  ///
  /// When `true`, timestamps are displayed inside bubbles for all message types
  /// (text, image, voice). Use `ChatBubble.messageTimeTextStyle` to customise
  /// the appearance of the timestamp text per bubble direction.
  ///
  /// See also: `enableSwipeToSeeTime`, which uses the same `ChatBubble.messageTimeTextStyle`
  /// for its per-bubble swipe-out timestamp styling.
  final bool showTimestamp;

  /// Used for enable/disable current user profile circle.
  final bool enableCurrentUserProfileAvatar;

  /// Used for enable/disable other users profile circle.
  final bool enableOtherUserProfileAvatar;

  /// Used for enable/disable reply snack bar when user long press on chat-bubble.
  final bool enableReplySnackBar;

  /// Used for enable/disable pagination.
  final bool enablePagination;

  /// Used for enable/disable chat separator widget.
  final bool enableChatSeparator;

  /// Used for enable/disable double tap to like message.
  final bool enableDoubleTapToLike;

  /// Controls the visibility of message seen ago receipts default is true
  final bool lastSeenAgoBuilderVisibility;

  /// Controls the visibility of the message [receiptsBuilder]
  final bool receiptsBuilderVisibility;

  /// Used for enable/disable other users name.
  final bool enableOtherUserName;

  /// Used for enable/disable Scroll To Bottom Button.
  final bool enableScrollToBottomButton;

  /// Used to determine whether the text can be selected.
  ///
  /// Defaults to `false`.
  final bool enableTextSelection;
}
