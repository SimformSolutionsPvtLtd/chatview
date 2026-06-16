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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/config_models/chat_list/chat_menu_config.dart';
import '../../models/config_models/chat_list/list_state_config.dart';
import '../../models/config_models/chat_list/list_tile_config.dart';
import '../../models/config_models/chat_list/load_more_config.dart';
import '../../models/config_models/chat_list/search_config.dart';
import '../../utils/package_strings.dart';
import '../../values/enumeration.dart';
import '../../values/typedefs.dart';
import '../chatview_state_widget.dart';
import 'adaptive_progress_indicator.dart';
import 'auto_animate_sliver_list.dart';
import 'chat_list_item_tile.dart';
import 'chat_list_tile_context_menu.dart';
import 'search_text_field.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    required this.controller,
    this.menuConfig = const ChatMenuConfig(),
    this.scrollViewKeyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.onDrag,
    this.extraSpaceAtLast = 32,
    this.enablePagination = false,
    this.backgroundColor = Colors.white,
    this.loadMoreConfig = const LoadMoreConfig(),
    this.tileConfig = const ListTileConfig(),
    this.stateConfig = const ListStateConfig(),
    this.separatorBuilder,
    this.searchConfig,
    this.chatBuilder,
    this.appbar,
    this.loadMoreChats,
    this.header,
    this.footer,
    this.isLastPage,
    super.key,
  });

  /// Provides controller for managing the chat list.
  final ChatListController controller;

  /// Provides widget builder for users in chat list.
  final ChatListTileBuilder? chatBuilder;

  /// Provides separator builder for chat list items.
  final AutoAnimateSeparatorBuilder? separatorBuilder;

  /// Provides custom app bar for chat list page.
  final Widget? appbar;

  /// Callback function that is called to load more chats when the user scrolls
  final AsyncCallback? loadMoreChats;

  /// Flag to indicate if the current page is the last page of chat data.
  ///
  /// Defaults to `false`.
  /// If set to `true`, pagination will not trigger loading more chats.
  final ValueGetter<bool>? isLastPage;

  /// Header widget to be displayed at the top of the chat list.
  final Widget? header;

  /// Footer widget to be displayed at the bottom of the chat list.
  final Widget? footer;

  /// Behavior for dismissing the keyboard when scrolling.
  ///
  /// Defaults to `ScrollViewKeyboardDismissBehavior.onDrag`.
  final ScrollViewKeyboardDismissBehavior? scrollViewKeyboardDismissBehavior;

  /// Provides configuration for the context menu in the chat list.
  ///
  /// For Android & iOS, it uses iOS style context menu.
  /// For Web & Desktop, it uses Material style context menu.
  ///
  /// Behaviour:
  /// Android, iOS & Web: Long press on chat tile to open context menu.
  /// Desktop: Right click on chat tile to open context menu.
  final ChatMenuConfig menuConfig;

  /// Configuration for the search text field in the chat list.
  final SearchConfig? searchConfig;

  /// Configuration for the chat tile widget in the chat list.
  final ListTileConfig tileConfig;

  /// Extra space at the last element of the chat list.
  ///
  /// Defaults to `32`.
  final double extraSpaceAtLast;

  /// Configuration for the load more chat list widget.
  final LoadMoreConfig loadMoreConfig;

  /// Flag to enable or disable pagination in the chat list.
  ///
  /// Defaults to `false`.
  final bool enablePagination;

  /// Background color for the chat list.
  final Color backgroundColor;

  /// Provides configuration for chat list state appearance.
  ///
  /// For example:
  /// - if the stream has no data, it will show a no data state.
  /// - if the stream has no data, and user is searching, it will show
  /// a no search data state.
  /// - if the stream is loading, it will show a loading state.
  /// - If there is an error in stream, it will show an error state.
  final ListStateConfig stateConfig;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  /// ValueNotifier to track if the next page is currently loading.
  final ValueNotifier<bool> _isNextPageLoading = ValueNotifier<bool>(false);

  /// ValueNotifier to highlight the chat tile when context menu is opened on web/desktop.
  final ValueNotifier<String?> _highlightChatNotifier =
      ValueNotifier<String?>(null);

  LoadMoreConfig get _loadMoreConfig => widget.loadMoreConfig;

  ChatListController get _controller => widget.controller;

  ScrollController get _scrollController => widget.controller.scrollController;

  @override
  void didChangeDependencies() {
    if (widget.enablePagination) {
      _scrollController.addListener(_pagination);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      keyboardDismissBehavior: widget.scrollViewKeyboardDismissBehavior,
      slivers: [
        if (widget.appbar case final appbar?) appbar,
        if (widget.searchConfig case final config?)
          SliverPadding(
            padding: config.padding,
            sliver: SliverToBoxAdapter(
              child: SearchTextField(
                config: config,
                chatListController: _controller,
              ),
            ),
          ),
        if (widget.header case final header?) SliverToBoxAdapter(child: header),
        StreamBuilder<List<ChatListItem>>(
          stream: _controller.chatListStream,
          builder: (context, snapshot) {
            final chats = snapshot.data ?? List.empty();
            final state = snapshot.chatViewState;
            return switch (state) {
              ChatViewState.hasMessages => AutoAnimateSliverList<ChatListItem>(
                  items: chats,
                  separatorBuilder: widget.separatorBuilder,
                  controller: _controller.animatedListController
                    // Update the items in the animated list controller
                    // whenever the chat list changes
                    ..updateItems(chats),
                  builder: (context, _, __, chat) {
                    final child = widget.chatBuilder?.call(context, chat) ??
                        ChatListItemTile(
                          chat: chat,
                          config: widget.tileConfig,
                        );
                    return widget.menuConfig.enabled
                        ? ChatListTileContextMenu(
                            key: ValueKey(chat.id),
                            chat: chat,
                            config: widget.menuConfig,
                            chatTileColor: widget.backgroundColor,
                            highlightNotifier: _highlightChatNotifier,
                            child: child,
                          )
                        : child;
                  },
                ),
              ChatViewState.noData => SliverFillRemaining(
                  child: _controller.isSearching
                      ? ChatViewStateWidget(
                          chatViewState: state,
                          title: widget.stateConfig.noSearchChatsWidgetConfig
                                  .title ??
                              PackageStrings.currentLocale.noSearchResults,
                          type: ChatViewStateType.chatList,
                          config: widget.stateConfig.noSearchChatsWidgetConfig,
                        )
                      : ChatViewStateWidget(
                          chatViewState: state,
                          type: ChatViewStateType.chatList,
                          config: widget.stateConfig.noChatsWidgetConfig,
                          onReloadButtonTap:
                              widget.stateConfig.onReloadButtonTap,
                        ),
                ),
              ChatViewState.loading => SliverFillRemaining(
                  child: ChatViewStateWidget(
                    chatViewState: state,
                    type: ChatViewStateType.chatList,
                    config: widget.stateConfig.loadingWidgetConfig,
                  ),
                ),
              ChatViewState.error => SliverFillRemaining(
                  child: ChatViewStateWidget(
                    chatViewState: state,
                    type: ChatViewStateType.chatList,
                    config: widget.stateConfig.errorWidgetConfig,
                    onReloadButtonTap: widget.stateConfig.onReloadButtonTap,
                  ),
                ),
            };
          },
        ),
        // Show loading indicator at the bottom when loading next page
        SliverToBoxAdapter(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isNextPageLoading,
            builder: (context, isLoading, _) {
              if (!isLoading) return const SizedBox.shrink();
              return Padding(
                padding: _loadMoreConfig.padding,
                child: Center(
                  child: _loadMoreConfig.loadMoreBuilder ??
                      AdaptiveProgressIndicator(
                        color: _loadMoreConfig.color,
                        size: _loadMoreConfig.size,
                      ),
                ),
              );
            },
          ),
        ),
        if (widget.footer case final footer?) SliverToBoxAdapter(child: footer),
        // Add extra space at the bottom to avoid overlap with iOS home bar
        SliverToBoxAdapter(
          child: SizedBox(height: widget.extraSpaceAtLast),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.enablePagination) {
      _scrollController.removeListener(_pagination);
    }
    _isNextPageLoading.dispose();
    super.dispose();
  }

  void _pagination() {
    if (widget.loadMoreChats == null || (widget.isLastPage?.call() ?? false)) {
      return;
    }
    // Check if the user has scrolled to the bottom of the list
    if ((_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50) &&
        !_isNextPageLoading.value) {
      _isNextPageLoading.value = true;

      widget.loadMoreChats!()
          .whenComplete(() => _isNextPageLoading.value = false);
    }
  }
}
