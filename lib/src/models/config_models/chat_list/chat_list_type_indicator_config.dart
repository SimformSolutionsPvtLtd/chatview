import 'package:flutter/material.dart';

import '../../../../chatview.dart';

class ChatListTypeIndicatorConfig {
  const ChatListTypeIndicatorConfig({
    this.suffix = '...',
    this.maxLines = 1,
    this.textStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
    ),
    this.overflow = TextOverflow.ellipsis,
    this.prefix,
    this.textBuilder,
    this.widgetBuilder,
  });

  final String? suffix;
  final String? prefix;
  final TextStyle? textStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final ChatListTextBuilder? textBuilder;
  final ChatListWidgetBuilder? widgetBuilder;
}
