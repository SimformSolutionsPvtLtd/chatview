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
import 'pagination_loader.dart';
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
  final ValueNotifier<bool> _isNextPageLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPrevPageLoading = ValueNotifier<bool>(false);

  ChatController get chatController => widget.chatController;

  List<Message> get messageList => chatController.initialMessageList;

  ScrollController get scrollController => chatController.scrollController;

  FeatureActiveConfig? featureActiveConfig;
  ChatUser? currentUser;

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
    if (featureActiveConfig?.enablePagination ?? false) {
      // When flag is on then it will include pagination logic to scroll
      // controller.
      scrollController.addListener(_pagination);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (featureActiveConfig?.enablePagination ?? false)
          PaginationLoader(
            listenable: _isPrevPageLoading,
            loader: widget.loadingWidget,
          ),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: chatViewIW!.showPopUp,
            builder: (_, showPopupValue, __) => ChatGroupedListWidget(
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
          ),
        ),
        if (featureActiveConfig?.enablePagination ?? false)
          PaginationLoader(
            listenable: _isNextPageLoading,
            loader: widget.loadingWidget,
          ),
        // Adds bottom space to the message list, ensuring it is displayed
        // above the message text field.
        if (chatViewIW?.chatTextFieldHeight case final height?)
          ValueListenableBuilder<double>(
            valueListenable: height,
            builder: (_, value, __) => SizedBox(height: value),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _isNextPageLoading.dispose();
    _isPrevPageLoading.dispose();
    super.dispose();
  }

  void _initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!chatController.messageStreamController.isClosed) {
        chatController.messageStreamController.add(messageList);
      }
      if (messageList.isNotEmpty) chatController.scrollToLastMessage();
    });
  }

  void _pagination() {
    if (widget.loadMoreData == null || (widget.isLastPage?.call() ?? false)) {
      return;
    }

    final position = scrollController.position;
    final pixels = position.pixels;
    if (pixels >= (position.maxScrollExtent + 5) && !_isPrevPageLoading.value) {
      _isPrevPageLoading.value = true;
      widget.loadMoreData
          ?.call(
            ChatPaginationDirection.previous,
            chatController.initialMessageList.first,
          )
          .whenComplete(() => _isPrevPageLoading.value = false);
    } else if (pixels <= (position.minScrollExtent - 5) &&
        !_isNextPageLoading.value) {
      _isNextPageLoading.value = true;
      widget.loadMoreData
          ?.call(
            ChatPaginationDirection.next,
            chatController.initialMessageList.last,
          )
          .whenComplete(() => _isNextPageLoading.value = false);
    }
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
