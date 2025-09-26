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
  });

  final Color textColor;
  final Color iconColor;
  final Color searchBg;
  final Color searchText;
  final Color lastMessageText;
  final Color backgroundColor;
  final Color secondaryBg;

  static const ChatViewListTheme uiOneDart = ChatViewListTheme(
    iconColor: Colors.white,
    textColor: Colors.white,
    searchBg: Color(0xff26292E),
    searchText: Color(0xffA7ADB6),
    lastMessageText: Color(0xff74787F),
    backgroundColor: Color(0xff0B1014),
    secondaryBg: Color(0xff26292E),
  );

  static const ChatViewListTheme uiOneLight = ChatViewListTheme(
    iconColor: Colors.black,
    textColor: Colors.black,
    searchBg: Color(0xffF3F4F7),
    searchText: Color(0xff5D636E),
    lastMessageText: Colors.black,
    backgroundColor: Color(0xffFEFFFE),
    secondaryBg: Color(0xffF3F5F7),
  );
}
