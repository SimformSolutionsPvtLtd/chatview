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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../chat_list_view_controller.dart';
import '../models/chat_view_list_tile.dart';
import '../models/config_models/chat_view_list_config.dart';
import '../models/config_models/chat_view_list_time_config.dart';
import '../models/config_models/chat_view_list_user_config.dart';
import '../models/config_models/load_more_widget_config.dart';
import '../models/config_models/search_config.dart';
import '../models/config_models/unread_widget_config.dart';
import '../utils/constants/constants.dart';
import 'chat_list_search_text_field.dart';
import 'chat_view_list_user_widget.dart';

class ChatViewList extends StatefulWidget {
  const ChatViewList({
    super.key,
    this.config,
    required this.controller,
    this.profileWidget,
    this.trailingWidget,
    this.userNameWidget,
    this.lastMessageTimeWidget,
    this.unReadCountWidget,
    this.chatListUserWidgetBuilder,
    this.appbar,
    this.loadMoreChats,
    this.isLastPage = false,
    this.loadMoreChatWidget,
    this.showSearchTextField = true,
    this.filterChipWidget,
    this.scrollViewKeyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.onDrag,
  });

  /// Provides configuration for chat list UI.
  final ChatViewListConfig? config;

  /// Provides controller for managing the chat list.
  final ChatViewListController controller;

  /// Provides widget for profile in chat list.
  final Widget? profileWidget;

  /// Provides widget for trailing elements in chat list.
  final Widget? trailingWidget;

  /// Provides widget for user name in chat list.
  final Widget? userNameWidget;

  /// Provides widget for last message time in chat list.
  final Widget? lastMessageTimeWidget;

  /// Provides widget for unread count in chat list.
  final Widget? unReadCountWidget;

  /// Provides widget builder for users in chat list.
  final NullableIndexedWidgetBuilder? chatListUserWidgetBuilder;

  /// Provides custom app bar for chat list page.
  final Widget? appbar;

  /// Callback function that is called to load more chats when the user scrolls
  final AsyncCallback? loadMoreChats;

  /// Flag to indicate if the current page is the last page of chat data.
  final bool isLastPage;

  /// Widget to display while loading more chats.
  final Widget? loadMoreChatWidget;

  /// Flag to show/hide the search text field in the chat list.
  final bool showSearchTextField;

  /// Widget to display as a filter chip in the chat list.
  final Widget? filterChipWidget;

  /// Behavior for dismissing the keyboard when scrolling.
  final ScrollViewKeyboardDismissBehavior scrollViewKeyboardDismissBehavior;

  @override
  State<ChatViewList> createState() => _ChatViewListState();
}

class _ChatViewListState extends State<ChatViewList> {
  SearchConfig get searchConfig =>
      widget.config?.searchConfig ??
      SearchConfig(
        textEditingController: TextEditingController(),
      );

  ChatViewListTileConfig get chatViewListTileConfig =>
      widget.config?.chatViewListTileConfig ?? const ChatViewListTileConfig();

  UnreadWidgetConfig get unreadWidgetConfig =>
      widget.config?.unreadWidgetConfig ?? const UnreadWidgetConfig();

  ChatViewListTimeConfig get timeConfig =>
      widget.config?.timeConfig ??
      const ChatViewListTimeConfig(
        dateFormatPattern: defaultDateFormat,
      );

  LoadMoreChatListConfig get loadMoreChatListConfig =>
      widget.config?.loadMoreChatListConfig ?? const LoadMoreChatListConfig();

  ScrollController get scrollController => widget.controller.scrollController;

  /// ValueNotifier to track if the next page is currently loading.
  final ValueNotifier<bool> _isNextPageLoading = ValueNotifier<bool>(false);

  @override
  void didChangeDependencies() {
    if (widget.config?.enablePagination ?? false) {
      scrollController.addListener(_pagination);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      keyboardDismissBehavior: widget.scrollViewKeyboardDismissBehavior,
      slivers: [
        if (widget.appbar != null) widget.appbar!,
        if (widget.showSearchTextField)
          SliverToBoxAdapter(
            child: Padding(
              padding: searchConfig.padding ?? const EdgeInsets.all(10.0),
              child: ChatViewListSearch(
                searchConfig: searchConfig,
                chatViewListController: widget.controller,
              ),
            ),
          ),
        if (widget.filterChipWidget != null)
          SliverToBoxAdapter(
            child: widget.filterChipWidget!,
          ),
        StreamBuilder<List<ChatViewListModel>>(
          stream: widget.controller.chatListStreamController.stream,
          builder: (context, snapshot) {
            final users = snapshot.data ?? widget.controller.initialUsersList;
            final itemCount = users.isEmpty ? 0 : users.length * 2 - 1;
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: itemCount,
                (context, index) {
                  final itemIndex = index ~/ 2;
                  if (index.isOdd) {
                    return widget.config?.separatorWidget ??
                        const Divider(height: 12);
                  }
                  final user = users[itemIndex];

                  return widget.chatListUserWidgetBuilder
                          ?.call(context, itemIndex) ??
                      ChatViewListUserWidget(
                        config: widget.config,
                        user: user,
                        profileWidget: widget.profileWidget,
                        trailingWidget: widget.trailingWidget,
                        userNameWidget: widget.userNameWidget,
                        lastMessageTimeWidget: widget.lastMessageTimeWidget,
                        unReadCountWidget: widget.unReadCountWidget,
                        chatViewListTileConfig: chatViewListTileConfig,
                        unreadWidgetConfig: unreadWidgetConfig,
                        timeConfig: timeConfig,
                      );
                },
              ),
            );
          },
        ),
        // Show loading indicator at the bottom when loading next page
        SliverToBoxAdapter(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isNextPageLoading,
            builder: (context, isLoading, _) {
              if (!isLoading) return const SizedBox.shrink();
              return Padding(
                padding: loadMoreChatListConfig.padding ??
                    const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: widget.loadMoreChatWidget ??
                      CircularProgressIndicator(
                        color: loadMoreChatListConfig.color ?? primaryColor,
                      ),
                ),
              );
            },
          ),
        ),
        // Add extra space at the bottom to avoid overlap with iOS home bar
        SliverToBoxAdapter(
          child: SizedBox(
            height: widget.config?.extraSpaceAtLast ?? 32.0,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.config?.enablePagination ?? false) {
      scrollController.removeListener(_pagination);
    }
    _isNextPageLoading.dispose();
    super.dispose();
  }

  void _pagination() {
    if (widget.loadMoreChats == null || widget.isLastPage) return;
    // Check if the user has scrolled to the bottom of the list
    if ((scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 50) &&
        !_isNextPageLoading.value) {
      _isNextPageLoading.value = true;

      widget.loadMoreChats!()
          .whenComplete(() => _isNextPageLoading.value = false);
    }
  }
}
