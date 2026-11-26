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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/config_models/chat_view/feature_active_config.dart';
import '../../models/config_models/chat_view/message/message_list_configuration.dart';
import '../../values/enumeration.dart';
import '../../values/typedefs.dart';
import '../chat_bubble/chat_bubble_widget.dart';
import '../message/message_highlight_scope.dart';
import 'chat_group_header.dart';
import 'end_message_footer.dart';
import 'message_rebuild_gate.dart';
import 'message_timeline_adapter.dart';
import 'pagination_loader.dart';
import 'swipe_to_see_time.dart';

class ChatGroupedListWidget extends StatefulWidget {
  const ChatGroupedListWidget({
    required this.showPopUp,
    required this.scrollController,
    required this.assignReplyMessage,
    required this.onChatListTap,
    required this.onChatBubbleLongPress,
    required this.isEnableSwipeToSeeTime,
    super.key,
    this.loadMoreData,
    this.isLastPage,
    this.loadingWidget,
  });

  /// True while the reaction popup is open. The list then stops scrolling
  /// and swipe-to-see-time is ignored.
  ///
  /// A listenable, not a bool, so opening the popup rebuilds only the scroll
  /// physics, not the list and its bubbles.
  final ValueListenable<bool> showPopUp;

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

  /// Provides callback when user actions reaches to top and needs to load more
  /// chat
  final PaginationCallback? loadMoreData;

  /// Provides flag if there is no more next data left in list.
  final ValueGetter<bool>? isLastPage;

  /// Provides widget for loading view while pagination is enabled.
  final Widget? loadingWidget;

  @override
  State<ChatGroupedListWidget> createState() => _ChatGroupedListWidgetState();
}

class _ChatGroupedListWidgetState extends State<ChatGroupedListWidget> {
  final ValueNotifier<bool> _isNextPageLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPrevPageLoading = ValueNotifier<bool>(false);

  bool highlightMessage = false;
  final ValueNotifier<String?> _replyId = ValueNotifier(null);
  final ValueNotifier<UniqueKey> _listKey = ValueNotifier(UniqueKey());

  FeatureActiveConfig? featureActiveConfig;

  ChatController? chatController;

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      chatListConfig.chatBackgroundConfig;

  final Map<String, GlobalKey> _messageKeys = {};

  /// The messages currently shown. Read by callbacks of bubbles that are not
  /// rebuilt on every event, so they never see an older list.
  List<Message> _messages = const [];

  /// Where the list gets its [MessageTimeline]s from. Created again only when
  /// the controller, the sort setting, the order or the separators change.
  MessageTimelineAdapter? _timelineAdapter;

  static int _newestFirst(Message a, Message b) =>
      b.createdAt.compareTo(a.createdAt);

  /// The timeline to show right after [_timelineAdapter] changed, because a new
  /// subscription would otherwise show the loader until the next event.
  MessageTimeline? _initialTimeline;

  bool get isPaginationEnabled =>
      featureActiveConfig?.enablePagination ?? false;

  ValueListenable<bool>? get typingIndicatorNotifier =>
      chatController?.typingIndicatorNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      featureActiveConfig = chatViewIW!.featureActiveConfig;
      chatController = chatViewIW!.chatController
        ..registerListViewReset(() => _listKey.value = UniqueKey());
    }
    _syncTimelineAdapter();
  }

  /// Creates [_timelineAdapter], again when the controller or a setting that
  /// affects sorting or separators changes.
  ///
  /// The settings are read here, once, so handling a stream event never reads
  /// the context.
  void _syncTimelineAdapter() {
    final controller = chatController;
    if (controller == null) return;

    final config = chatBackgroundConfig;
    final adapter = MessageTimelineAdapter(
      controller: controller,
      sortEnable: config.sortEnable,
      sorter: config.messageSorter ?? _newestFirst,
      order: config.groupedListOrder,
      enableSeparator: featureActiveConfig?.enableChatSeparator ?? false,
    );
    if (adapter == _timelineAdapter) {
      // Only the sorter can differ. Keep the adapter, its stream and the list
      // mounted, and sort the next events with the new one.
      _timelineAdapter!.sorter = adapter.sorter;
      return;
    }

    // Show the current messages right away, so the first frame already has
    // the bubbles. Only the first call with no messages keeps the loader until
    // the first stream event, like a host that shows `hasMessages` while it is
    // still fetching.
    final current = adapter.current;
    final isFirstCall = _timelineAdapter == null;
    _initialTimeline = isFirstCall && current.messages.isEmpty ? null : current;
    _timelineAdapter = adapter;
  }

  @override
  Widget build(BuildContext context) {
    return SwipeToSeeTime(
      enable: widget.isEnableSwipeToSeeTime,
      isPaused: widget.showPopUp,
      onTap: widget.onChatListTap,
      snapBackCurve: chatBackgroundConfig.messageTimeAnimationCurve,
      builder: (context, slideAnimation) => StreamBuilder<MessageTimeline>(
        // A new adapter gets a fresh builder, so no stale snapshot is shown.
        key: ObjectKey(_timelineAdapter),
        stream: _timelineAdapter?.stream,
        initialData: _initialTimeline,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: chatBackgroundConfig.loadingWidget ??
                  const CircularProgressIndicator.adaptive(),
            );
          } else {
            final enableSeparator =
                featureActiveConfig?.enableChatSeparator ?? false;
            final timeline = snapshot.data!;
            final messages = _messages = timeline.messages;
            final messageSeparator = timeline.separators;
            final separatorCounts = timeline.separatorCounts;

            final messageLength = messages.length;

            final itemCount = enableSeparator
                ? messageLength + messageSeparator.length
                : messageLength;

            return NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) => _onScrollUpdateNotification(
                notification,
                messages,
              ),
              child: ListenableBuilder(
                // Not chatTextFieldHeight: a height change only moves the
                // bottom spacer below, it must not rebuild every bubble.
                listenable: Listenable.merge([_listKey, _isPrevPageLoading]),
                builder: (context, child) {
                  // Whether to reserve an extra slot at the top (the list is
                  // reversed) for the previous-page loader.
                  final showPrevPageLoader = _isPrevPageLoading.value;

                  // Derive the effective count without mutating [itemCount].
                  // Using `++itemCount` here would permanently inflate the
                  // captured [itemCount] every time this builder re-runs while
                  // [_isPrevPageLoading] is true (e.g. when the text field
                  // height changes during a load), eventually producing
                  // out-of-range indices.
                  final effectiveItemCount =
                      showPrevPageLoader ? itemCount + 1 : itemCount;

                  final listView = CustomScrollView(
                    key: _listKey.value,
                    controller: widget.scrollController,
                    reverse: true,
                    slivers: [
                      // Bottom space so the list sits above the message text
                      // field. The list is reversed, so the first sliver is the
                      // bottom one. Own listener: a height change (reply bar,
                      // multi-line input) resizes only this box.
                      if (chatViewIW case final iw?)
                        ValueListenableBuilder<double>(
                          valueListenable: iw.chatTextFieldHeight,
                          builder: (_, height, __) => SliverPadding(
                            padding: EdgeInsets.only(bottom: height),
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: effectiveItemCount,
                          findChildIndexCallback: (key) {
                            if (key is! ValueKey) return null;
                            final index = timeline.itemIndexes[key.value];
                            // Slot 0 is the keep-alive footer. Moving a bubble
                            // there would push the footer's element out and
                            // remount it, so that bubble is rebuilt instead.
                            return index == 0 ? null : index;
                          },
                          (context, index) {
                            // Since the list is reversed, check if it's the last item
                            // to display the loading widget at top.
                            if (showPrevPageLoader &&
                                index == effectiveItemCount - 1) {
                              return PaginationLoader(
                                key: const ValueKey(MessageListItem.loader),
                                listenable: _isPrevPageLoading,
                                loader: widget.loadingWidget,
                              );
                            }

                            /// Check [messageSeparator] contains group separator for [index]
                            if (enableSeparator &&
                                messageSeparator.containsKey(index)) {
                              final separator = messageSeparator[index]!;
                              return KeyedSubtree(
                                key: ValueKey<DateTime>(separator),
                                child: chatBackgroundConfig
                                        .groupSeparatorBuilder
                                        ?.call(separator.toString()) ??
                                    ChatGroupHeader(
                                      day: separator,
                                      groupSeparatorConfig: chatBackgroundConfig
                                          .defaultGroupSeparatorConfig,
                                    ),
                              );
                            }

                            /// By removing separators encountered till now from the [index]
                            /// so that we'll get actual index to display message in chat
                            final newIndex =
                                index - (separatorCounts[index] ?? 0);
                            final message = messages[newIndex];

                            final enableScrollToRepliedMsg = chatListConfig
                                    .repliedMessageConfig
                                    ?.repliedMsgAutoScrollConfig
                                    .enableScrollToRepliedMsg ??
                                false;
                            // ListView is reversed: index 0 = newest (bottom).
                            // isLastInGroup  → avatar shown (newest in group, visually bottom).
                            // isFirstInGroup → name shown  (oldest in group, visually top).
                            //
                            // Edited messages show an "Edited" label ABOVE the bubble,
                            // creating a visual break only on the top side. So:
                            //  • isFirstInGroup=true when THIS message is edited
                            //    (Edited label above → detach from older message above).
                            //  • isLastInGroup=true when the NEWER/below neighbor is
                            //    edited (that neighbor's Edited label visually separates
                            //    it from the current message below).
                            // The connection below the edited message is preserved so
                            // messages sent after it stay grouped with it.
                            final prevMessage =
                                newIndex > 0 ? messages[newIndex - 1] : null;
                            final isLastInGroup = newIndex == 0 ||
                                !_isSameGroup(
                                  message,
                                  messages[newIndex - 1],
                                ) ||
                                (prevMessage?.updatedAt != null);
                            final isFirstInGroup =
                                newIndex == messages.length - 1 ||
                                    !_isSameGroup(
                                      message,
                                      messages[newIndex + 1],
                                    ) ||
                                    message.updatedAt != null;

                            // Key on the id (not on the position) so the list
                            // can find the bubble again after items move.
                            final messageChild = MessageRebuildGate(
                              key: ValueKey<String>(message.id),
                              signature: MessageSignature(
                                message: message,
                                slideAnimation: slideAnimation,
                                isFirstInGroup: isFirstInGroup,
                                isLastInGroup: isLastInGroup,
                                enableScrollToRepliedMsg:
                                    enableScrollToRepliedMsg,
                                sender: chatController
                                    ?.getUserFromId(message.sentBy),
                              ),
                              builder: () => MessageHighlightScope(
                                id: message.id,
                                highlightedId: _replyId,
                                child: ChatBubbleWidget(
                                  key: _messageKeys[message.id] ??= GlobalKey(),
                                  message: message,
                                  slideAnimation: slideAnimation,
                                  onLongPress: (yCoordinate, xCoordinate) =>
                                      widget.onChatBubbleLongPress(
                                    yCoordinate,
                                    xCoordinate,
                                    message,
                                  ),
                                  onSwipe: widget.assignReplyMessage,
                                  onReplyTap: enableScrollToRepliedMsg
                                      ? (id) => _onReplyTap(id, _messages)
                                      : null,
                                  isFirstInGroup: isFirstInGroup,
                                  isLastInGroup: isLastInGroup,
                                ),
                              ),
                            );

                            return index != 0
                                ? messageChild
                                // Since the list is reversed, we need to check if
                                // we are at the first item to display the typing indicator
                                // , suggestions and loading widget.
                                : EndMessageFooter(
                                    key: const ValueKey(MessageListItem.footer),
                                    loadingWidget: widget.loadingWidget,
                                    isNextPageLoading: _isNextPageLoading,
                                    typingIndicatorNotifier:
                                        typingIndicatorNotifier,
                                    child: messageChild,
                                  );
                          },
                        ),
                      ),
                    ],
                  );

                  // Stops scrolling while the reaction popup is open. The
                  // physics come from a ScrollConfiguration so a toggle only
                  // updates the Scrollable; `listView` (and every bubble) is
                  // not rebuilt.
                  return ValueListenableBuilder<bool>(
                    valueListenable: widget.showPopUp,
                    child: listView,
                    // Always wrapped, so the tree keeps its shape and the
                    // list is not remounted on a toggle.
                    builder: (context, showPopUp, listView) =>
                        ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        physics: showPopUp
                            ? const NeverScrollableScrollPhysics()
                            : null,
                      ),
                      child: listView!,
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
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
        final onNotFound = repliedMsgConfig.onReplyTargetNotFound;
        if (onNotFound != null) {
          onNotFound(id);
        } else {
          debugPrint(
            'Failed to find message with id: $id. '
            'Please ensure to load the message in loadOldReplyMessage.',
          );
        }
        return;
      }

      await repliedMsgConfig.loadOldReplyMessage(id);
      // The chat may have been closed while the message was being fetched.
      if (!mounted) return;

      // Search for the message again in the updated message list.
      await _onReplyTap(
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

      await widget.scrollController.animateTo(
        scrollPosition,
        curve: Curves.ease,
        duration: const Duration(milliseconds: 50),
      );
      if (!mounted) return;
      await _onReplyTap(id, messages, messageIndex: index);
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
    if (!mounted) return;

    if (repliedMsgAutoScrollConfig?.enableHighlightRepliedMsg ?? false) {
      _replyId.value = id;
      // The chat may be closed before the highlight is due to be cleared.
      Future.delayed(highlightDuration, () {
        if (mounted) _replyId.value = null;
      });
    }
  }

  @override
  void dispose() {
    _replyId.dispose();
    _isNextPageLoading.dispose();
    _isPrevPageLoading.dispose();
    super.dispose();
  }

  bool _isSameGroup(Message a, Message b) {
    if (!(featureActiveConfig?.enableMessageGrouping ?? true)) return false;
    final threshold = featureActiveConfig?.messageGroupingThresholdMinutes ?? 1;
    return a.sentBy == b.sentBy &&
        a.createdAt.difference(b.createdAt).inMinutes.abs() < threshold;
  }

  bool _onScrollUpdateNotification(
    ScrollUpdateNotification notification,
    List<Message> messages,
  ) {
    // Always false: true would stop the notification here and starve any
    // NotificationListener the host app has above the ChatView.
    if (!isPaginationEnabled) return false;

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

    if (result.direction == null || result.message == null) return false;

    _pagination(direction: result.direction!, message: result.message!);
    return false;
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
        if (_isPrevPageLoading.value) return;
        _isPrevPageLoading.value = true;
        unawaited(
          widget.loadMoreData?.call(direction, message).whenComplete(() {
            // The chat may be closed before the page finishes loading.
            if (mounted) _isPrevPageLoading.value = false;
          }),
        );
      case ChatPaginationDirection.next:
        if (_isNextPageLoading.value) return;
        _isNextPageLoading.value = true;
        unawaited(
          widget.loadMoreData?.call(direction, message).whenComplete(() {
            // The chat may be closed before the page finishes loading.
            if (mounted) _isNextPageLoading.value = false;
          }),
        );
    }
  }
}
