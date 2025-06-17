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
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

typedef StringCallback = void Function(String);
typedef StringMessageCallBack = void Function(
  String message,
  ReplyMessage replyMessage,
  MessageType messageType,
);
typedef ReplyMessageWithReturnWidget = Widget Function(
  ReplyMessage? replyMessage,
);
typedef ReplyMessageCallBack = void Function(ReplyMessage replyMessage);
typedef VoidCallBack = void Function();
typedef DoubleCallBack = void Function(double, double);
typedef MessageCallBack = void Function(Message message);
typedef VoidCallBackWithFuture = Future<void> Function();
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
typedef GetMessageSeparator = (Map<int, DateTime>, DateTime);
typedef SelectedImageViewBuilder = Widget Function(
  List<String> images,
  ValueSetter<String> onImageRemove,
);
