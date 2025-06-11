import 'package:chatview/src/widgets/chat_list_search_text_field.dart';
import 'package:flutter/material.dart';

import '../../chatview.dart';
import '../utils/constants/constants.dart';
import 'chat_view_list_user_widget.dart';

class ChatViewList extends StatefulWidget {
  const ChatViewList({
    super.key,
    this.config,
    required this.chatViewListController,
    this.profileWidget,
    this.trailingWidget,
    this.userNameWidget,
    this.lastMessageWidget,
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
  final ChatViewListController chatViewListController;

  /// Provides widget for profile in chat list.
  final Widget? profileWidget;

  /// Provides widget for trailing elements in chat list.
  final Widget? trailingWidget;

  /// Provides widget for user name in chat list.
  final Widget? userNameWidget;

  /// Provides widget for last message in chat list.
  final Widget? lastMessageWidget;

  /// Provides widget for last message time in chat list.
  final Widget? lastMessageTimeWidget;

  /// Provides widget for unread count in chat list.
  final Widget? unReadCountWidget;

  /// Provides widget builder for users in chat list.
  final NullableIndexedWidgetBuilder? chatListUserWidgetBuilder;

  /// Provides custom app bar for chat list page.
  final Widget? appbar;

  /// Callback function that is called to load more chats when the user scrolls
  final VoidCallBackWithFuture? loadMoreChats;

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

  ProfileWidgetConfig get profileWidgetConfig =>
      widget.config?.profileWidgetConfig ?? const ProfileWidgetConfig();

  ChatViewListUserConfig get chatViewListUserConfig =>
      widget.config?.chatViewListUserConfig ?? const ChatViewListUserConfig();

  UnReadWidgetConfig get unReadWidgetConfig =>
      widget.config?.unReadWidgetConfig ?? const UnReadWidgetConfig();

  ChatViewListTimeConfig get timeConfig =>
      widget.config?.timeConfig ??
      const ChatViewListTimeConfig(
        dateFormatPattern: defaultDateFormat,
      );

  LoadMoreChatListConfig get loadMoreChatListConfig =>
      widget.config?.loadMoreChatListConfig ?? const LoadMoreChatListConfig();

  ScrollController get scrollController =>
      widget.chatViewListController.scrollController;

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
              padding: searchConfig.searchTextFieldPadding ??
                  const EdgeInsets.all(10.0),
              child: ChatViewListSearch(
                searchConfig: searchConfig,
                chatViewListController: widget.chatViewListController,
              ),
            ),
          ),
        if (widget.filterChipWidget != null)
          SliverToBoxAdapter(
            child: widget.filterChipWidget!,
          ),
        StreamBuilder<List<ChatViewListUser>>(
          stream: widget.chatViewListController.chatListStreamController.stream,
          builder: (context, snapshot) {
            final users = snapshot.data ??
                widget.chatViewListController.chatViewListUsers;
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
                        lastMessageWidget: widget.lastMessageWidget,
                        lastMessageTimeWidget: widget.lastMessageTimeWidget,
                        unReadCountWidget: widget.unReadCountWidget,
                        chatViewListUserConfig: chatViewListUserConfig,
                        unReadWidgetConfig: unReadWidgetConfig,
                        timeConfig: timeConfig,
                        profileWidgetConfig: profileWidgetConfig,
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
                        color: loadMoreChatListConfig.color ??
                            const Color(primaryColorHex),
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
