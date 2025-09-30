import 'package:chatview/chatview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data.dart';
import '../main.dart';
import '../models/chatview_list_theme.dart';
import '../values/colors.dart';
import '../values/icons.dart';
import 'example_two_chat_screen.dart';

class ExampleTwoListScreen extends StatefulWidget {
  const ExampleTwoListScreen({super.key});

  @override
  State<ExampleTwoListScreen> createState() => _ExampleTwoListScreenState();
}

class _ExampleTwoListScreenState extends State<ExampleTwoListScreen> {
  ChatViewListTheme _theme = ChatViewListTheme.uiTwoLight;
  bool _isDarkTheme = false;

  final _searchController = TextEditingController();

  ChatViewListController? _chatListController;

  ScrollController? _scrollController;

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: AppColors.uiTwoBackground),
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
        primaryColor: AppColors.uiTwoGreen,
        colorScheme: ColorScheme.fromSwatch(accentColor: AppColors.uiTwoGreen),
      ),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: _theme.backgroundColor,
          body: _chatListController == null
              ? const Center(child: CircularProgressIndicator())
              : ChatViewList(
                  backgroundColor: _theme.backgroundColor,
                  controller: _chatListController!,
                  header: _buildHeader(),
                  footer: _buildFooter(),
                  appbar: CupertinoSliverNavigationBar(
                    largeTitle: Text(
                      'Chats',
                      style: TextStyle(color: _theme.textColor),
                    ),
                    border: const Border.fromBorderSide(BorderSide.none),
                    backgroundColor: _theme.backgroundColor,
                    leading: PopupMenuButton(
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: CircleAvatar(
                        radius: 14,
                        backgroundColor: _theme.iconButton,
                        child: SvgPicture.asset(
                          AppIcons.moreHoriz,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            _theme.iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'dark_theme',
                          child:
                              Text(' ${_isDarkTheme ? 'Light' : 'Dark'} Mode'),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'dark_theme':
                            _onThemeIconTap();
                        }
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => showSnackBar('Camera Button Tapped'),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: _theme.iconButton,
                            child: SvgPicture.asset(
                              AppIcons.camera,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                _theme.iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => showSnackBar('Add Button Tapped'),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.uiTwoGreen,
                            child: SvgPicture.asset(
                              AppIcons.add,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                _theme.backgroundColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 80,
                    endIndent: 0,
                    color: _theme.divider,
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
                    lastMessageIconColor: _theme.iconColor,
                    onTap: (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExampleTwoChatScreen(chat: value),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    showUserActiveStatusIndicator: false,
                    userAvatarConfig: const UserAvatarConfig(
                      radius: 28,
                      backgroundColor: Color(0xFFD0FECF),
                    ),
                    lastMessageStatusConfig: LastMessageStatusConfig(
                      statusBuilder: (status) => switch (status) {
                        MessageStatus.read => SvgPicture.asset(
                            AppIcons.checkMark,
                            width: 19,
                            height: 19,
                          ),
                        MessageStatus.delivered => SvgPicture.asset(
                            AppIcons.checkMark,
                            width: 19,
                            height: 19,
                            colorFilter: const ColorFilter.mode(
                              AppColors.uiTwoGrey,
                              BlendMode.srcIn,
                            ),
                          ),
                        MessageStatus.pending => const Icon(
                            Icons.schedule,
                            size: 19,
                            color: AppColors.uiTwoGrey,
                          ),
                        MessageStatus.undelivered => const Icon(
                            Icons.error_rounded,
                            size: 19,
                            color: Colors.red,
                          ),
                      },
                    ),
                    pinIconConfig: PinIconConfig(
                      widget: SvgPicture.asset(AppIcons.pinned),
                    ),
                    typingStatusConfig: const TypingStatusConfig(
                      textStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(0xff767779),
                        fontSize: 14,
                      ),
                    ),
                    timeConfig: const LastMessageTimeConfig(
                      textStyle: TextStyle(
                        color: Color(0xff767779),
                        fontSize: 14,
                      ),
                    ),
                    unreadCountConfig: UnreadCountConfig(
                      backgroundColor: AppColors.uiTwoGreen,
                      style: UnreadCountStyle.ninetyNinePlus,
                      textStyle: TextStyle(color: _theme.backgroundColor),
                    ),
                    userNameTextStyle: TextStyle(
                      fontSize: 16,
                      color: _theme.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    lastMessageTextStyle: const TextStyle(
                      color: Color(0xff767779),
                      fontSize: 14,
                    ),
                  ),
                  searchConfig: SearchConfig(
                    textEditingController: _searchController,
                    hintText: 'Ask Meta AI or Search',
                    hintStyle: TextStyle(
                      fontSize: 16.4,
                      color: _theme.searchText,
                      fontWeight: FontWeight.w400,
                    ),
                    textFieldBackgroundColor: _theme.searchBg,
                    prefixIcon: Icon(
                      Icons.search,
                      color: _theme.searchText,
                      size: 24,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: TextStyle(color: _theme.textColor),
                    clearIcon: Icon(
                      Icons.clear,
                      color: _theme.iconColor,
                      size: 24,
                    ),
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
                ),
          bottomNavigationBar: _buildBottomNavigationBar(),
          floatingActionButton: GestureDetector(
            onTap: () => showSnackBar('Meta AI Button Tapped'),
            child: Container(
              width: 46,
              height: 46,
              padding: const EdgeInsetsGeometry.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _theme.floatingButton,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: SvgPicture.asset(AppIcons.ai),
            ),
          ),
        ),
      ),
    );
  }

  void _onThemeIconTap() {
    setState(() {
      if (_isDarkTheme) {
        _theme = ChatViewListTheme.uiTwoLight;
        _isDarkTheme = false;
      } else {
        _theme = ChatViewListTheme.uiTwoDark;
        _isDarkTheme = true;
      }
    });
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppIcons.lock),
          const SizedBox(width: 3),
          const Text.rich(
            TextSpan(
              text: 'Your personal messages are ',
              children: [
                TextSpan(
                  text: 'end-to-end encrypted',
                  style: TextStyle(color: AppColors.uiTwoGreen),
                ),
              ],
              style: TextStyle(
                fontSize: 11,
                color: AppColors.uiTwoGrey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ExampleOneListScreen(),
            ),
          ),
          child: Text(
            '✨ Check out another UI',
            style: TextStyle(
              color: _theme.textColor,
              shadows: [
                Shadow(
                  color: _isDarkTheme ? Colors.white54 : Colors.black54,
                  offset: const Offset(0, -1),
                  blurRadius: 1,
                ),
              ],
              decorationColor: _theme.textColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Padding(
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
        ),
        _archiveWidget(),
        Divider(
          height: 1,
          indent: 80,
          endIndent: 0,
          color: _theme.divider,
        ),
      ],
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
      backgroundColor: _theme.chipBg,
      selectedColor: _theme.selectedChipBg,
      labelStyle: TextStyle(
        color: isSelected ? _theme.selectedChip : _theme.chipText,
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
      onTap: () => showSnackBar('Add Filter Tapped'),
      borderRadius: const BorderRadius.all(Radius.circular(19)),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _theme.chipBg,
          borderRadius: const BorderRadius.all(Radius.circular(19)),
        ),
        child: Icon(
          Icons.add,
          size: 20,
          color: _theme.chipText,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: _theme.backgroundColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.status,
            colorFilter: const ColorFilter.mode(
              AppColors.uiTwoGrey,
              BlendMode.srcIn,
            ),
          ),
          label: 'Updates',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.calls,
            colorFilter:
                const ColorFilter.mode(AppColors.uiTwoGrey, BlendMode.srcIn),
          ),
          label: 'Calls',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.community,
            colorFilter:
                const ColorFilter.mode(AppColors.uiTwoGrey, BlendMode.srcIn),
          ),
          label: 'Communities',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.messages,
            colorFilter:
                const ColorFilter.mode(AppColors.uiTwoGrey, BlendMode.srcIn),
          ),
          activeIcon: Badge(
            label: const Text('1'),
            offset: const Offset(10, 0),
            backgroundColor: AppColors.uiTwoGreen,
            child: SvgPicture.asset(
              AppIcons.messages,
              colorFilter: ColorFilter.mode(_theme.iconColor, BlendMode.srcIn),
            ),
          ),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.settings,
            colorFilter:
                const ColorFilter.mode(AppColors.uiTwoGrey, BlendMode.srcIn),
          ),
          label: 'Settings',
        ),
      ],
      currentIndex: 3,
      selectedItemColor: _theme.textColor,
      unselectedItemColor: AppColors.uiTwoGrey,
      showUnselectedLabels: true,
      onTap: (index) {},
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _archiveWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 32, bottom: 10, right: 32),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.archived,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              _theme.searchText,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 28.66),
          Expanded(
            child: Text(
              'Archived',
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: _theme.searchText,
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
