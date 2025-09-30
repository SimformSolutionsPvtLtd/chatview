import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'models/chatview_list_theme.dart';
import 'models/chatview_theme.dart';
import 'values/colors.dart';
import 'values/icons.dart';

void main() {
  runApp(const Example());
}

class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat UI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.instaPurple,
        colorScheme: ColorScheme.fromSwatch(accentColor: AppColors.instaPurple),
      ),
      darkTheme: ThemeData(
        primaryColor: AppColors.instaPurple,
        colorScheme: ColorScheme.fromSwatch(accentColor: AppColors.instaPurple),
      ),
      home: const ExampleOneListScreen(),
    );
  }
}

class ExampleOneListScreen extends StatefulWidget {
  const ExampleOneListScreen({super.key});

  @override
  State<ExampleOneListScreen> createState() => _ExampleOneListScreenState();
}

class _ExampleOneListScreenState extends State<ExampleOneListScreen> {
  ChatViewListTheme _theme = ChatViewListTheme.uiOneLight;
  bool _isDarkTheme = false;

  final _searchController = TextEditingController();

  final _chatListController = ChatViewListController(
    initialChatList: Data.getChatList(),
    scrollController: ScrollController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _theme.backgroundColor,
      body: SafeArea(
        child: ChatViewList(
          controller: _chatListController,
          backgroundColor: _theme.backgroundColor,
          header: _headerWidget(),
          appbar: ChatViewListAppBar(
            backgroundColor: _theme.backgroundColor,
            leading: Icon(
              Icons.arrow_back_ios_rounded,
              color: _theme.iconColor,
            ),
            centerTitle: false,
            scrolledUnderElevation: 0,
            titleText: 'ChatViewList',
            titleTextStyle: TextStyle(
              fontSize: 20,
              color: _theme.textColor,
              fontWeight: FontWeight.bold,
            ),
            actions: [
              SvgPicture.asset(
                AppIcons.chatDiscoveryAi,
                colorFilter: ColorFilter.mode(
                  _theme.iconColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                AppIcons.createPen,
                colorFilter: ColorFilter.mode(
                  _theme.iconColor,
                  BlendMode.srcIn,
                ),
              ),
              IconButton(
                onPressed: _onThemeIconTap,
                icon: Icon(
                  _isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                  color: _theme.iconColor,
                ),
              ),
            ],
          ),
          searchConfig: SearchConfig(
            textEditingController: _searchController,
            hintText: 'Ask Meta AI or search',
            hintStyle: TextStyle(
              fontSize: 16.4,
              color: _theme.searchText,
              fontWeight: FontWeight.w400,
            ),
            textStyle: TextStyle(
              fontSize: 16.4,
              color: _theme.textColor,
              fontWeight: FontWeight.w400,
            ),
            textFieldBackgroundColor: _theme.searchBg,
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            prefixIcon: SizedBox.square(
              dimension: 48,
              child: Align(child: SvgPicture.asset(AppIcons.ai, width: 24)),
            ),
            clearIcon: Icon(Icons.clear, color: _theme.iconColor),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onSearch: (value) {
              if (value.isEmpty) {
                _chatListController.clearSearch();
                return null;
              }

              List<ChatViewListItem> chats =
                  _chatListController.chatListMap.values.toList();

              final list = chats
                  .where((chat) =>
                      chat.name.toLowerCase().contains(value.toLowerCase()))
                  .toList();
              return list;
            },
          ),
          menuConfig: ChatMenuConfig(
            deleteCallback: (chat) => _chatListController.removeChat(chat.id),
            muteStatusCallback: (result) => _chatListController.updateChat(
              result.chat.id,
              (previousChat) => previousChat.copyWith(
                settings: previousChat.settings.copyWith(
                  muteStatus: result.status,
                ),
              ),
            ),
            pinStatusCallback: (result) => _chatListController.updateChat(
              result.chat.id,
              (previousChat) => previousChat.copyWith(
                settings: previousChat.settings.copyWith(
                  pinStatus: result.status,
                ),
              ),
            ),
          ),
          tileConfig: ListTileConfig(
            showUserActiveStatusIndicator: false,
            trailingBuilder: (chat) => _customTrailingWidget(chat),
            userNameBuilder: (chat) => _customUserNameWidget(chat),
            lastMessageTileBuilder: (chat) => _customLastMessageTile(chat),
            onTap: (chat) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExampleOneChatScreen(chat: chat),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            userAvatarConfig: UserAvatarConfig(
              radius: 26,
              backgroundColor: _theme.secondaryBg,
            ),
            typingStatusConfig: TypingStatusConfig(
              textBuilder: (chat) => 'Typing...',
              textStyle: TextStyle(
                fontSize: 13,
                color: _theme.lastMessageText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatListController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onThemeIconTap() {
    setState(() {
      if (_isDarkTheme) {
        _theme = ChatViewListTheme.uiOneLight;
        _isDarkTheme = false;
      } else {
        _theme = ChatViewListTheme.uiOneDart;
        _isDarkTheme = true;
      }
    });
  }

  Widget _customTrailingWidget(ChatViewListItem chat) {
    final highlight = (chat.unreadCount ?? 0) > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (highlight) ...[
          const CircleAvatar(
            radius: 4,
            backgroundColor: AppColors.instaUnreadCountDot,
          ),
          const SizedBox(width: 12),
        ],
        SvgPicture.asset(
          AppIcons.camera2,
          colorFilter: ColorFilter.mode(
            highlight ? _theme.iconColor : AppColors.instaDarkGrey,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }

  Widget _headerWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Messages',
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
                color: _theme.textColor,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'Requests',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _theme.searchText),
          ),
        ],
      ),
    );
  }

  Widget _customUserNameWidget(ChatViewListItem chat) {
    final highlightText = (chat.unreadCount ?? 0) > 0;
    return Row(
      children: [
        Flexible(
          child: Text(
            chat.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: highlightText ? _theme.textColor : _theme.lastMessageText,
              fontWeight: highlightText ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        if (chat.settings.pinStatus.isPinned) ...[
          const SizedBox(width: 6),
          SvgPicture.asset(
            AppIcons.pinned,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              _theme.lastMessageText,
              BlendMode.srcIn,
            ),
          ),
        ],
      ],
    );
  }

  Widget _customLastMessageTile(ChatViewListItem chat) {
    final message = chat.lastMessage;
    final unreadCount = chat.unreadCount ?? 0;
    final highlightText = unreadCount > 0;
    if (message == null) {
      return const SizedBox.shrink();
    }

    String prefix = switch (message.status) {
      MessageStatus.read => 'Seen',
      MessageStatus.delivered => 'Sent',
      MessageStatus.undelivered => 'Failed to send.',
      MessageStatus.pending => 'Sending...',
    };

    final showDisplayMessage = prefix == 'Seen' || prefix == 'Sent';

    final String display;
    if (highlightText && unreadCount != 1) {
      display = '$unreadCount new messages';
    } else if (!showDisplayMessage) {
      display = prefix;
    } else if (message.sentBy == 'me') {
      display = message.createdAt.getTimestamp(prefix: prefix);
    } else {
      display = switch (message.messageType) {
        MessageType.image => '$prefix a Photo',
        MessageType.text => message.message,
        MessageType.voice => '$prefix a Audio',
        MessageType.custom => '$prefix a Message',
      };
    }

    return Row(
      children: [
        if (showDisplayMessage && message.messageType != MessageType.text) ...[
          switch (message.messageType) {
            MessageType.image => const Icon(Icons.photo, size: 14),
            MessageType.voice => const Icon(Icons.mic, size: 14),
            MessageType.text || MessageType.custom => const SizedBox.shrink(),
          },
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            display,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: message.status.isUndelivered
                  ? Colors.red
                  : highlightText
                      ? _theme.textColor
                      : _theme.lastMessageText,
              fontWeight: highlightText ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        if (showDisplayMessage) ...[
          Text(
            ' · ${message.createdAt.getTimeAgo}',
            style: TextStyle(
              fontSize: 14,
              color: _theme.lastMessageText,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
        if (chat.settings.muteStatus.isMuted) ...[
          const SizedBox(width: 6),
          Icon(
            Icons.notifications_off_outlined,
            size: 16,
            color: _theme.lastMessageText,
          ),
        ],
      ],
    );
  }
}

class ExampleOneChatScreen extends StatefulWidget {
  const ExampleOneChatScreen({required this.chat, super.key});

  final ChatViewListItem chat;

  @override
  State<ExampleOneChatScreen> createState() => _ExampleOneChatScreenState();
}

class _ExampleOneChatScreenState extends State<ExampleOneChatScreen> {
  ChatViewTheme _theme = ChatViewTheme.uiOneLight;
  bool _isDarkTheme = false;
  bool _isTopPaginationCalled = false;
  bool _isBottomPaginationCalled = false;

  final ChatController _chatController = ChatController(
    initialMessageList: Data.getMessageList(),
    scrollController: ScrollController(),
    currentUser: Data.currentUser,
    otherUsers: Data.otherUsers,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ChatView(
          chatController: _chatController,
          onSendTap: _onSendTap,
          isLastPage: () => _isTopPaginationCalled && _isBottomPaginationCalled,
          loadMoreData: (direction, message) async {
            if (direction.isNext) {
              if (_isBottomPaginationCalled) {
                return;
              }
              _isBottomPaginationCalled = true;
            } else if (direction.isPrevious) {
              if (_isTopPaginationCalled) {
                return;
              }
              _isTopPaginationCalled = true;
            }
            await Future.delayed(const Duration(seconds: 1));
            _chatController.loadMoreData(
              direction.isPrevious
                  ? [
                      Message(
                        id: DateTime.timestamp()
                            .subtract(const Duration(days: 30, minutes: 10))
                            .toIso8601String(),
                        message: "Long time no see!",
                        createdAt: DateTime.now()
                            .subtract(const Duration(days: 30, minutes: 10)),
                        sentBy: '2',
                        status: MessageStatus.read,
                      ),
                      Message(
                        id: DateTime.timestamp()
                            .subtract(const Duration(days: 30, minutes: 5))
                            .toIso8601String(),
                        message: "Indeed! I was about to ping you.",
                        createdAt: DateTime.now()
                            .subtract(const Duration(days: 30, minutes: 5)),
                        sentBy: '1',
                        status: MessageStatus.read,
                      ),
                    ]
                  : [
                      Message(
                        id: '14',
                        message: "How about a movie marathon?",
                        createdAt:
                            DateTime.now().subtract(const Duration(minutes: 1)),
                        sentBy: '2',
                        status: MessageStatus.read,
                      ),
                      Message(
                        id: '15',
                        message: "Sounds great! I'm in. 🎬",
                        createdAt: DateTime.now(),
                        sentBy: '1',
                        status: MessageStatus.read,
                      ),
                    ],
              direction: direction,
            );
          },
          featureActiveConfig: const FeatureActiveConfig(
            lastSeenAgoBuilderVisibility: true,
            receiptsBuilderVisibility: true,
            enableOtherUserName: false,
            enableScrollToBottomButton: true,
            enableOtherUserProfileAvatar: true,
            enablePagination: true,
          ),
          scrollToBottomButtonConfig: const ScrollToBottomButtonConfig(
            padding: EdgeInsets.only(bottom: 8, right: 12),
            insidePadding: EdgeInsets.all(10),
            alignment: ScrollButtonAlignment.right,
            icon: Icon(Icons.arrow_downward_rounded),
            border: Border.fromBorderSide(BorderSide.none),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, 4),
                color: Colors.black26,
              ),
            ],
          ),
          chatViewState: ChatViewState.hasMessages,
          typeIndicatorConfig: TypeIndicatorConfiguration(
            customIndicator: _customTypingIndicator(),
          ),
          appBar: ChatViewAppBar(
            elevation: 0,
            chatTitle: widget.chat.name,
            leading: IconButton(
              onPressed: Navigator.of(context).maybePop,
              icon: Icon(Icons.arrow_back_ios, color: _theme.iconColor),
            ),
            chatTitleTextStyle: TextStyle(
              fontSize: 18,
              color: _theme.titleColor,
              fontWeight: FontWeight.w600,
            ),
            profilePicture: widget.chat.imageUrl,
            backGroundColor: _theme.backgroundColor,
            userStatus: '@${widget.chat.name}',
            userStatusTextStyle: TextStyle(
              fontSize: 13,
              color: _theme.titleColor,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  AppIcons.chatDiscoveryAi,
                  colorFilter: ColorFilter.mode(
                    _theme.iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  AppIcons.phone,
                  colorFilter: ColorFilter.mode(
                    _theme.iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              IconButton(
                // Handle video call
                onPressed: () {},
                icon: SvgPicture.asset(
                  AppIcons.video,
                  colorFilter: ColorFilter.mode(
                    _theme.iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: _theme.iconColor,
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'toggle_typing_indicator',
                    child: Text('Toggle TypingIndicator'),
                  ),
                  const PopupMenuItem(
                    value: 'simulate_message_receive',
                    child: Text('Simulate Message receive'),
                  ),
                  PopupMenuItem(
                    value: 'dark_theme',
                    child: Text(' ${_isDarkTheme ? 'Light' : 'Dark'} Mode'),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'toggle_typing_indicator':
                      _showHideTypingIndicator();
                    case 'simulate_message_receive':
                      receiveMessage();
                    case 'dark_theme':
                      _onThemeIconTap();
                  }
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          chatBackgroundConfig: ChatBackgroundConfiguration(
            backgroundColor: _theme.backgroundColor,
            groupSeparatorBuilder: (separator) =>
                _customSeparatorWidget(separator),
          ),
          sendMessageConfig: SendMessageConfiguration(
            closeIconColor: _theme.iconColor,
            replyTitleColor: _theme.textColor,
            replyMessageColor: _theme.textColor,
            replyDialogColor: _theme.backgroundColor,
            defaultSendButtonColor: Colors.white,
            textFieldBackgroundColor: _theme.textField,
            voiceRecordingConfiguration: VoiceRecordingConfiguration(
              recorderIconColor: _theme.iconColor,
              waveStyle: WaveStyle(
                extendWaveform: true,
                showMiddleLine: false,
                waveColor: _theme.iconColor,
                durationLinesColor: AppColors.black20,
                backgroundColor: Colors.transparent,
                scaleFactor: 60,
                waveThickness: 3,
                spacing: 4,
              ),
            ),
            sendButtonStyle: IconButton.styleFrom(
              backgroundColor: AppColors.instaPurple,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            textFieldConfig: TextFieldConfiguration(
              hintText: 'Message...',
              hideLeadingActionsOnType: false,
              onMessageTyping: (status) {
                /// Do with status
                debugPrint(status.toString());
              },
              compositionThresholdTime: const Duration(seconds: 1),
              textStyle: TextStyle(color: _theme.textColor),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leadingActions: (context, controller) =>
                  controller.text.trim().isEmpty
                      ? [
                          CameraActionButton(
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.instaPurple,
                            ),
                            onPressed: (path, replyMessage) {
                              if (path?.isEmpty ?? true) return;
                              _chatController.addMessage(
                                Message(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  message: path!,
                                  createdAt: DateTime.now(),
                                  messageType: MessageType.image,
                                  sentBy: _chatController.currentUser.id,
                                  replyMessage:
                                      replyMessage ?? const ReplyMessage(),
                                ),
                              );
                              _chatController.addMessage(
                                Message(
                                  message: controller.text,
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  createdAt: DateTime.now(),
                                  sentBy: _chatController.currentUser.id,
                                  replyMessage:
                                      replyMessage ?? const ReplyMessage(),
                                ),
                              );
                            },
                          ),
                        ]
                      : [
                          IconButton(
                            icon: const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.instaPurple,
                            ),
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Search button pressed')),
                            ),
                          ),
                        ],
              trailingActions: (context, controller) => [
                GalleryActionButton(
                  icon: Icon(
                    Icons.photo_rounded,
                    size: 30,
                    color: _theme.iconColor,
                  ),
                  onPressed: (path, replyMessage) {
                    if (path?.isEmpty ?? true) return;
                    _chatController.addMessage(
                      Message(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        message: path!,
                        createdAt: DateTime.now(),
                        messageType: MessageType.image,
                        sentBy: _chatController.currentUser.id,
                        replyMessage: replyMessage ?? const ReplyMessage(),
                      ),
                    );
                  },
                ),
                EmojiPickerActionButton(
                  context: context,
                  onPressed: (emoji, replyMessage) {
                    if (emoji?.isEmpty ?? true) return;
                    controller.text = controller.text += emoji!;
                    _chatController.addMessage(
                      Message(
                        message: controller.text,
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        createdAt: DateTime.now(),
                        sentBy: _chatController.currentUser.id,
                        replyMessage: replyMessage ?? const ReplyMessage(),
                      ),
                    );
                  },
                  icon: SvgPicture.asset(
                    AppIcons.sticker,
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                      _theme.iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add attachment')),
                  ),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 30,
                    color: _theme.iconColor,
                  ),
                ),
              ],
            ),
          ),
          chatBubbleConfig: ChatBubbleConfiguration(
            outgoingChatBubbleConfig: const ChatBubble(
              linkPreviewConfig: LinkPreviewConfiguration(
                backgroundColor: Colors.white12,
                linkStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              color: AppColors.instaPurple,
              textStyle: TextStyle(color: Colors.white, fontSize: 16),
              receiptsWidgetConfig: ReceiptsWidgetConfig(
                showReceiptsIn: ShowReceiptsIn.lastMessage,
              ),
            ),
            inComingChatBubbleConfig: ChatBubble(
              linkPreviewConfig: LinkPreviewConfiguration(
                backgroundColor: Colors.white12,
                linkStyle: TextStyle(
                  fontSize: 16,
                  color: _theme.textColor,
                ),
              ),
              color: _theme.incomingBubble,
              textStyle: TextStyle(color: _theme.textColor, fontSize: 16),
              onMessageRead: (message) {
                /// send your message reciepts to the other client
                debugPrint('Message Read');
              },
            ),
          ),
          reactionPopupConfig: const ReactionPopupConfiguration(
            backgroundColor: Colors.white,
            shadow: BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 4),
              color: Colors.black26,
            ),
          ),
          messageConfig: MessageConfiguration(
            voiceMessageConfig: VoiceMessageConfiguration(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              playIcon: (isMessageBySender) => Icon(
                Icons.play_arrow_rounded,
                size: 24,
                color: isMessageBySender ? Colors.white : _theme.iconColor,
              ),
              pauseIcon: (isMessageBySender) => Icon(
                Icons.pause_rounded,
                size: 24,
                color: isMessageBySender ? Colors.white : _theme.iconColor,
              ),
              inComingPlayerWaveStyle: PlayerWaveStyle(
                liveWaveColor: _theme.iconColor,
                fixedWaveColor: AppColors.black20,
                backgroundColor: Colors.transparent,
                scaleFactor: 60,
                waveThickness: 3,
                spacing: 4,
              ),
              outgoingPlayerWaveStyle: PlayerWaveStyle(
                liveWaveColor: _theme.iconColor,
                fixedWaveColor: AppColors.white20,
                backgroundColor: Colors.transparent,
                scaleFactor: 60,
                waveThickness: 3,
                spacing: 4,
              ),
            ),
            messageReactionConfig: MessageReactionConfiguration(
              backgroundColor: _theme.incomingBubble,
              borderColor: _theme.backgroundColor,
              borderWidth: 2,
              reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                backgroundColor: _theme.backgroundColor,
                reactedUserTextStyle: TextStyle(
                  color: _theme.textColor,
                ),
                reactionWidgetDecoration: BoxDecoration(
                  color: _theme.incomingBubble,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            customMessageBuilder: (message) {
              if (message.message == 'Message unavailable') {
                return _buildUnavailableMessage(message);
              }
              return const SizedBox.shrink();
            },
          ),
          profileCircleConfig: const ProfileCircleConfiguration(
            padding: EdgeInsets.only(right: 4),
            profileImageUrl: Data.profileImage,
          ),
          repliedMessageConfig: RepliedMessageConfiguration(
            backgroundColor: _theme.replyBg,
            verticalBarColor: _theme.verticalDivider,
            textStyle: TextStyle(color: _theme.replyText),
            replyTitleTextStyle: TextStyle(
              fontSize: 12,
              color: _theme.titleColor,
            ),
            loadOldReplyMessage: (id) async => {
              // Implement logic to fetch old replied message with surrounding context using message ID
            },
            repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
              enableHighlightRepliedMsg: true,
              highlightScale: 1.1,
              highlightColor: Colors.grey.shade300,
            ),
          ),
          swipeToReplyConfig: SwipeToReplyConfiguration(
            replyIconColor: _theme.iconColor,
            replyIconBackgroundColor: _theme.backgroundColor,
            replyIconProgressRingColor: _theme.incomingBubble,
          ),
          replySuggestionsConfig: ReplySuggestionsConfig(
            itemConfig: SuggestionItemConfig(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _theme.incomingBubble,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _theme.incomingBubble),
              ),
              textStyle: TextStyle(color: _theme.textColor),
            ),
            onTap: (item) => _onSendTap(
              item.text,
              const ReplyMessage(),
              MessageType.text,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // ChatController should be disposed to avoid memory leaks
    _chatController.dispose();
    super.dispose();
  }

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  void receiveMessage() async {
    _chatController.addMessage(
      Message(
        id: DateTime.now().toString(),
        message: 'I will schedule the meeting.',
        createdAt: DateTime.now(),
        sentBy: '2',
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    _chatController.addReplySuggestions([
      const SuggestionItemData(text: 'Thanks.'),
      const SuggestionItemData(text: 'Thank you very much.'),
      const SuggestionItemData(text: 'Great.')
    ]);
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
    final messageObj = Message(
      id: DateTime.now().toString(),
      createdAt: DateTime.now(),
      message: message,
      sentBy: _chatController.currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
    );
    _chatController.addMessage(
      messageObj,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      final index = _chatController.initialMessageList.indexOf(messageObj);
      _chatController.initialMessageList[index].setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      final index = _chatController.initialMessageList.indexOf(messageObj);
      _chatController.initialMessageList[index].setStatus = MessageStatus.read;
    });
  }

  void _onThemeIconTap() {
    setState(() {
      if (_isDarkTheme) {
        _theme = ChatViewTheme.uiOneLight;
        _isDarkTheme = false;
      } else {
        _theme = ChatViewTheme.uiOneDark;
        _isDarkTheme = true;
      }
    });
  }

  Widget _buildUnavailableMessage(Message message) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: EdgeInsets.fromLTRB(
          5, 0, 6, message.reaction.reactions.isNotEmpty ? 15 : 2),
      decoration: BoxDecoration(
        color: _theme.incomingBubble,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.message,
            style: TextStyle(
              fontSize: 16,
              color: _theme.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This content may have been deleted by its owner or hidden by their privacy settings.',
            style: TextStyle(color: _theme.textColor, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _customSeparatorWidget(String separator) {
    final date = DateTime.tryParse(separator);
    if (date == null) {
      return const SizedBox.shrink();
    }
    String separatorDate;
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      separatorDate = DateFormat('h:mm a').format(date);
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      separatorDate = 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (date.isAfter(now.subtract(const Duration(days: 7)))) {
      separatorDate = DateFormat('EEE h:mm a').format(date);
    } else {
      separatorDate = DateFormat('d MMM AT h:mm a').format(date);
    }
    return Align(
      heightFactor: 2,
      child: Text(
        separatorDate.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _theme.titleColor,
        ),
      ),
    );
  }

  Widget _customTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_chatController.otherUsers.firstOrNull?.profilePhoto
            case final image?) ...[
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(image),
            backgroundColor: _theme.incomingBubble,
          ),
        ],
        Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: _theme.incomingBubble,
            borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 14,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 2.75,
                backgroundColor: AppColors.instaDarkGrey,
              ),
              SizedBox(width: 3),
              CircleAvatar(
                radius: 2.75,
                backgroundColor: AppColors.instaDarkGrey,
              ),
              SizedBox(width: 3),
              CircleAvatar(
                radius: 2.75,
                backgroundColor: AppColors.instaDarkGrey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on DateTime {
  String get getTimeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w';
    }
    return now.year == year
        ? DateFormat('MMM d').format(this) // e.g. Aug 5
        : DateFormat('MMM d, y').format(this); // e.g. Aug 5, 2023;
  }

  String getTimestamp({required String prefix}) {
    String timeStamp;
    if (isNow) {
      timeStamp = 'just Now';
    } else {
      final difference = DateTime.now().difference(this);
      // if the difference is 1 day, show hours wise
      if (difference.inDays == 0) {
        if (difference.inHours > 0) {
          timeStamp = '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          timeStamp = '${difference.inMinutes}m ago';
        } else {
          timeStamp = 'now';
        }
        // if less than 7 days, show days wise
      } else if (isLast7Days) {
        final day = DateFormat('EEEE').format(this);
        timeStamp = 'on $day';
      } else {
        timeStamp = '';
      }
    }
    return '$prefix $timeStamp';
  }

  bool get isNow {
    final now = DateTime.now();
    return year == now.year &&
        month == now.month &&
        day == now.day &&
        hour == now.hour &&
        minute == now.minute;
  }

  bool get isLast7Days {
    final now = DateTime.now();
    return now.difference(DateTime(year, month, day)).inDays < 7;
  }
}
