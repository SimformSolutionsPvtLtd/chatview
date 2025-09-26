import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'example_two/example_two_list_screen.dart';
import 'models/theme.dart';
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
  final _chatListController = ChatViewListController(
    initialChatList: Data.getChatList(),
    scrollController: ScrollController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatViewList(
        controller: _chatListController,
        appbar: ChatViewListAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: const Icon(Icons.arrow_back_ios_rounded),
          centerTitle: false,
          scrolledUnderElevation: 0,
          titleText: 'ChatViewList',
          actions: [
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExampleTwoListScreen(),
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.wpGreen),
              child: const Text('WhatsApp'),
            ),
            SvgPicture.asset(
              AppIcons.instaDiscoveryAi,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            SvgPicture.asset(
              AppIcons.instaAdd,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        searchConfig: SearchConfig(
          textEditingController: TextEditingController(),
          hintText: 'Ask Meta AI or Search',
          hintStyle: const TextStyle(
            fontSize: 16.4,
            color: AppColors.instaGrey,
            fontWeight: FontWeight.w400,
          ),
          textFieldBackgroundColor: AppColors.instaTextFieldBackground,
          prefixIcon: const Icon(
            Icons.search,
            size: 24,
            color: AppColors.instaGrey,
          ),
          borderRadius: BorderRadius.circular(10),
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
          onTap: (chat) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExampleOneChatScreen(chat: chat),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          showUserActiveStatusIndicator: false,
          userAvatarConfig: const UserAvatarConfig(
            radius: 26,
            backgroundColor: AppColors.instaLightGrey,
          ),
          trailingBuilder: (chat) {
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
                  AppIcons.instaCamera,
                  colorFilter: ColorFilter.mode(
                    highlight ? Colors.black : AppColors.instaDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            );
          },
          lastMessageStatusConfig: LastMessageStatusConfig(
            statusBuilder: (status) => switch (status) {
              MessageStatus.read =>
                SvgPicture.asset(AppIcons.wpCheckMark, width: 19, height: 19),
              MessageStatus.delivered => SvgPicture.asset(
                  AppIcons.wpCheckMark,
                  width: 19,
                  height: 19,
                  colorFilter: const ColorFilter.mode(
                    AppColors.instaDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
              MessageStatus.pending => const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.instaDarkGrey,
                ),
              MessageStatus.undelivered => const Icon(
                  Icons.error_rounded,
                  size: 16,
                  color: Colors.red,
                ),
            },
          ),
          pinIconConfig: PinIconConfig(
            widget: SvgPicture.asset(AppIcons.wpChatPinned),
          ),
          typingStatusConfig: TypingStatusConfig(
            textBuilder: (chat) => 'Typing...',
            textStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.instaGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
          timeConfig: const LastMessageTimeConfig(
            textStyle: TextStyle(color: AppColors.instaGrey, fontSize: 14),
          ),
          userNameBuilder: (chat) {
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
                      color: highlightText ? Colors.black : AppColors.instaGrey,
                      fontWeight:
                          highlightText ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (chat.settings.pinStatus.isPinned) ...[
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    AppIcons.wpChatPinned,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.instaGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ],
            );
          },
          lastMessageTileBuilder: (chat) {
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
                if (showDisplayMessage &&
                    message.messageType != MessageType.text) ...[
                  switch (message.messageType) {
                    MessageType.image => const Icon(Icons.photo, size: 14),
                    MessageType.voice => const Icon(Icons.mic, size: 14),
                    MessageType.text ||
                    MessageType.custom =>
                      const SizedBox.shrink(),
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
                              ? Colors.black
                              : AppColors.instaGrey,
                      fontWeight:
                          highlightText ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (showDisplayMessage) ...[
                  Text(
                    ' · ${message.createdAt.getTimeAgo}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.instaGrey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
                if (chat.settings.muteStatus.isMuted) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.notifications_off_outlined,
                    size: 16,
                    color: AppColors.instaGrey,
                  ),
                ],
              ],
            );
          },
          unreadCountConfig: const UnreadCountConfig(
            backgroundColor: AppColors.instaPurple,
            style: UnreadCountStyle.ninetyNinePlus,
            textStyle: TextStyle(color: Colors.white),
          ),
          userNameTextStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        header: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Messages',
                  maxLines: 1,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Requests',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
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
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;
  bool _isTopPaginationCalled = false;
  bool _isBottomPaginationCalled = false;
  final ChatController _chatController = ChatController(
    initialMessageList: Data.getMessageList(),
    scrollController: ScrollController(),
    currentUser: Data.currentUser,
    otherUsers: Data.otherUsers,
  );

  @override
  void initState() {
    super.initState();
    // Set system UI overlay style
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: AppColors.instaBackground,
          statusBarBrightness: Brightness.dark,
        ),
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(
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
          customIndicator: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_chatController.otherUsers.firstOrNull?.profilePhoto
                  case final image?) ...[
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(image),
                  backgroundColor: AppColors.instaLightGrey,
                ),
              ],
              Container(
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                  color: AppColors.instaLightGrey,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
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
          ),
        ),
        appBar: ChatViewAppBar(
          elevation: 0,
          chatTitle: widget.chat.name,
          leading: IconButton(
            onPressed: Navigator.of(context).maybePop,
            icon: const Icon(Icons.arrow_back_ios),
          ),
          chatTitleTextStyle: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          profilePicture: widget.chat.imageUrl,
          backGroundColor: AppColors.instaBackground,
          userStatus: '@${widget.chat.name}',
          userStatusTextStyle: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                AppIcons.instaDiscoveryAi,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(AppIcons.wpPhone),
            ),
            IconButton(
              // Handle video call
              onPressed: () {},
              icon: SvgPicture.asset(AppIcons.wpVideo),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'toggle_typing_indicator',
                  child: Text('Toggle TypingIndicator'),
                ),
                const PopupMenuItem(
                  value: 'simulate_message_receive',
                  child: Text('Simulate Message receive'),
                ),
                // PopupMenuItem(
                //   value: 'dark_theme',
                //   child: Text(' ${isDarkTheme ? 'Light' : 'Dark'} Mode'),
                // ),
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
          backgroundColor: AppColors.instaBackground,
          groupSeparatorBuilder: (separator) {
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
              separatorDate =
                  'Yesterday at ${DateFormat('h:mm a').format(date)}';
            } else if (date.isAfter(now.subtract(const Duration(days: 7)))) {
              separatorDate = DateFormat('EEE h:mm a').format(date);
            } else {
              separatorDate = DateFormat('d MMM AT h:mm a').format(date);
            }
            return Align(
              heightFactor: 2,
              child: Text(
                separatorDate.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.instaSeparatorText,
                ),
              ),
            );
          },
        ),
        sendMessageConfig: SendMessageConfiguration(
          replyTitleColor: Colors.black,
          replyDialogColor: Colors.white,
          defaultSendButtonColor: Colors.white,
          textFieldBackgroundColor: AppColors.instaTextFieldBackground,
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
            textStyle: const TextStyle(color: Colors.black),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leadingActions: (context, controller) => controller.text
                    .trim()
                    .isEmpty
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
                            replyMessage: replyMessage ?? const ReplyMessage(),
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
                            replyMessage: replyMessage ?? const ReplyMessage(),
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
                        const SnackBar(content: Text('Search button pressed')),
                      ),
                    ),
                  ],
            trailingActions: (context, controller) => [
              GalleryActionButton(
                icon: const Icon(Icons.photo_rounded, size: 30),
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
                  AppIcons.wpSticker,
                  width: 30,
                  height: 30,
                ),
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add attachment')),
                ),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          outgoingChatBubbleConfig: const ChatBubble(
            linkPreviewConfig: LinkPreviewConfiguration(
              linkStyle: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            color: AppColors.instaPurple,
            textStyle: TextStyle(color: Colors.white, fontSize: 16),
            receiptsWidgetConfig: ReceiptsWidgetConfig(
              showReceiptsIn: ShowReceiptsIn.lastMessage,
            ),
          ),
          inComingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: const LinkPreviewConfiguration(
              linkStyle: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            color: AppColors.instaLightGrey,
            textStyle: const TextStyle(color: Colors.black87, fontSize: 16),
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
              color: isMessageBySender ? Colors.white : Colors.black,
            ),
            pauseIcon: (isMessageBySender) => Icon(
              Icons.pause_rounded,
              size: 24,
              color: isMessageBySender ? Colors.white : Colors.black,
            ),
            inComingPlayerWaveStyle: const PlayerWaveStyle(
              liveWaveColor: AppColors.black,
              fixedWaveColor: AppColors.black20,
              backgroundColor: Colors.transparent,
              scaleFactor: 60,
              waveThickness: 3,
              spacing: 4,
            ),
            outgoingPlayerWaveStyle: const PlayerWaveStyle(
              liveWaveColor: AppColors.white,
              fixedWaveColor: AppColors.white20,
              backgroundColor: Colors.transparent,
              scaleFactor: 60,
              waveThickness: 3,
              spacing: 4,
            ),
          ),
          messageReactionConfig: MessageReactionConfiguration(
            backgroundColor: Colors.white,
            borderColor: Colors.grey.shade300,
            reactionsBottomSheetConfig: const ReactionsBottomSheetConfiguration(
              backgroundColor: Colors.white,
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
          backgroundColor: AppColors.instaReplyBackground,
          verticalBarColor: AppColors.instaLightGrey,
          textStyle: const TextStyle(color: AppColors.instaReplyText),
          replyTitleTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.instaReplyTitleText,
          ),
          loadOldReplyMessage: (id) async => {},
          repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
            enableHighlightRepliedMsg: true,
            highlightScale: 1.1,
            highlightColor: Colors.grey.shade300,
          ),
        ),
        swipeToReplyConfig: SwipeToReplyConfiguration(
          replyIconColor: theme.swipeToReplyIconColor,
        ),
        replySuggestionsConfig: ReplySuggestionsConfig(
          itemConfig: SuggestionItemConfig(
            decoration: BoxDecoration(
              color: theme.textFieldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.outgoingChatBubbleColor ?? Colors.white,
              ),
            ),
            textStyle: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          onTap: (item) => _onSendTap(
            item.text,
            const ReplyMessage(),
            MessageType.text,
          ),
        ),
      ),
    );
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
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
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
      decoration: const BoxDecoration(
        color: AppColors.instaLightGrey,
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This content may have been deleted by its owner or hidden by their privacy settings.',
            style: TextStyle(color: Colors.black87, fontSize: 15),
          ),
        ],
      ),
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
