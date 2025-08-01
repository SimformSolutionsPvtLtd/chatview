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
    this.textFieldConfig,
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

  @override
  State<ChatGroupedListWidget> createState() => _ChatGroupedListWidgetState();
}

class _ChatGroupedListWidgetState extends State<ChatGroupedListWidget>
    with TickerProviderStateMixin {
  bool get showPopUp => widget.showPopUp;

  bool highlightMessage = false;
  final ValueNotifier<String?> _replyId = ValueNotifier(null);

  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;

  FeatureActiveConfig? featureActiveConfig;

  ChatController? chatController;

  bool get isEnableSwipeToSeeTime => widget.isEnableSwipeToSeeTime;

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      chatListConfig.chatBackgroundConfig;

  final Map<String, GlobalKey> _messageKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    // When this flag is on at that time only animation controllers will be
    // initialized.
    if (isEnableSwipeToSeeTime) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      );
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(
        CurvedAnimation(
          curve: Curves.decelerate,
          parent: _animationController!,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      featureActiveConfig = chatViewIW!.featureActiveConfig;
      chatController = chatViewIW!.chatController;
    }
    _initializeAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsListConfig =
        suggestionsConfig?.listConfig ?? const SuggestionListConfig();
    return SingleChildScrollView(
      reverse: true,
      // When reaction popup is being appeared at that user should not scroll.
      physics: showPopUp ? const NeverScrollableScrollPhysics() : null,
      controller: widget.scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onHorizontalDragUpdate: (details) =>
                isEnableSwipeToSeeTime && !showPopUp
                    ? _onHorizontalDrag(details)
                    : null,
            onHorizontalDragEnd: (details) =>
                isEnableSwipeToSeeTime && !showPopUp
                    ? _animationController?.reverse()
                    : null,
            onTap: widget.onChatListTap,
            child: _animationController != null
                ? AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      return _chatStreamBuilder;
                    },
                  )
                : _chatStreamBuilder,
          ),
          if (chatController != null)
            ValueListenableBuilder(
              valueListenable: chatController!.typingIndicatorNotifier,
              builder: (context, value, child) => TypingIndicator(
                typeIndicatorConfig: chatListConfig.typeIndicatorConfig,
                chatBubbleConfig:
                    chatListConfig.chatBubbleConfig?.inComingChatBubbleConfig,
                showIndicator: value,
              ),
            ),
          if (chatController != null)
            Flexible(
              child: Align(
                alignment: suggestionsListConfig.axisAlignment.alignment,
                child: const SuggestionList(),
              ),
            ),

          // Adds bottom space to the message list, ensuring it is displayed
          // above the message text field.
          if (chatViewIW case final chatViewIWNonNull?)
            ValueListenableBuilder<double>(
              valueListenable: chatViewIWNonNull.chatTextFieldHeight,
              builder: (_, value, __) => SizedBox(height: value),
            ),
        ],
      ),
    );
  }

  Future<void> _onReplyTap(String id) async {
    // Finds the replied message if exists
    final replyMsgCurrentState = _messageKeys[id]?.currentState;
    final repliedMsgAutoScrollConfig =
        chatListConfig.repliedMessageConfig?.repliedMsgAutoScrollConfig;
    final highlightDuration = repliedMsgAutoScrollConfig?.highlightDuration ??
        const Duration(milliseconds: 300);
    // Scrolls to replied message and highlights
    if (replyMsgCurrentState != null) {
      await Scrollable.ensureVisible(
        replyMsgCurrentState.context,
        // This value will make widget to be in center when auto scrolled.
        alignment: 0.5,
        curve:
            repliedMsgAutoScrollConfig?.highlightScrollCurve ?? Curves.easeIn,
        duration: highlightDuration,
      );
      if (repliedMsgAutoScrollConfig?.enableHighlightRepliedMsg ?? false) {
        _replyId.value = id;

        Future.delayed(highlightDuration, () {
          _replyId.value = null;
        });
      }
    }
  }

  /// When user swipe at that time only animation is assigned with value.
  void _onHorizontalDrag(DragUpdateDetails details) {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
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
    DateTime lastMatchedDate = DateTime.now();
    return StreamBuilder<List<Message>>(
      stream: chatController?.messageStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.connectionState.isActive) {
          return Center(
            child: chatBackgroundConfig.loadingWidget ??
                const CircularProgressIndicator(),
          );
        } else {
          final messages = chatBackgroundConfig.sortEnable
              ? sortMessage(snapshot.data!)
              : snapshot.data!;

          final enableSeparator =
              featureActiveConfig?.enableChatSeparator ?? false;

          Map<int, DateTime> messageSeparator = {};

          if (enableSeparator) {
            /// Get separator when date differ for two messages
            (messageSeparator, lastMatchedDate) = _getMessageSeparator(
              messages,
              lastMatchedDate,
            );
          } else {
            _initMessageKeys(messages);
          }

          /// [count] that indicates how many separators
          /// needs to be display in chat
          var count = 0;

          return ListView.builder(
            key: widget.key,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: (enableSeparator
                ? messages.length + messageSeparator.length
                : messages.length),
            itemBuilder: (context, index) {
              /// By removing [count] from [index] will get actual index
              /// to display message in chat
              var newIndex = index - count;

              /// Check [messageSeparator] contains group separator for [index]
              if (enableSeparator && messageSeparator.containsKey(index)) {
                /// Increase counter each time
                /// after separating messages with separator
                count++;
                return _groupSeparator(
                  messageSeparator[index]!,
                );
              }

              return ValueListenableBuilder<String?>(
                valueListenable: _replyId,
                builder: (context, state, child) {
                  final message = messages[newIndex];
                  final messageKey = _messageKeys[message.id] ??= GlobalKey();
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
                    onReplyTap: enableScrollToRepliedMsg ? _onReplyTap : null,
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  List<Message> sortMessage(List<Message> messages) {
    final elements = [...messages];
    elements.sort(
      chatBackgroundConfig.messageSorter ??
          (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    if (chatBackgroundConfig.groupedListOrder.isAsc) {
      return elements.toList();
    } else {
      return elements.reversed.toList();
    }
  }

  /// return DateTime by checking lastMatchedDate and message created DateTime
  DateTime _groupBy(
    Message message,
    DateTime lastMatchedDate,
  ) {
    /// If the conversation is ongoing on the same date,
    /// return the same date [lastMatchedDate].

    /// When the conversation starts on a new date,
    /// we are returning new date [message.createdAt].
    return lastMatchedDate.getDateFromDateTime ==
            message.createdAt.getDateFromDateTime
        ? lastMatchedDate
        : message.createdAt;
  }

  Widget _groupSeparator(DateTime createdAt) {
    return featureActiveConfig?.enableChatSeparator ?? false
        ? _GroupSeparatorBuilder(
            separator: createdAt,
            defaultGroupSeparatorConfig:
                chatBackgroundConfig.defaultGroupSeparatorConfig,
            groupSeparatorBuilder: chatBackgroundConfig.groupSeparatorBuilder,
          )
        : const SizedBox.shrink();
  }

  GetMessageSeparator _getMessageSeparator(
    List<Message> messages,
    DateTime lastDate,
  ) {
    final messageSeparator = <int, DateTime>{};
    var lastMatchedDate = lastDate;
    var counter = 0;

    /// Holds index and separator mapping to display in chat
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      _messageKeys.putIfAbsent(message.id, () => GlobalKey());
      if (messageSeparator.isEmpty) {
        /// Separator for initial message
        messageSeparator[0] = message.createdAt;
        continue;
      }
      lastMatchedDate = _groupBy(
        message,
        lastMatchedDate,
      );
      var previousDate = _groupBy(
        messages[i - 1],
        lastMatchedDate,
      );

      if (previousDate != lastMatchedDate) {
        /// Group separator when previous message and
        /// current message time differ
        counter++;

        messageSeparator[i + counter] = messages[i].createdAt;
      }
    }

    return (messageSeparator, lastMatchedDate);
  }

  void _initMessageKeys(List<Message> messages) {
    final messagesLength = messages.length;
    for (var i = 0; i < messagesLength; i++) {
      final message = messages[i];
      _messageKeys.putIfAbsent(message.id, () => GlobalKey());
    }
  }
}

class _GroupSeparatorBuilder extends StatelessWidget {
  const _GroupSeparatorBuilder({
    Key? key,
    required this.separator,
    this.groupSeparatorBuilder,
    this.defaultGroupSeparatorConfig,
  }) : super(key: key);
  final DateTime separator;
  final StringWithReturnWidget? groupSeparatorBuilder;
  final DefaultGroupSeparatorConfiguration? defaultGroupSeparatorConfig;

  @override
  Widget build(BuildContext context) {
    return groupSeparatorBuilder != null
        ? groupSeparatorBuilder!(separator.toString())
        : ChatGroupHeader(
            day: separator,
            groupSeparatorConfig: defaultGroupSeparatorConfig,
          );
  }
}
