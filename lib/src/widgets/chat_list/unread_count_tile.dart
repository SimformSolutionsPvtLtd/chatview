import 'package:flutter/material.dart';

import '../../models/config_models/unread_widget_config.dart';
import '../../models/models.dart';
import '../../utils/constants/constants.dart';

class UnreadCountTile extends StatelessWidget {
  const UnreadCountTile({
    required this.chat,
    this.config,
    super.key,
  });

  final ChatViewListModel chat;
  final UnreadWidgetConfig? config;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (config?.unreadCountView.isDot ?? false) {
          final dotSize = config?.width ?? 12;
          return Container(
            width: dotSize,
            height: dotSize,
            decoration: config?.decoration ??
                const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
          );
        } else if (config?.unreadCountView.isNone ?? false) {
          return const SizedBox.shrink();
        } else {
          final displayCount =
              ((config?.unreadCountView.isNinetyNinePlus ?? false) &&
                      chat.unreadCount! > 99)
                  ? '99+'
                  : '${chat.unreadCount}';
          final isSingleDigit = chat.unreadCount! < 10;
          final minWidth = config?.width ?? 20;
          return Container(
            constraints: BoxConstraints(
              minWidth: minWidth,
              minHeight: config?.height ?? 20,
            ),
            padding: isSingleDigit
                ? null
                : const EdgeInsets.symmetric(horizontal: 4),
            decoration: config?.decoration ??
                BoxDecoration(
                  color: primaryColor,
                  shape: isSingleDigit ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius:
                      isSingleDigit ? null : BorderRadius.circular(minWidth),
                ),
            alignment: Alignment.center,
            child: Text(
              displayCount,
              style: config?.unreadCountTextStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
            ),
          );
        }
      },
    );
  }
}
