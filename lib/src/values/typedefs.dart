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

import '../models/chat_view_list_item.dart';

typedef Defaulted<T> = FutureOr<T>;

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
typedef GetMessageSeparator = (
  Map<int, DateTime> messageSeparator,
  DateTime dateTime,
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
typedef BackgroundImageLoadError = void Function(
  Object exception,
  StackTrace? stackTrace,
)?;
typedef SearchUserCallback = FutureOr<List<ChatViewListItem>?> Function(
  String value,
);
typedef ChatViewListLastMessageTileBuilder = Widget Function(
  Message? message,
);
typedef ChatViewListTextBuilder = String? Function(ChatViewListItem chat);
typedef ChatViewListWidgetBuilder = Widget? Function(ChatViewListItem chat);
typedef UpdateChatCallback = ChatViewListItem Function(
  ChatViewListItem previousChat,
);
typedef UnreadCountWidgetBuilder = Widget Function(int count);
