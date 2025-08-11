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
import '../models/config_models/message_list_configuration.dart';
import '../models/config_models/send_message_configuration.dart';
import '../models/config_models/suggestion_list_config.dart';
import '../values/enumeration.dart';
import '../values/typedefs.dart';
import 'chat_bubble_widget.dart';
import 'chat_group_header.dart';
import 'suggestions/suggestion_list.dart';
import 'type_indicator_widget.dart';

class ChatGroupedListWidget extends StatefulWidget {
  const ChatGroupedListWidget({
    Key? key,
    required this.showPopUp,
    required this.scrollController,
    required this.assignReplyMessage,
    required this.onChatListTap,
    required this.onChatBubbleLongPress,
    required this.isEnableSwipeToSeeTime,
    required this.prevPageLoadingNotifier,
    required this.nextPageLoadingNotifier,
    this.textFieldConfig,
    this.loadMoreData,
    this.isLastPage,
  }) : super(key: key);

  /// Allow user to swipe to see time while reaction pop is not open.
  final bool showPopUp;

  /// Pass scroll controller
  final ScrollController scrollController;

  /// Provides callback for assigning reply message when user swipe on chat bubble.
  final ValueSetter<Message> assignReplyMessage;

  /// Provides callback when user tap anywhere on whole chat.
  final VoidCallback onChatListTap;

  /// Provides callback when user press chat bubble for certain time then usual.
  final ChatBubbleLongPressCallback onChatBubbleLongPress;

  /// Provide flag for turn on/off to see message crated time view when user
  /// swipe whole chat.
  final bool isEnableSwipeToSeeTime;

  /// Provides configuration for text field.
  final TextFieldConfiguration? textFieldConfig;

  /// Provides notifier for previous page loading.
  final ValueNotifier<bool> prevPageLoadingNotifier;

  /// Provides notifier for next page loading.
  final ValueNotifier<bool> nextPageLoadingNotifier;

  /// Provides callback when user actions reaches to top and needs to load more
  /// chat
  final PaginationCallback? loadMoreData;

  /// Provides flag if there is no more next data left in list.
  final ValueGetter<bool>? isLastPage;

  @override
  State<ChatGroupedListWidget> createState() => _ChatGroupedListWidgetState();
}

class _ChatGroupedListWidgetState extends State<ChatGroupedListWidget>
    with TickerProviderStateMixin {
  bool get showPopUp => widget.showPopUp;

  bool highlightMessage = false;
  final ValueNotifier<String?> _replyId = ValueNotifier(null);
  final _listKey = ValueNotifier(UniqueKey());

  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;

  FeatureActiveConfig? featureActiveConfig;

  ChatController? chatController;

  bool get isEnableSwipeToSeeTime => widget.isEnableSwipeToSeeTime;

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      chatListConfig.chatBackgroundConfig;

  final Map<String, GlobalKey> _messageKeys = {};

  bool get isPaginationEnabled =>
      featureActiveConfig?.enablePagination ?? false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    // When this flag is on at that time only animation controllers will be
    // initialized.
    if (!isEnableSwipeToSeeTime) return;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(curve: Curves.decelerate, parent: _animationController!),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      featureActiveConfig = chatViewIW!.featureActiveConfig;
      chatController = chatViewIW!.chatController
        ..registerListViewReset(() => _listKey.value = UniqueKey());
    }
    _initializeAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsListConfig =
        suggestionsConfig?.listConfig ?? const SuggestionListConfig();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragUpdate:
                isEnableSwipeToSeeTime && !showPopUp ? _onHorizontalDrag : null,
            onHorizontalDragEnd: isEnableSwipeToSeeTime && !showPopUp
                ? (_) => _animationController?.reverse()
                : null,
            onTap: widget.onChatListTap,
            child: _animationController == null
                ? _chatStreamBuilder
                : AnimatedBuilder(
                    animation: _animationController!,
                    builder: (_, __) => _chatStreamBuilder,
                  ),
          ),
        ),
        if (chatController?.typingIndicatorNotifier case final notifier?)
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (_, showIndicator, __) => TypingIndicator(
              typeIndicatorConfig: chatListConfig.typeIndicatorConfig,
              chatBubbleConfig:
                  chatListConfig.chatBubbleConfig?.inComingChatBubbleConfig,
              showIndicator: showIndicator,
            ),
          ),
        Align(
          alignment: suggestionsListConfig.axisAlignment.alignment,
          child: const SuggestionList(),
        ),
      ],
    );
  }

  Future<void> _onReplyTap(
    String id,
    List<Message> messages, {
    int? messageIndex,
  }) async {
    final index = messageIndex == null || messageIndex.isNegative
        ? messages.indexWhere((message) => id == message.id)
        : messageIndex;

    // The message is not in the list. Notify the user to get messages around
    // it.
    if (index == -1) {
      final repliedMsgConfig = chatListConfig.repliedMessageConfig;
      if (repliedMsgConfig == null) {
        throw Exception(
          'Please provide [loadOldReplyMessage] callback in '
          '[RepliedMessageConfiguration] to load old messages.',
        );
      }

      // We have already requested user to load more data containing the message
      // id. But still the message is not found in the list.
      if (messageIndex?.isNegative ?? false) {
        throw Exception(
          'Failed to find message with id: $id. '
          'Please ensure to load the message in loadMoreData callback.',
        );
      }

      await repliedMsgConfig.loadOldReplyMessage(id);

      // Search for the message again in the updated message list.
      _onReplyTap(
        id,
        // Use the latest user updated message list.
        chatViewIW!.chatController.initialMessageList,
        // Helps stopping recursion.
        messageIndex: index,
      );
      return;
    }

    final repliedMessage = messages[index];
    final repliedMsgState = _messageKeys[repliedMessage.id]?.currentState;

    // The message is in the list but not rendered yet.
    // Scroll slightly repeatedly to ensure it is rendered.
    if (repliedMsgState == null) {
      // Calculate total scroll extent and visible portion
      final controllerPosition = widget.scrollController.position;

      // Calculate a target position based on relative index position
      // This estimates where the message might be in the list
      final scrollExtent = controllerPosition.maxScrollExtent;
      final targetPosition = scrollExtent * ((index + 1) / messages.length);

      // Start a bit before the estimated position to avoid overshooting
      final visibleHeight = controllerPosition.viewportDimension;
      final scrollPosition = targetPosition - (visibleHeight * 0.85);

      widget.scrollController
          .animateTo(
            scrollPosition,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 50),
          )
          .then((_) => _onReplyTap(id, messages, messageIndex: index));
      return;
    }

    final repliedMsgAutoScrollConfig =
        chatListConfig.repliedMessageConfig?.repliedMsgAutoScrollConfig;
    final highlightDuration = repliedMsgAutoScrollConfig?.highlightDuration ??
        const Duration(milliseconds: 300);

    // Scrolls to replied message and highlights
    await Scrollable.ensureVisible(
      repliedMsgState.context,
      curve: repliedMsgAutoScrollConfig?.highlightScrollCurve ?? Curves.easeIn,
      duration: highlightDuration,
      // This value will make widget to be in center when auto scrolled.
      alignment: repliedMsgAutoScrollConfig?.alignment ?? 0.5,
    );

    if (repliedMsgAutoScrollConfig?.enableHighlightRepliedMsg ?? false) {
      _replyId.value = id;
      Future.delayed(highlightDuration, () => _replyId.value = null);
    }
  }

  /// When user swipe at that time only animation is assigned with value.
  void _onHorizontalDrag(DragUpdateDetails details) {
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0.0),
    ).animate(
      CurvedAnimation(
        curve: chatBackgroundConfig.messageTimeAnimationCurve,
        parent: _animationController!,
      ),
    );

    details.delta.dx > 1
        ? _animationController?.reverse()
        : _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _replyId.dispose();
    super.dispose();
  }

  Widget get _chatStreamBuilder {
    var lastMatchedDate = DateTime.now();
    return StreamBuilder<List<Message>>(
      stream: chatController?.messageStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.connectionState.isActive) {
          return Center(
            child: chatBackgroundConfig.loadingWidget ??
                const CircularProgressIndicator.adaptive(),
          );
        } else {
          final data = snapshot.data!;
          final messages = chatBackgroundConfig.sortEnable
              ? sortMessage(data)
              : data.reversed.toList();

          final enableSeparator =
              featureActiveConfig?.enableChatSeparator ?? false;

          var messageSeparator = <int, DateTime>{};
          var separatorCounts = <int, int>{};

          if (enableSeparator && messages.isNotEmpty) {
            /// Get separator when date differ for two messages
            (messageSeparator, lastMatchedDate, separatorCounts) =
                _getMessageSeparator(messages, lastMatchedDate);
          } else {
            _initMessageKeys(messages);
          }

          return ValueListenableBuilder(
            valueListenable: _listKey,
            builder: (context, key, _) =>
                NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) => _onScrollUpdateNotification(
                notification,
                messages,
              ),
              child: ListView.builder(
                key: key,
                controller: widget.scrollController,
                // When reaction popup is being appeared at that user should not
                // scroll.
                physics:
                    showPopUp ? const NeverScrollableScrollPhysics() : null,
                padding: EdgeInsets.zero,
                reverse: true,
                itemCount: (enableSeparator
                    ? messages.length + messageSeparator.length
                    : messages.length),
                itemBuilder: (context, index) {
                  /// Check [messageSeparator] contains group separator for [index]
                  if (enableSeparator && messageSeparator.containsKey(index)) {
                    final separator = messageSeparator[index]!;
                    return chatBackgroundConfig.groupSeparatorBuilder
                            ?.call(separator.toString()) ??
                        ChatGroupHeader(
                          day: separator,
                          groupSeparatorConfig:
                              chatBackgroundConfig.defaultGroupSeparatorConfig,
                        );
                  }

                  /// By removing separators encountered till now from the [index]
                  /// so that we'll get actual index to display message in chat
                  var newIndex = index - (separatorCounts[index] ?? 0);

                  return ValueListenableBuilder<String?>(
                    valueListenable: _replyId,
                    builder: (context, state, child) {
                      final message = messages[newIndex];
                      final messageKey =
                          _messageKeys[message.id] ??= GlobalKey();
                      final enableScrollToRepliedMsg = chatListConfig
                              .repliedMessageConfig
                              ?.repliedMsgAutoScrollConfig
                              .enableScrollToRepliedMsg ??
                          false;
                      return ChatBubbleWidget(
                        key: messageKey,
                        message: message,
                        slideAnimation: _slideAnimation,
                        onLongPress: (yCoordinate, xCoordinate) =>
                            widget.onChatBubbleLongPress(
                          yCoordinate,
                          xCoordinate,
                          message,
                        ),
                        onSwipe: widget.assignReplyMessage,
                        shouldHighlight: state == message.id,
                        onReplyTap: enableScrollToRepliedMsg
                            ? (id) => _onReplyTap(id, messages)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  List<Message> sortMessage(List<Message> messages) {
    final elements = messages.toList();
    elements.sort(
      chatBackgroundConfig.messageSorter ??
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );
    return chatBackgroundConfig.groupedListOrder.isAsc
        ? elements.toList()
        : elements.reversed.toList();
  }

  /// return DateTime by checking lastMatchedDate and message created DateTime
  DateTime _groupBy(
    Message message,
    DateTime lastMatchedDate,
  ) {
    // If the conversation is ongoing on the same date,
    // return the same date [lastMatchedDate].

    // When the conversation starts on a new date,
    // we are returning new date [message.createdAt].
    return lastMatchedDate.getDateFromDateTime ==
            message.createdAt.getDateFromDateTime
        ? lastMatchedDate
        : message.createdAt;
  }

  GetMessageSeparatorWithCounts _getMessageSeparator(
    List<Message> messages,
    DateTime lastDate,
  ) {
    var counter = 0;
    var lastMatchedDate = lastDate;
    final messageSeparator = <int, DateTime>{};

    // Build separator counts as we build the separator map
    final separatorCounts = <int, int>{
      0: 0, // Initial count since the loop starts from index 1
    };

    _messageKeys.putIfAbsent(messages.first.id, () => GlobalKey());

    // Build separator map and update counts in the same loop
    for (var i = 1; i < messages.length; i++) {
      final message = messages[i];
      _messageKeys.putIfAbsent(message.id, () => GlobalKey());
      lastMatchedDate = _groupBy(
        message,
        lastMatchedDate,
      );
      final previousDate = _groupBy(
        messages[i - 1],
        lastMatchedDate,
      );

      if (previousDate == lastMatchedDate) {
        separatorCounts[i + counter] = counter;
      } else {
        // Group separator when previous message and current message time differ
        final separatorIndex = i + counter++;
        separatorCounts[separatorIndex + 1] = counter;
        messageSeparator[separatorIndex] = previousDate;
      }
    }

    final separatorIndex = messages.length + counter;
    separatorCounts[separatorIndex + 1] = counter;
    messageSeparator[separatorIndex] = lastMatchedDate;

    return (messageSeparator, lastMatchedDate, separatorCounts);
  }

  void _initMessageKeys(List<Message> messages) {
    final messagesLength = messages.length;
    for (var i = 0; i < messagesLength; i++) {
      final message = messages[i];
      _messageKeys.putIfAbsent(message.id, () => GlobalKey());
    }
  }

  bool _onScrollUpdateNotification(
    ScrollUpdateNotification notification,
    List<Message> messages,
  ) {
    if (!isPaginationEnabled) return true;

    final metrics = notification.metrics;

    PaginationScrollUpdateResult result = (direction: null, message: null);

    final pixels = metrics.pixels;

    // Changed direction as ListView scrolls direction is reversed.
    if (pixels <= metrics.minScrollExtent) {
      result = (
        direction: ChatPaginationDirection.next,
        message: messages.firstOrNull,
      );
    } else if (pixels >= metrics.maxScrollExtent) {
      result = (
        direction: ChatPaginationDirection.previous,
        message: messages.lastOrNull,
      );
    }

    if (result.direction == null || result.message == null) return true;

    _pagination(direction: result.direction!, message: result.message!);
    return true;
  }

  void _pagination({
    required ChatPaginationDirection direction,
    required Message message,
  }) {
    if (widget.loadMoreData == null || (widget.isLastPage?.call() ?? false)) {
      return;
    }

    switch (direction) {
      case ChatPaginationDirection.previous:
        if (widget.prevPageLoadingNotifier.value) return;
        widget.prevPageLoadingNotifier.value = true;
        widget.loadMoreData
            ?.call(direction, message)
            .whenComplete(() => widget.prevPageLoadingNotifier.value = false);
      case ChatPaginationDirection.next:
        if (widget.nextPageLoadingNotifier.value) return;
        widget.nextPageLoadingNotifier.value = true;
        widget.loadMoreData
            ?.call(direction, message)
            .whenComplete(() => widget.nextPageLoadingNotifier.value = false);
    }
  }
}
