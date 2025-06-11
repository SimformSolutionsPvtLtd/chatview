import 'package:flutter/material.dart';

import 'chat_view_list_time_config.dart';
import 'chat_view_list_user_config.dart';
import 'load_more_widget_config.dart';
import 'profile_widget_config.dart';
import 'search_config.dart';
import 'unread_widget_config.dart';

/// Configuration class for the chat list UI.
class ChatViewListConfig {
  /// Creates a configuration object for the chat list UI.
  const ChatViewListConfig({
    this.searchConfig,
    this.profileWidgetConfig,
    this.separatorWidget,
    this.chatViewListPadding,
    this.chatViewListUserConfig,
    this.unReadWidgetConfig,
    this.extraSpaceAtLast,
    this.loadMoreChatListConfig,
    this.timeConfig,
    this.enablePagination = false,
  });

  /// Configuration for the search text field in the chat list.
  final SearchConfig? searchConfig;

  /// Configuration for the profile widget in the chat list.
  final ProfileWidgetConfig? profileWidgetConfig;

  /// Divider widget to be used in the chat list.
  final Widget? separatorWidget;

  /// Padding for the chat list.
  final EdgeInsets? chatViewListPadding;

  /// Configuration for the user widget in the chat list.
  final ChatViewListUserConfig? chatViewListUserConfig;

  /// Configuration for the unread message widget in the chat list.
  final UnReadWidgetConfig? unReadWidgetConfig;

  /// Configuration for the unread message widget in the chat list.
  final ChatViewListTimeConfig? timeConfig;

  /// Extra space at the last element of the chat list.
  final double? extraSpaceAtLast;

  /// Configuration for the load more chat list widget.
  final LoadMoreChatListConfig? loadMoreChatListConfig;

  /// Flag to enable or disable pagination in the chat list.
  final bool enablePagination;
}
