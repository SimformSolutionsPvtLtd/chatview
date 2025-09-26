import 'package:chatview/chatview.dart';
import 'package:example/example_two/example_two_chat_screen.dart';
import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data.dart';
import '../values/colors.dart';
import '../values/icons.dart';

class ExampleTwoListScreen extends StatefulWidget {
  const ExampleTwoListScreen({super.key});

  @override
  State<ExampleTwoListScreen> createState() => _ExampleTwoListScreenState();
}

class _ExampleTwoListScreenState extends State<ExampleTwoListScreen> {
  final _searchController = TextEditingController();

  ChatViewListController? _chatListController;

  ScrollController? _scrollController;

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: AppColors.wpBackground),
      );
    });
  }

  // Assign the controller in didChangeDependencies
  // to ensure PrimaryScrollController is available.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController = PrimaryScrollController.of(context);
    _chatListController ??= ChatViewListController(
      initialChatList: Data.getChatList(),
      scrollController: _scrollController!,
      disposeOtherResources: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: AppColors.wpGreen,
        colorScheme: ColorScheme.fromSwatch(accentColor: AppColors.wpGreen),
      ),
      child: Builder(
        builder: (context) => Scaffold(
          body: _chatListController == null
              ? const Center(child: CircularProgressIndicator())
              : ChatViewList(
                  controller: _chatListController!,
                  appbar: CupertinoSliverNavigationBar(
                    largeTitle: const Text('Chats'),
                    border: const Border.fromBorderSide(BorderSide.none),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0x080A0A0A),
                      child: SvgPicture.asset(
                        AppIcons.wpMoreHoriz,
                        width: 24,
                        height: 24,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExampleOneListScreen(),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.instaPurple,
                          ),
                          child: const Text('Instagram'),
                        ),
                        GestureDetector(
                          onTap: () => showSnackBar('Camera Button Tapped'),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0x080A0A0A),
                            child: SvgPicture.asset(
                              AppIcons.wpCamera,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => showSnackBar('Add Button Tapped'),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.wpGreen,
                            child: SvgPicture.asset(
                              AppIcons.wpAdd,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 80,
                    endIndent: 0,
                    color: AppColors.wpDividerGrey,
                  ),
                  header: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _archiveWidget(),
                    ],
                  ),
                  menuConfig: ChatMenuConfig(
                    deleteCallback: (chat) =>
                        _chatListController?.removeChat(chat.id),
                    muteStatusCallback: (result) =>
                        _chatListController?.updateChat(
                      result.chat.id,
                      (previousChat) => previousChat.copyWith(
                        settings: previousChat.settings.copyWith(
                          muteStatus: result.status,
                        ),
                      ),
                    ),
                    pinStatusCallback: (result) =>
                        _chatListController?.updateChat(
                      result.chat.id,
                      (previousChat) => previousChat.copyWith(
                        settings: previousChat.settings.copyWith(
                          pinStatus: result.status,
                        ),
                      ),
                    ),
                  ),
                  tileConfig: ListTileConfig(
                    onTap: (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExampleTwoChatScreen(chat: value),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    showUserActiveStatusIndicator: false,
                    userAvatarConfig: const UserAvatarConfig(
                      radius: 28,
                      backgroundColor: Color(0xFFD0FECF),
                    ),
                    lastMessageStatusConfig: LastMessageStatusConfig(
                      statusBuilder: (status) => switch (status) {
                        MessageStatus.read => SvgPicture.asset(
                            AppIcons.wpCheckMark,
                            width: 19,
                            height: 19,
                          ),
                        MessageStatus.delivered => SvgPicture.asset(
                            AppIcons.wpCheckMark,
                            width: 19,
                            height: 19,
                            colorFilter: const ColorFilter.mode(
                              AppColors.wpGrey,
                              BlendMode.srcIn,
                            ),
                          ),
                        MessageStatus.pending => const Icon(
                            Icons.schedule,
                            size: 19,
                            color: AppColors.wpGrey,
                          ),
                        MessageStatus.undelivered => const Icon(
                            Icons.error_rounded,
                            size: 19,
                            color: Colors.red,
                          ),
                      },
                    ),
                    pinIconConfig: PinIconConfig(
                      widget: SvgPicture.asset(AppIcons.wpChatPinned),
                    ),
                    typingStatusConfig: const TypingStatusConfig(
                      textStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(0xff767779),
                        fontSize: 14,
                      ),
                    ),
                    timeConfig: const LastMessageTimeConfig(
                      textStyle:
                          TextStyle(color: Color(0xff767779), fontSize: 14),
                    ),
                    unreadCountConfig: const UnreadCountConfig(
                      backgroundColor: AppColors.wpGreen,
                      style: UnreadCountStyle.ninetyNinePlus,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    userNameTextStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    lastMessageTextStyle: const TextStyle(
                      color: Color(0xff767779),
                      fontSize: 14,
                    ),
                  ),
                  searchConfig: SearchConfig(
                    textEditingController: _searchController,
                    hintText: 'Ask Meta AI or Search',
                    hintStyle: const TextStyle(
                      fontSize: 16.4,
                      color: Color(0xFF767779),
                      fontWeight: FontWeight.w400,
                    ),
                    textFieldBackgroundColor: const Color(0xFFF4F4F4),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF767779),
                      size: 24,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onSearch: (value) async {
                      if (value.isEmpty) {
                        return null;
                      }

                      List<ChatViewListItem> chats =
                          _chatListController?.chatListMap.values.toList() ??
                              [];

                      final list = chats
                          .where((chat) => chat.name
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                      return list;
                    },
                  ),
                  footer: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppIcons.wpLock),
                        const SizedBox(width: 3),
                        const Text.rich(
                          TextSpan(
                            text: 'Your personal messages are ',
                            children: [
                              TextSpan(
                                text: 'end-to-end encrypted',
                                style: TextStyle(color: AppColors.wpGreen),
                              ),
                            ],
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.wpGrey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: _buildBottomNavigationBar(),
          floatingActionButton: GestureDetector(
            onTap: () => showSnackBar('Meta AI Button Tapped'),
            child: Container(
              width: 46,
              height: 46,
              padding: const EdgeInsetsGeometry.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F2EB),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: SvgPicture.asset(AppIcons.wpMetaAI),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8),
      child: SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildFilterChip('All'),
            const SizedBox(width: 8),
            _buildFilterChip('Unread'),
            const SizedBox(width: 8),
            _buildFilterChip('Favourites'),
            const SizedBox(width: 8),
            _buildFilterChip('Groups'),
            const SizedBox(width: 8),
            _buildAddFilterChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          _onFilterSelected(label);
        }
      },
      backgroundColor: const Color(0xFFF4F4F4),
      selectedColor: const Color(0xFFD0FECF),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF15603E) : const Color(0xFF767779),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      shape: const StadiumBorder(),
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAddFilterChip() {
    return InkWell(
      onTap: () {
        // TODO: Handle add filter action.
      },
      borderRadius: BorderRadius.circular(19),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(19),
        ),
        child: const Icon(
          Icons.add,
          size: 20,
          color: Color(0xFF767779),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.wpStatus,
            colorFilter: const ColorFilter.mode(
              AppColors.wpGrey,
              BlendMode.srcIn,
            ),
          ),
          label: 'Updates',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.wpCalls,
            colorFilter:
                const ColorFilter.mode(AppColors.wpGrey, BlendMode.srcIn),
          ),
          label: 'Calls',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.wpCommunity,
            colorFilter:
                const ColorFilter.mode(AppColors.wpGrey, BlendMode.srcIn),
          ),
          label: 'Communities',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.wpMessages,
            colorFilter:
                const ColorFilter.mode(AppColors.wpGrey, BlendMode.srcIn),
          ),
          activeIcon: Badge(
            label: const Text('1'),
            offset: const Offset(10, 0),
            backgroundColor: AppColors.wpGreen,
            child: SvgPicture.asset(
              AppIcons.wpMessages,
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.wpSettings,
            colorFilter:
                const ColorFilter.mode(AppColors.wpGrey, BlendMode.srcIn),
          ),
          label: 'Settings',
        ),
      ],
      currentIndex: 3,
      selectedItemColor: Colors.black,
      unselectedItemColor: AppColors.wpGrey,
      showUnselectedLabels: true,
      onTap: (index) {},
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _archiveWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 32),
      child: Row(
        children: [
          SvgPicture.asset(AppIcons.wpArchived, width: 24, height: 24),
          const SizedBox(width: 28.66),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 15, bottom: 12, top: 2.5),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    width: 0.33,
                  ),
                ),
              ),
              child: const Text(
                'Archived',
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    if (filter == 'All') {
      _chatListController?.clearSearch();
      return;
    }

    final List<ChatViewListItem> filteredList;
    switch (filter) {
      case 'Unread':
        filteredList = _chatListController?.chatListMap.values
                .where((chat) => (chat.unreadCount ?? 0) > 0)
                .toList() ??
            [];
        break;
      case 'Favourites':
        filteredList = _chatListController?.chatListMap.values
                .where((chat) => chat.settings.pinStatus.isPinned)
                .toList() ??
            [];
        break;
      case 'Groups':
        filteredList = _chatListController?.chatListMap.values
                .where((chat) => chat.chatRoomType == ChatRoomType.group)
                .toList() ??
            [];
        break;
      default:
        filteredList = _chatListController?.chatListMap.values.toList() ?? [];
        break;
    }
    _chatListController?.setSearchChats(filteredList);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _chatListController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
