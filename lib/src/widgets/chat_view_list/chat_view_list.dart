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
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../controller/chat_list_view_controller.dart';
import '../../models/chat_view_list_item.dart';
import '../../models/config_models/chat_view_list/chat_view_list_config.dart';
import '../../models/config_models/chat_view_list/load_more_config.dart';
import '../../models/config_models/chat_view_list/search_config.dart';
import '../../utils/constants/constants.dart';
import 'chat_view_list_item_tile.dart';
import 'search_text_field.dart';

class ChatViewList extends StatefulWidget {
  const ChatViewList({
    required this.controller,
    // TODO(YASH): take this as a callback rather than a bool
    this.isLastPage = false,
    // TODO(YASH): remove the necessity for this.
    this.showSearchTextField = true,
    this.config = const ChatViewListConfig(),
    this.scrollViewKeyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.onDrag,
    this.profile,
    this.trailing,
    this.userName,
    this.lastMessageTime,
    this.chatListUserWidgetBuilder,
    this.appbar,
    this.loadMoreChats,
    this.header,
    super.key,
  });

  /// Provides configuration for chat list UI.
  final ChatViewListConfig config;

  /// Provides controller for managing the chat list.
  final ChatViewListController controller;

  /// Provides widget for profile in chat list.
  final Widget? profile;

  /// Provides widget for trailing elements in chat list.
  final Widget? trailing;

  /// Provides widget for user name in chat list.
  final Widget? userName;

  /// Provides widget for last message time in chat list.
  final Widget? lastMessageTime;

  /// Provides widget builder for users in chat list.
  final NullableIndexedWidgetBuilder? chatListUserWidgetBuilder;

  /// Provides custom app bar for chat list page.
  final Widget? appbar;

  /// Callback function that is called to load more chats when the user scrolls
  final AsyncCallback? loadMoreChats;

  /// Flag to indicate if the current page is the last page of chat data.
  ///
  /// Defaults to `false`.
  /// If set to `true`, pagination will not trigger loading more chats.
  final bool isLastPage;

  /// Flag to show/hide the search text field in the chat list.
  ///
  /// Defaults to `true`.
  final bool showSearchTextField;

  /// Header widget to be displayed at the top of the chat list.
  final Widget? header;

  /// Behavior for dismissing the keyboard when scrolling.
  ///
  /// Defaults to `ScrollViewKeyboardDismissBehavior.onDrag`.
  final ScrollViewKeyboardDismissBehavior? scrollViewKeyboardDismissBehavior;

  @override
  State<ChatViewList> createState() => _ChatViewListState();
}

class _ChatViewListState extends State<ChatViewList> {
  /// ValueNotifier to track if the next page is currently loading.
  final ValueNotifier<bool> _isNextPageLoading = ValueNotifier<bool>(false);

  ChatViewListSearchConfig get searchConfig =>
      widget.config.searchConfig ??
      ChatViewListSearchConfig(
        textEditingController: TextEditingController(),
      );

  LoadMoreConfig get _loadMoreConfig => widget.config.loadMoreConfig;

  ScrollController get _scrollController => widget.controller.scrollController;

  @override
  void didChangeDependencies() {
    if (widget.config.enablePagination) {
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
        if (widget.showSearchTextField)
          SliverToBoxAdapter(
            child: Padding(
              padding: searchConfig.padding,
              child: SearchTextField(
                config: searchConfig,
                disposeResources: widget.controller.disposeOtherResources,
                chatViewListController: widget.controller,
              ),
            ),
          ),
        if (widget.header case final header?) SliverToBoxAdapter(child: header),
        StreamBuilder<List<ChatViewListItem>>(
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
                    return widget.config.separator;
                  }

                  return widget.chatListUserWidgetBuilder
                          ?.call(context, itemIndex) ??
                      ChatViewListItemTile(
                        chat: chats[itemIndex],
                        profile: widget.profile,
                        trailing: widget.trailing,
                        userName: widget.userName,
                        lastMessageTime: widget.lastMessageTime,
                        tileConfig: widget.config.tileConfig,
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
                padding: _loadMoreConfig.padding,
                child: Center(
                  child: _loadMoreConfig.loadMoreBuilder ??
                      RepaintBoundary(
                        child: switch (defaultTargetPlatform) {
                          TargetPlatform.iOS ||
                          TargetPlatform.macOS =>
                            CupertinoActivityIndicator(
                              color: _loadMoreConfig.color,
                              radius:
                                  loadMoreCircularProgressIndicatorSize * 0.5,
                            ),
                          TargetPlatform.android ||
                          TargetPlatform.fuchsia ||
                          TargetPlatform.linux ||
                          TargetPlatform.windows =>
                            SizedBox.square(
                              dimension: loadMoreCircularProgressIndicatorSize,
                              child: CircularProgressIndicator(
                                color: _loadMoreConfig.color,
                              ),
                            ),
                        },
                      ),
                ),
              );
            },
          ),
        ),
        // Add extra space at the bottom to avoid overlap with iOS home bar
        SliverToBoxAdapter(
          child: SizedBox(height: widget.config.extraSpaceAtLast),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.config.enablePagination) {
      _scrollController.removeListener(_pagination);
    }
    _isNextPageLoading.dispose();
    super.dispose();
  }

  void _pagination() {
    if (widget.loadMoreChats == null || widget.isLastPage) return;
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
