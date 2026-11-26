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

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../inherited_widgets/configurations_inherited_widgets.dart';
import '../../models/config_models/chat_view/feature_active_config.dart';
import '../../values/typedefs.dart';
import '../common/profile_circle.dart';
import '../message_status/message_status_indicator.dart';
import 'chat_bubble_content.dart';
import 'chat_bubble_slide_wrapper.dart';

class ChatBubbleWidget extends StatefulWidget {
  const ChatBubbleWidget({
    required GlobalKey key,
    required this.message,
    required this.onLongPress,
    required this.slideAnimation,
    required this.onSwipe,
    this.onReplyTap,
    this.shouldHighlight = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  }) : super(key: key);

  /// Represent current instance of message.
  final Message message;

  /// Give callback once user long press on chat bubble.
  final DoubleCallBack onLongPress;

  /// Provides callback of when user swipe chat bubble for reply.
  final ValueSetter<Message> onSwipe;

  /// Provides slide animation when user swipe whole chat.
  final Animation<Offset>? slideAnimation;

  /// Provides callback when user tap on replied message upon chat bubble.
  final ValueSetter<String>? onReplyTap;

  /// Flag for when user tap on replied message and highlight actual message.
  final bool shouldHighlight;

  /// True when this is the oldest message in a consecutive same-sender group.
  /// Controls sender name visibility.
  final bool isFirstInGroup;

  /// True when this is the newest message in a consecutive same-sender group.
  /// Controls avatar visibility; a spacer is shown when false to preserve alignment.
  final bool isLastInGroup;

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  bool get isMessageBySender => widget.message.sentBy == currentUser?.id;

  bool get isLastMessage =>
      chatController?.initialMessageList.last.id == widget.message.id;

  FeatureActiveConfig? featureActiveConfig;
  ChatController? chatController;
  ChatUser? currentUser;
  int? maxDuration;

  /// Read once per dependency change; the `chatListConfig` getter does two
  /// inherited lookups on every call.
  ConfigurationsInheritedWidget? _cachedChatListConfig;

  ConfigurationsInheritedWidget get _chatListConfig =>
      _cachedChatListConfig ??= chatListConfig;

  bool _isOutsideBubbleEmoji = false;

  void _updateIsOutsideBubbleEmoji() {
    final message = widget.message;
    _isOutsideBubbleEmoji = message.messageType.isText &&
        message.message.isOutsideBubbleEmoji(
          _chatListConfig
              .messageConfig?.emojiMessageConfig?.maxOutSideBubbleEmojis,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedChatListConfig = null; // config may have changed; re-read lazily
    if (chatViewIW != null) {
      featureActiveConfig = chatViewIW!.featureActiveConfig;
      chatController = chatViewIW!.chatController;
      currentUser = chatController?.currentUser;
    }
    _updateIsOutsideBubbleEmoji();
  }

  @override
  void didUpdateWidget(ChatBubbleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `identical`, not `!=`: comparing two big image strings would read them
    // all. A wrong "changed" only costs one cheap recompute.
    if (!identical(oldWidget.message.message, widget.message.message) ||
        oldWidget.message.messageType != widget.message.messageType) {
      _updateIsOutsideBubbleEmoji();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user from id.
    final messagedUser = chatController?.getUserFromId(widget.message.sentBy);

    // showTimeInChatBubble and enableSwipeToSeeTime are mutually exclusive
    // (enforced by FeatureActiveConfig's assert). Only one can ever be true.
    final showTimeInChatBubble =
        featureActiveConfig?.showTimeInChatBubble ?? false;

    // Use swipe-to-see-time only when in-bubble timestamps are not active.
    final useSwipeToSeeTime = !showTimeInChatBubble &&
        (featureActiveConfig?.enableSwipeToSeeTime ?? true);

    final profileCircleConfig = _chatListConfig.profileCircleConfig;

    return ChatBubbleSlideWrapper(
      slideAnimation: widget.slideAnimation,
      messageTime: widget.message.createdAt,
      isCurrentUser: isMessageBySender,
      showSwipeTime: useSwipeToSeeTime,
      child: ChatBubbleContent(
        message: widget.message,
        messagedUser: messagedUser,
        isMessageBySender: isMessageBySender,
        isOutsideBubbleEmoji: _isOutsideBubbleEmoji,
        chatListConfig: _chatListConfig,
        featureActiveConfig: featureActiveConfig,
        chatController: chatController,
        currentUser: currentUser,
        onSwipe: isMessageBySender ? onLeftSwipe : onRightSwipe,
        onLongPress: widget.onLongPress,
        onMaxDuration: _onMaxDuration,
        onReplyTap: widget.onReplyTap,
        shouldHighlight: widget.shouldHighlight,
        isFirstInGroup: widget.isFirstInGroup,
        isLastInGroup: widget.isLastInGroup,
        messageStatusIndicator: MessageStatusIndicator(
          message: widget.message,
          isLast: isLastMessage,
        ),
        profileCircle: ProfileCircle(
          bottomPadding: widget.message.reaction.reactions.isNotEmpty
              ? profileCircleConfig?.bottomPadding ?? 15
              : profileCircleConfig?.bottomPadding ?? 2,
          profileCirclePadding: profileCircleConfig?.padding,
          imageUrl: messagedUser?.profilePhoto,
          imageType: messagedUser?.imageType,
          defaultAvatarImage:
              messagedUser?.defaultAvatarImage ?? Constants.profileImage,
          networkImageProgressIndicatorBuilder:
              messagedUser?.networkImageProgressIndicatorBuilder,
          assetImageErrorBuilder: messagedUser?.assetImageErrorBuilder,
          networkImageErrorBuilder: messagedUser?.networkImageErrorBuilder,
          circleRadius: profileCircleConfig?.circleRadius,
          onTap: () => _onAvatarTap(messagedUser),
          onLongPress: () => _onAvatarLongPress(messagedUser),
        ),
      ),
    );
  }

  void onRightSwipe() {
    if (maxDuration != null && widget.message.voiceMessageDuration == null) {
      widget.message.voiceMessageDuration =
          Duration(milliseconds: maxDuration!);
    }
    _chatListConfig.swipeToReplyConfig?.onRightSwipe?.call(
      widget.message.message,
      widget.message.sentBy,
    );
    widget.onSwipe(widget.message);
  }

  void onLeftSwipe() {
    if (maxDuration != null && widget.message.voiceMessageDuration == null) {
      widget.message.voiceMessageDuration =
          Duration(milliseconds: maxDuration!);
    }
    _chatListConfig.swipeToReplyConfig?.onLeftSwipe?.call(
      widget.message.message,
      widget.message.sentBy,
    );
    widget.onSwipe(widget.message);
  }

  void _onAvatarTap(ChatUser? user) {
    final onTap = _chatListConfig.profileCircleConfig?.onAvatarTap;
    if (onTap != null && user != null) onTap(user);
  }

  void _onAvatarLongPress(ChatUser? user) {
    final onLongPress = _chatListConfig.profileCircleConfig?.onAvatarLongPress;
    if (onLongPress != null && user != null) onLongPress(user);
  }

  void _onMaxDuration(int duration) => maxDuration = duration;
}
