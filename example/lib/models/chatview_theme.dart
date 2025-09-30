import 'package:flutter/material.dart';

class ChatViewTheme {
  const ChatViewTheme({
    required this.textColor,
    required this.titleColor,
    required this.iconColor,
    required this.backgroundColor,
    required this.textField,
    required this.incomingBubble,
    required this.verticalDivider,
    required this.replyBg,
    required this.replyText,
  });

  final Color textColor;
  final Color titleColor;
  final Color iconColor;
  final Color backgroundColor;
  final Color textField;
  final Color incomingBubble;
  final Color verticalDivider;
  final Color replyBg;
  final Color replyText;

  static const ChatViewTheme uiOneDark = ChatViewTheme(
    iconColor: Colors.white,
    textColor: Colors.white,
    titleColor: Color(0xff6B7079),
    backgroundColor: Color(0xff0C1014),
    textField: Color(0xff1C1E1F),
    incomingBubble: Color(0xff26292E),
    verticalDivider: Color(0xff191C21),
    replyBg: Color(0xff191C21),
    replyText: Color(0xff999B9D),
  );

  static const ChatViewTheme uiOneLight = ChatViewTheme(
    iconColor: Colors.black,
    textColor: Colors.black,
    titleColor: Colors.black,
    backgroundColor: Colors.white,
    textField: Color(0xffF7F7F7),
    incomingBubble: Color(0xffF3F5F7),
    verticalDivider: Color(0xffF3F5F7),
    replyBg: Color(0xffF9FAFB),
    replyText: Color(0xff6D7073),
  );
}
