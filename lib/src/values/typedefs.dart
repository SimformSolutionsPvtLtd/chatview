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

import 'dart:async';

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

typedef StringMessageCallBack = void Function(
  String message,
  ReplyMessage replyMessage,
  MessageType messageType,
);
typedef ReplyMessageWithReturnWidget = Widget Function(
  ReplyMessage? replyMessage,
);
typedef DoubleCallBack = void Function(
  double yPosition,
  double xPosition,
);
typedef StringsCallBack = void Function(String emoji, String messageId);
typedef StringWithReturnWidget = Widget Function(String separator);
typedef DragUpdateDetailsCallback = void Function(DragUpdateDetails);
typedef MoreTapCallBack = void Function(
  Message message,
  bool sentByCurrentUser,
);
typedef ReactionCallback = void Function(
  Message message,
  String emoji,
);
typedef ReactedUserCallback = void Function(
  ChatUser reactedUser,
  String reaction,
);

/// customMessageType view for a reply of custom message type
typedef CustomMessageReplyViewBuilder = Widget Function(
  ReplyMessage state,
);
typedef MessageSorter = int Function(
  Message message1,
  Message message2,
);

/// customView for replying to any message
typedef CustomViewForReplyMessage = Widget Function(
  BuildContext context,
  ReplyMessage state,
);
typedef GetMessageSeparatorWithCounts = (
  Map<int, DateTime> separators,
  DateTime lastMatchedDate,
  Map<int, int> separatorCounts
);
typedef SelectedImageViewBuilder = Widget Function(
  List<String> images,
  ValueSetter<String> onImageRemove,
);
typedef CustomMessageBuilder = Widget Function(Message message);
typedef ReceiptBuilder = Widget Function(MessageStatus status);
typedef LastSeenAgoBuilder = Widget Function(
  Message message,
  String formattedDate,
);
typedef ReplyPopupBuilder = Widget Function(
  Message message,
  bool sentByCurrentUser,
);
typedef ImagePickedCallback = Future<String?> Function(String? path);
typedef OnMessageSwipeCallback = void Function(
  String message,
  String sentBy,
);
typedef ChatBubbleLongPressCallback = void Function(
  double yCordinate,
  double xCordinate,
  Message message,
);
typedef ChatTextFieldViewBuilderCallback<T> = Widget Function(
  BuildContext context,
  T value,
  Widget? child,
);
typedef TextFieldActionWidgetBuilder = List<Widget> Function(
  BuildContext context,
  TextEditingController controller,
);
typedef BackgroundImageLoadError = void Function(
  Object exception,
  StackTrace? stackTrace,
)?;
typedef SearchUserCallback = FutureOr<List<ChatListItem>?> Function(
  String value,
);
typedef ChatListLastMessageTileBuilder = Widget Function(
  // Using chat item instead of message allows for greater customization
  // based on additional chat item properties if required
  ChatListItem chat,
);
typedef ChatListTextBuilder = String? Function(ChatListItem chat);
typedef ChatListWidgetBuilder = Widget? Function(ChatListItem chat);
typedef UnreadCountWidgetBuilder = Widget Function(int count);
typedef ChatStatusCallback<T> = void Function(
  ({ChatListItem chat, T status}) result,
);
typedef DeleteChatCallback = void Function(ChatListItem chat);
typedef StatusTrailingIcon<T> = IconData Function(T status);
typedef LastMessageTimeBuilder = Widget Function(DateTime time);
typedef ChatListTileBuilder = Widget Function(
  BuildContext context,
  ChatListItem chat,
);
typedef UserAvatarBuilder = Widget Function(ChatListItem chat);
typedef UserNameBuilder = Widget Function(ChatListItem chat);
typedef TrailingBuilder = Widget Function(ChatListItem chat);
typedef MenuWidgetCallback = Widget Function(ChatListItem chat);
typedef MenuBuilderCallback = Widget Function(
  BuildContext context,
  ChatListItem chat,
  Widget child,
);
typedef MenuActionBuilder = List<Widget> Function(ChatListItem chat);
typedef AutoAnimateItemBuilder<T> = Widget Function(
  BuildContext context,
  int index,
  bool isLastItem,
  T item,
);
typedef AutoAnimateSeparatorBuilder = Widget Function(
  BuildContext context,
  int index,
);
typedef ChatPinnedCallback<T> = bool Function(T chat);
typedef ShowUserActiveIndicatorCallback = bool Function(
  UserActiveStatus status,
);
typedef ActiveStatusIndicatorColorResolver = Color Function(
  UserActiveStatus status,
);
typedef PaginationCallback = Future<void> Function(
  ChatPaginationDirection direction,
  Message message,
);
typedef OldReplyMessageFetchCallback = Future<void> Function(
  String messageId,
);
typedef PaginationScrollUpdateResult = ({
  ChatPaginationDirection? direction,
  Message? message,
});
typedef MessageStatusIconEnableCallback = bool Function(
  Message message,
);
typedef MessageStatusColorResolver = Color Function(
  MessageStatus status,
);
typedef MessageStatusIconResolver = IconData Function(
  MessageStatus status,
);
typedef MessageStatusBuilder = Widget Function(
  MessageStatus status,
);
typedef CustomVoiceActionIconCallback = Icon Function(
  bool isMessageBySender,
);
typedef CameraActionCallback = void Function(
  String? path,
  ReplyMessage? replyMessage,
);
typedef EmojiPickerActionCallback = void Function(
  String? emoji,
  ReplyMessage? replyMessage,
);
