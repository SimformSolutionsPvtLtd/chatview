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

import '../extensions/extensions.dart';
import '../models/config_models/feature_active_config.dart';
import '../utils/constants/constants.dart';
import '../values/enumeration.dart';
import '../values/typedefs.dart';
import 'chat_view_inherited_widget.dart';
import 'message_time_widget.dart';
import 'message_view.dart';
import 'profile_circle.dart';
import 'reply_message_widget.dart';
import 'swipe_to_reply.dart';

class ChatBubbleWidget extends StatefulWidget {
  const ChatBubbleWidget({
    required GlobalKey key,
    required this.message,
    required this.onLongPress,
    required this.slideAnimation,
    required this.onSwipe,
    this.onReplyTap,
    this.shouldHighlight = false,
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

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  String get replyMessage => widget.message.replyMessage.message;

  bool get isMessageBySender => widget.message.sentBy == currentUser?.id;

  bool get isLastMessage =>
      chatController?.initialMessageList.last.id == widget.message.id;

  FeatureActiveConfig? featureActiveConfig;
  ChatController? chatController;
  ChatUser? currentUser;
  int? maxDuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      featureActiveConfig = chatViewIW!.featureActiveConfig;
      chatController = chatViewIW!.chatController;
      currentUser = chatController?.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user from id.
    final messagedUser = chatController?.getUserFromId(widget.message.sentBy);
    return Stack(
      children: [
        if (featureActiveConfig?.enableSwipeToSeeTime ?? true) ...[
          Visibility(
            visible: widget.slideAnimation?.value.dx == 0.0 ? false : true,
            child: Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: MessageTimeWidget(
                  messageTime: widget.message.createdAt,
                  isCurrentUser: isMessageBySender,
                ),
              ),
            ),
          ),
          SlideTransition(
            position: widget.slideAnimation!,
            child: _chatBubbleWidget(messagedUser),
          ),
        ] else
          _chatBubbleWidget(messagedUser),
      ],
    );
  }

  Widget _chatBubbleWidget(ChatUser? messagedUser) {
    final chatBubbleConfig = chatListConfig.chatBubbleConfig;
    return Container(
      padding: chatBubbleConfig?.padding ?? const EdgeInsets.only(left: 5.0),
      margin: chatBubbleConfig?.margin ?? const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMessageBySender &&
              (featureActiveConfig?.enableOtherUserProfileAvatar ?? true))
            profileCircle(messagedUser),
          Expanded(
            child: _messagesWidgetColumn(messagedUser),
          ),
          if (isMessageBySender) ...[getReceipt()],
          if (isMessageBySender &&
              (featureActiveConfig?.enableCurrentUserProfileAvatar ?? true))
            profileCircle(messagedUser),
        ],
      ),
    );
  }

  ProfileCircle profileCircle(ChatUser? messagedUser) {
    final profileCircleConfig = chatListConfig.profileCircleConfig;
    return ProfileCircle(
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
    );
  }

  void onRightSwipe() {
    if (maxDuration != null) {
      widget.message.voiceMessageDuration =
          Duration(milliseconds: maxDuration!);
    }
    if (chatListConfig.swipeToReplyConfig?.onRightSwipe != null) {
      chatListConfig.swipeToReplyConfig?.onRightSwipe!(
          widget.message.message, widget.message.sentBy);
    }
    widget.onSwipe(widget.message);
  }

  void onLeftSwipe() {
    if (maxDuration != null) {
      widget.message.voiceMessageDuration =
          Duration(milliseconds: maxDuration!);
    }
    if (chatListConfig.swipeToReplyConfig?.onLeftSwipe != null) {
      chatListConfig.swipeToReplyConfig?.onLeftSwipe!(
          widget.message.message, widget.message.sentBy);
    }
    widget.onSwipe(widget.message);
  }

  void _onAvatarTap(ChatUser? user) {
    if (chatListConfig.profileCircleConfig?.onAvatarTap != null &&
        user != null) {
      chatListConfig.profileCircleConfig?.onAvatarTap!(user);
    }
  }

  Widget getReceipt() {
    final showReceipts = chatListConfig.chatBubbleConfig
            ?.outgoingChatBubbleConfig?.receiptsWidgetConfig?.showReceiptsIn ??
        ShowReceiptsIn.lastMessage;
    if (showReceipts == ShowReceiptsIn.all) {
      return ValueListenableBuilder(
        valueListenable: widget.message.statusNotifier,
        builder: (context, value, child) {
          if (ChatViewInheritedWidget.of(context)
                  ?.featureActiveConfig
                  .receiptsBuilderVisibility ??
              true) {
            return chatListConfig.chatBubbleConfig?.outgoingChatBubbleConfig
                    ?.receiptsWidgetConfig?.receiptsBuilder
                    ?.call(value) ??
                sendMessageAnimationBuilder(value);
          }
          return const SizedBox();
        },
      );
    } else if (showReceipts == ShowReceiptsIn.lastMessage && isLastMessage) {
      return ValueListenableBuilder(
          valueListenable:
              chatController!.initialMessageList.last.statusNotifier,
          builder: (context, value, child) {
            if (ChatViewInheritedWidget.of(context)
                    ?.featureActiveConfig
                    .receiptsBuilderVisibility ??
                true) {
              return chatListConfig.chatBubbleConfig?.outgoingChatBubbleConfig
                      ?.receiptsWidgetConfig?.receiptsBuilder
                      ?.call(value) ??
                  sendMessageAnimationBuilder(value);
            }
            return sendMessageAnimationBuilder(value);
          });
    }
    return const SizedBox();
  }

  void _onAvatarLongPress(ChatUser? user) {
    if (chatListConfig.profileCircleConfig?.onAvatarLongPress != null &&
        user != null) {
      chatListConfig.profileCircleConfig?.onAvatarLongPress!(user);
    }
  }

  Widget _messagesWidgetColumn(ChatUser? messagedUser) {
    return Column(
      crossAxisAlignment:
          isMessageBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if ((chatController?.otherUsers.isNotEmpty ?? false) &&
            !isMessageBySender &&
            (featureActiveConfig?.enableOtherUserName ?? true))
          Padding(
            padding: chatListConfig
                    .chatBubbleConfig?.inComingChatBubbleConfig?.padding ??
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              messagedUser?.name ?? '',
              style: chatListConfig.chatBubbleConfig?.inComingChatBubbleConfig
                  ?.senderNameTextStyle,
            ),
          ),
        if (replyMessage.isNotEmpty)
          chatListConfig.repliedMessageConfig?.repliedMessageWidgetBuilder !=
                  null
              ? chatListConfig.repliedMessageConfig!
                  .repliedMessageWidgetBuilder!(widget.message.replyMessage)
              : ReplyMessageWidget(
                  message: widget.message,
                  repliedMessageConfig: chatListConfig.repliedMessageConfig,
                  onTap: () => widget.onReplyTap
                      ?.call(widget.message.replyMessage.messageId),
                ),
        SwipeToReply(
          isMessageByCurrentUser: isMessageBySender,
          onSwipe: isMessageBySender ? onLeftSwipe : onRightSwipe,
          child: MessageView(
            outgoingChatBubbleConfig:
                chatListConfig.chatBubbleConfig?.outgoingChatBubbleConfig,
            isLongPressEnable:
                (featureActiveConfig?.enableReactionPopup ?? true) ||
                    (featureActiveConfig?.enableReplySnackBar ?? true),
            inComingChatBubbleConfig:
                chatListConfig.chatBubbleConfig?.inComingChatBubbleConfig,
            message: widget.message,
            isMessageBySender: isMessageBySender,
            messageConfig: chatListConfig.messageConfig,
            onLongPress: widget.onLongPress,
            chatBubbleMaxWidth: chatListConfig.chatBubbleConfig?.maxWidth,
            longPressAnimationDuration:
                chatListConfig.chatBubbleConfig?.longPressAnimationDuration,
            onDoubleTap: featureActiveConfig?.enableDoubleTapToLike ?? false
                ? chatListConfig.chatBubbleConfig?.onDoubleTap ??
                    (message) => currentUser != null
                        ? chatController?.setReaction(
                            emoji: heart,
                            messageId: message.id,
                            userId: currentUser!.id,
                          )
                        : null
                : null,
            shouldHighlight: widget.shouldHighlight,
            controller: chatController,
            highlightColor: chatListConfig.repliedMessageConfig
                    ?.repliedMsgAutoScrollConfig.highlightColor ??
                Colors.grey,
            highlightScale: chatListConfig.repliedMessageConfig
                    ?.repliedMsgAutoScrollConfig.highlightScale ??
                1.1,
            onMaxDuration: _onMaxDuration,
          ),
        ),
      ],
    );
  }

  void _onMaxDuration(int duration) => maxDuration = duration;
}
