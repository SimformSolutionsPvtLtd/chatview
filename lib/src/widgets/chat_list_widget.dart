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
import 'dart:io' if (kIsWeb) 'dart:html';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../chatview.dart';
import '../extensions/extensions.dart';
import 'chat_groupedlist_widget.dart';
import 'reply_popup_widget.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({
    Key? key,
    required this.chatController,
    required this.assignReplyMessage,
    this.loadingWidget,
    this.loadMoreData,
    this.isLastPage,
    this.onChatListTap,
    this.textFieldConfig,
  }) : super(key: key);

  /// Provides controller for accessing few function for running chat.
  final ChatController chatController;

  /// Provides widget for loading view while pagination is enabled.
  final Widget? loadingWidget;

  /// Provides callback when user actions reaches to top and needs to load more
  /// chat
  final PaginationCallback? loadMoreData;

  /// Provides flag if there is no more next data left in list.
  final ValueGetter<bool>? isLastPage;

  /// Provides callback for assigning reply message when user swipe to chat
  /// bubble.
  final ValueSetter<Message> assignReplyMessage;

  /// Provides callback when user tap anywhere on whole chat.
  final VoidCallback? onChatListTap;

  /// Provides configuration for text field config.
  final TextFieldConfiguration? textFieldConfig;

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  ChatController get chatController => widget.chatController;

  List<Message> get messageList => chatController.initialMessageList;

  ScrollController get scrollController => chatController.scrollController;

  FeatureActiveConfig? featureActiveConfig;
  ChatUser? currentUser;

  bool get isPaginationEnabled =>
      featureActiveConfig?.enablePagination ?? false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      featureActiveConfig = chatViewIW!.featureActiveConfig;
      currentUser = chatViewIW!.chatController.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: chatViewIW!.showPopUp,
      builder: (_, showPopupValue, __) => ChatGroupedListWidget(
        isLastPage: widget.isLastPage,
        loadMoreData: widget.loadMoreData,
        loadingWidget: widget.loadingWidget,
        showPopUp: showPopupValue,
        scrollController: scrollController,
        isEnableSwipeToSeeTime:
            featureActiveConfig?.enableSwipeToSeeTime ?? true,
        assignReplyMessage: widget.assignReplyMessage,
        onChatListTap: _onChatListTap,
        textFieldConfig: widget.textFieldConfig,
        onChatBubbleLongPress: (yCoordinate, xCoordinate, message) {
          if (featureActiveConfig?.enableReactionPopup ?? false) {
            chatViewIW
              ?..reactionPopupKey.currentState?.refreshWidget(
                    message: message,
                    xCoordinate: xCoordinate,
                    yCoordinate: yCoordinate,
                  )
              ..showPopUp.value = true;
          }
          if (featureActiveConfig?.enableReplySnackBar ?? false) {
            _showReplyPopup(
              message: message,
              sentByCurrentUser: message.sentBy == currentUser?.id,
            );
          }
        },
      ),
    );
  }

  void _initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!chatController.messageStreamController.isClosed) {
        chatController.messageStreamController.add(messageList);
      }
      if (messageList.isNotEmpty) chatController.scrollToLastMessage();
    });
  }

  void _showReplyPopup({
    required Message message,
    required bool sentByCurrentUser,
  }) {
    final replyPopup = chatListConfig.replyPopupConfig;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(hours: 1),
          backgroundColor: replyPopup?.backgroundColor ?? Colors.white,
          padding: EdgeInsets.zero,
          content: replyPopup?.replyPopupBuilder?.call(
                message,
                sentByCurrentUser,
              ) ??
              ReplyPopupWidget(
                buttonTextStyle: replyPopup?.buttonTextStyle,
                topBorderColor: replyPopup?.topBorderColor,
                onMoreTap: () {
                  _onChatListTap();
                  replyPopup?.onMoreTap?.call(
                    message,
                    sentByCurrentUser,
                  );
                },
                onReportTap: () {
                  _onChatListTap();
                  replyPopup?.onReportTap?.call(
                    message,
                  );
                },
                onUnsendTap: () {
                  _onChatListTap();
                  replyPopup?.onUnsendTap?.call(
                    message,
                  );
                },
                onReplyTap: () {
                  widget.assignReplyMessage(message);
                  if (featureActiveConfig?.enableReactionPopup ?? false) {
                    chatViewIW?.showPopUp.value = false;
                  }
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  replyPopup?.onReplyTap?.call(message);
                },
                sentByCurrentUser: sentByCurrentUser,
              ),
        ),
      ).closed;
  }

  void _onChatListTap() {
    widget.onChatListTap?.call();
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      FocusScope.of(context).unfocus();
    }
    chatViewIW?.showPopUp.value = false;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
