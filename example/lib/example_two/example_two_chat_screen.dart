import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../values/colors.dart';
import '../values/borders.dart';
import '../values/icons.dart';
import '../values/images.dart';
import '../widgets/reply_message_tile.dart';
import '../widgets/wp_custom_chat_bar.dart';

class ExampleTwoChatScreen extends StatefulWidget {
  const ExampleTwoChatScreen({required this.chat, super.key});

  final ChatViewListItem chat;

  @override
  State<ExampleTwoChatScreen> createState() => _ExampleTwoChatScreenState();
}

class _ExampleTwoChatScreenState extends State<ExampleTwoChatScreen> {
  bool _isTopPaginationCalled = false;
  bool _isBottomPaginationCalled = false;

  final ChatController _chatController = ChatController(
    initialMessageList: Data.getMessageList(isExampleOne: false),
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
          statusBarColor: Color(0xFFE5DDD5),
          statusBarBrightness: Brightness.dark,
        ),
      );
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.uiTwoBackground,
      body: ChatView(
        chatController: _chatController,
        chatViewState: ChatViewState.hasMessages,

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
        appBar: ChatViewAppBar(
          elevation: 0,
          chatTitle: widget.chat.name,
          chatTitleTextStyle: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          profilePicture: widget.chat.imageUrl,
          backGroundColor: AppColors.uiTwoBackground,
          userStatus: 'tap here for contact info',
          userStatusTextStyle: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
          actions: [
            IconButton(
              // Handle video call
              onPressed: () => showSnackBar('Video call pressed'),
              icon: SvgPicture.asset(AppIcons.video),
            ),
            IconButton(
              // Handle voice call
              onPressed: () => showSnackBar('Voice call pressed'),
              icon: SvgPicture.asset(AppIcons.phone),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'toggle_typing_indicator',
                  child: Text('Toggle TypingIndicator'),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'toggle_typing_indicator':
                    _showHideTypingIndicator();
                }
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        typeIndicatorConfig: TypeIndicatorConfiguration(
          customIndicator: _customTypingIndicator(),
        ),
        profileCircleConfig: const ProfileCircleConfiguration(
          padding: EdgeInsets.only(right: 4),
        ),
        chatBackgroundConfig: ChatBackgroundConfiguration(
          backgroundColor: AppColors.uiTwoBackground,
          backgroundImage: AppImages.wpChatBackground,
          groupSeparatorBuilder: (separator) => _customSeparator(separator),
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          outgoingChatBubbleConfig: const ChatBubble(
            linkPreviewConfig: LinkPreviewConfiguration(
              linkStyle: TextStyle(color: Colors.black87, fontSize: 16),
            ),
            border: AppBorders.exampleTwoMessageBorder,
            color: Color(0xFFD0FECF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(4),
            ),
            textStyle: TextStyle(color: Colors.black87, fontSize: 16),
            padding: EdgeInsets.all(5.5),
            receiptsWidgetConfig: ReceiptsWidgetConfig(
              showReceiptsIn: ShowReceiptsIn.lastMessage,
            ),
          ),
          inComingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: const LinkPreviewConfiguration(
              linkStyle: TextStyle(color: Colors.black87, fontSize: 16),
            ),
            border: AppBorders.exampleTwoMessageBorder,
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(12),
            ),
            textStyle: const TextStyle(color: Colors.black87, fontSize: 16),
            padding: const EdgeInsets.all(5.5),
            onMessageRead: (message) {
              /// send your message reciepts to the other client
              debugPrint('Message Read');
            },
          ),
        ),
        messageConfig: MessageConfiguration(
          voiceMessageConfig: VoiceMessageConfiguration(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            playIcon: (_) => const Icon(
              Icons.play_arrow_rounded,
              size: 38,
              color: Color(0xff767779),
            ),
            pauseIcon: (_) => const Icon(
              Icons.pause_rounded,
              size: 38,
              color: Color(0xff767779),
            ),
            inComingPlayerWaveStyle: const PlayerWaveStyle(
              liveWaveColor: Color(0xff000000),
              fixedWaveColor: Color(0x33000000),
              backgroundColor: Colors.transparent,
              scaleFactor: 60,
              waveThickness: 3,
              spacing: 4,
            ),
            outgoingPlayerWaveStyle: const PlayerWaveStyle(
              liveWaveColor: Color(0xff000000),
              fixedWaveColor: Color(0x33000000),
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
          // Custom message builder for location messages
          customMessageBuilder: (message) {
            // For demo, we check if the message contains 'Twin Pines Mall'
            if (message.message.contains('Twin Pines Mall')) {
              return _buildLocationMessage(message);
            }
            return const SizedBox.shrink();
          },
        ),

        // Reply message configuration
        repliedMessageConfig: RepliedMessageConfiguration(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: Colors.grey.shade100,
          verticalBarColor: const Color(0xFF128C7E),
          loadOldReplyMessage: (messageId) async {},
          repliedMessageWidgetBuilder: (replyMessage) => ReplyMessageTile(
            replyMessage: replyMessage,
            chatController: _chatController,
          ),
        ),

        // Swipe to reply configuration
        swipeToReplyConfig: const SwipeToReplyConfiguration(
          onLeftSwipe: null,
          onRightSwipe: null,
        ),
        sendMessageBuilder: (replyMessage) => WpCustomChatBar(
          chatController: _chatController,
          replyMessage: replyMessage ?? const ReplyMessage(),
          onAttachPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attach button pressed')),
          ),
        ),
        featureActiveConfig: const FeatureActiveConfig(
          lastSeenAgoBuilderVisibility: false,
          enableOtherUserProfileAvatar: false,
          enableOtherUserName: false,
          enablePagination: true,
        ),
        reactionPopupConfig: const ReactionPopupConfiguration(
          backgroundColor: Colors.white,
          shadow: BoxShadow(
            blurRadius: 8,
            color: Colors.black26,
            offset: Offset(0, 4),
          ),
        ),
      ),
    );
  }

  Widget _customTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: AppBorders.exampleTwoMessageBorder,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12.75,
        horizontal: 8.75,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 2.75, backgroundColor: AppColors.uiTwoGrey),
          SizedBox(width: 3),
          CircleAvatar(radius: 2.75, backgroundColor: AppColors.uiTwoGrey),
          SizedBox(width: 3),
          CircleAvatar(radius: 2.75, backgroundColor: AppColors.uiTwoGrey),
        ],
      ),
    );
  }

  Widget _customSeparator(String separator) {
    final date = DateTime.tryParse(separator);
    if (date == null) {
      return const SizedBox.shrink();
    }
    String separatorDate;
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      separatorDate = 'Today';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      separatorDate = 'Yesterday';
    } else {
      separatorDate = DateFormat('d MMMM y').format(date);
    }
    return Align(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 3,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: AppBorders.exampleTwoMessageBorder,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(
          separatorDate,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff0A0A0A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationMessage(Message message) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.fromLTRB(
        message.sentBy == _chatController.currentUser.id ? 64 : 8,
        4,
        message.sentBy == _chatController.currentUser.id ? 8 : 64,
        4,
      ),
      decoration: BoxDecoration(
        color: message.sentBy == _chatController.currentUser.id
            ? const Color(0xFFD0FECF)
            : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message.message,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Text(
            'Hill Valley, CA',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              if (message.sentBy == _chatController.currentUser.id) ...[
                const SizedBox(width: 4),
                Icon(
                  _getMessageStatusIcon(message.status),
                  size: 16,
                  color: _getMessageStatusColor(message.status),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getMessageStatusIcon(MessageStatus status) {
    return switch (status) {
      MessageStatus.delivered => Icons.done_all,
      MessageStatus.read => Icons.done_all,
      MessageStatus.pending => Icons.access_time,
      MessageStatus.undelivered => Icons.error_outline,
    };
  }

  Color _getMessageStatusColor(MessageStatus status) {
    return switch (status) {
      MessageStatus.read => const Color(0xFF4FC3F7),
      MessageStatus.delivered => Colors.grey.shade600,
      MessageStatus.pending => Colors.grey.shade500,
      MessageStatus.undelivered => Colors.red.shade600,
    };
  }
}
