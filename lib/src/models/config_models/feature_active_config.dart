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
  });

  /// Used for enable/disable swipe to reply.
  final bool enableSwipeToReply;

  /// Used for enable/disable reaction pop-up.
  final bool enableReactionPopup;

  /// Used for enable/disable text field.
  final bool enableTextField;

  /// Used for enable/disable swipe whole chat to see message created time.
  final bool enableSwipeToSeeTime;

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
}
