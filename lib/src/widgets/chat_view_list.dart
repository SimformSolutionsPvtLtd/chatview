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
import '../models/config_models/chat_list/chat_list_type_indicator_config.dart';
import '../models/config_models/chat_list/chat_menu_config.dart';
import '../models/config_models/chat_list/mute_icon_config.dart';
import '../models/config_models/chat_list/pin_icon_config.dart';
import '../models/config_models/chat_view_list_config.dart';
import '../models/config_models/chat_view_list_time_config.dart';
import '../models/config_models/chat_view_list_user_config.dart';
import '../models/config_models/load_more_widget_config.dart';
import '../models/config_models/search_config.dart';
import '../models/config_models/unread_widget_config.dart';
import '../utils/constants/constants.dart';
import 'chat_list/chat_list_tile_context_menu.dart';
import 'chat_list_search_text_field.dart';
import 'chat_view_list_user_widget.dart';

class ChatViewList extends StatefulWidget {
  const ChatViewList({
    required this.controller,
    this.isLastPage = false,
    this.showSearchTextField = true,
    this.scrollViewKeyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.onDrag,
    this.typeIndicatorConfig = const ChatListTypeIndicatorConfig(),
    this.muteIconConfig = const MuteIconConfig(),
    this.pinIconConfig = const PinIconConfig(),
    this.config = const ChatViewListConfig(),
    this.menuConfig = const ChatMenuConfig(),
    this.profileWidget,
    this.trailingWidget,
    this.userNameWidget,
    this.lastMessageTimeWidget,
    this.unReadCountWidget,
    this.chatListUserWidgetBuilder,
    this.appbar,
    this.loadMoreChats,
    this.loadMoreChatWidget,
    this.filterChipWidget,
    super.key,
  });

  /// Provides configuration for chat list UI.
  final ChatViewListConfig config;

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

  /// Provides configurations related to typing indicator appearance.
  final ChatListTypeIndicatorConfig typeIndicatorConfig;

  /// Provides configurations related to mute icon appearance.
  final MuteIconConfig muteIconConfig;

  /// Provides configurations related to pin icon appearance.
  final PinIconConfig pinIconConfig;

  /// Callback to provide a widget for the menu in the chat list.
  final ChatMenuConfig menuConfig;

  @override
  State<ChatViewList> createState() => _ChatViewListState();
}

class _ChatViewListState extends State<ChatViewList> {
  SearchConfig get searchConfig =>
      widget.config.searchConfig ??
      SearchConfig(
        textEditingController: TextEditingController(),
      );

  ChatViewListTileConfig get chatViewListTileConfig =>
      widget.config.chatViewListTileConfig ?? const ChatViewListTileConfig();

  UnreadWidgetConfig get unreadWidgetConfig =>
      widget.config.unreadWidgetConfig ?? const UnreadWidgetConfig();

  ChatViewListTimeConfig get timeConfig =>
      widget.config.timeConfig ??
      const ChatViewListTimeConfig(
        dateFormatPattern: defaultDateFormat,
      );

  LoadMoreChatListConfig get loadMoreChatListConfig =>
      widget.config.loadMoreChatListConfig ?? const LoadMoreChatListConfig();

  ScrollController get scrollController => widget.controller.scrollController;

  /// ValueNotifier to track if the next page is currently loading.
  final ValueNotifier<bool> _isNextPageLoading = ValueNotifier<bool>(false);

  @override
  void didChangeDependencies() {
    if (widget.config.enablePagination) {
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
              padding: searchConfig.padding ?? const EdgeInsets.all(10),
              child: ChatViewListSearch(
                searchConfig: searchConfig,
                chatViewListController: widget.controller,
              ),
            ),
          ),
        if (widget.filterChipWidget != null)
          SliverToBoxAdapter(
            child: widget.filterChipWidget,
          ),
        StreamBuilder<List<ChatViewListModel>>(
          stream: widget.controller.chatListStream,
          builder: (context, snapshot) {
            final chats = snapshot.data ?? List.empty();
            final itemCount = chats.isEmpty ? 0 : chats.length * 2 - 1;
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: itemCount,
                (context, index) {
                  final itemIndex = index ~/ 2;
                  if (index.isOdd) {
                    return widget.config.separatorWidget ??
                        const Divider(height: 12);
                  }
                  final chat = chats[itemIndex];

                  return ChatListTileContextMenu(
                    key: ValueKey(chat.id),
                    chat: chat,
                    config: widget.menuConfig,
                    chatTileColor: widget.config.backgroundColor,
                    child: widget.chatListUserWidgetBuilder
                            ?.call(context, itemIndex) ??
                        ChatViewListUserWidget(
                          config: widget.config,
                          chat: chat,
                          profileWidget: widget.profileWidget,
                          trailingWidget: widget.trailingWidget,
                          userNameWidget: widget.userNameWidget,
                          typeIndicatorConfig: widget.typeIndicatorConfig,
                          lastMessageTimeWidget: widget.lastMessageTimeWidget,
                          unReadCountWidget: widget.unReadCountWidget,
                          chatViewListTileConfig: chatViewListTileConfig,
                          unreadWidgetConfig: unreadWidgetConfig,
                          timeConfig: timeConfig,
                          muteIconConfig: widget.muteIconConfig,
                          pinIconConfig: widget.pinIconConfig,
                        ),
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
                    const EdgeInsets.symmetric(vertical: 16),
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
            height: widget.config.extraSpaceAtLast ?? 32.0,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.config.enablePagination) {
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
