import 'package:flutter/material.dart';

class ChatViewListTheme {
  const ChatViewListTheme({
    required this.textColor,
    required this.iconColor,
    required this.searchBg,
    required this.searchText,
    required this.lastMessageText,
    required this.backgroundColor,
    required this.secondaryBg,
    required this.iconButton,
    required this.divider,
    required this.floatingButton,
    required this.selectedChip,
    required this.selectedChipBg,
    this.chipBg = Colors.transparent,
    this.chipText = Colors.black,
  });

  final Color textColor;
  final Color iconColor;
  final Color searchBg;
  final Color searchText;
  final Color lastMessageText;
  final Color backgroundColor;
  final Color secondaryBg;
  final Color iconButton;
  final Color divider;
  final Color floatingButton;
  final Color selectedChip;
  final Color selectedChipBg;
  final Color chipBg;
  final Color chipText;

  static const ChatViewListTheme uiOneDark = ChatViewListTheme(
    iconColor: Colors.white,
    divider: Colors.white,
    iconButton: Colors.white,
    textColor: Colors.white,
    searchBg: Color(0xff26292E),
    searchText: Color(0xffA7ADB6),
    lastMessageText: Color(0xff74787F),
    backgroundColor: Color(0xff0B1014),
    secondaryBg: Color(0xff26292E),
    floatingButton: Colors.white,
    selectedChip: Colors.black,
    selectedChipBg: Colors.white,
  );

  static const ChatViewListTheme uiTwoDark = ChatViewListTheme(
    iconColor: Colors.white,
    iconButton: Color(0xff222222),
    textColor: Colors.white,
    searchBg: Color(0xff222222),
    searchText: Color(0xff969494),
    lastMessageText: Color(0xff74787F),
    backgroundColor: Color(0xff0A0A0A),
    secondaryBg: Color(0xff26292E),
    divider: Color(0xff212121),
    floatingButton: Color(0xFF242626),
    selectedChipBg: Color(0xFF1A342A),
    selectedChip: Color(0xFFE0FCD6),
    chipBg: Color(0xFF161717),
    chipText: Color(0xFF969595),
  );

  static const ChatViewListTheme uiTwoLight = ChatViewListTheme(
    iconColor: Colors.black,
    iconButton: Color(0x080A0A0A),
    textColor: Colors.black,
    searchBg: Color(0xFFF4F4F4),
    searchText: Color(0xff767779),
    lastMessageText: Colors.black,
    backgroundColor: Color(0xffFEFFFE),
    secondaryBg: Color(0xffF3F5F7),
    divider: Color(0x33000000),
    floatingButton: Color(0xFFF5F2EB),
    selectedChipBg: Color(0xFFD0FECF),
    selectedChip: Color(0xFF15603E),
    chipBg: Color(0xFFF4F4F4),
    chipText: Color(0xFF767779),
  );

  static const ChatViewListTheme uiOneLight = ChatViewListTheme(
    iconColor: Colors.black,
    divider: Colors.black,
    iconButton: Colors.black,
    textColor: Colors.black,
    searchBg: Color(0xffF3F4F7),
    searchText: Color(0xff5D636E),
    lastMessageText: Colors.black,
    backgroundColor: Color(0xffFEFFFE),
    secondaryBg: Color(0xffF3F5F7),
    floatingButton: Colors.black,
    selectedChip: Colors.white,
    selectedChipBg: Colors.black,
  );
}
