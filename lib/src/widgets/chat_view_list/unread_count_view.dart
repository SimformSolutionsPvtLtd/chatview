import 'package:flutter/material.dart';

import '../../models/config_models/chat_view_list/unread_count_config.dart';
import '../../values/enumeration.dart';

class UnreadCountView extends StatelessWidget {
  const UnreadCountView({
    required this.unreadCount,
    required this.config,
    super.key,
  });

  final int unreadCount;
  final UnreadCountConfig config;

  @override
  Widget build(BuildContext context) {
    final isSingleDigit = unreadCount < 10;
    final minWidth = config.width ?? 20;
    final minHeight = config.height ?? 20;
    return switch (config.style) {
      UnreadCountStyle.none => const SizedBox.shrink(),
      UnreadCountStyle.dot => SizedBox.square(
          dimension: config.width ?? 12,
          child: DecoratedBox(
            decoration: config.decoration ??
                BoxDecoration(
                  color: config.backgroundColor,
                  shape: BoxShape.circle,
                ),
          ),
        ),
      UnreadCountStyle.count || UnreadCountStyle.ninetyNinePlus => Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
          padding:
              isSingleDigit ? null : const EdgeInsets.symmetric(horizontal: 4),
          decoration: config.decoration ??
              BoxDecoration(
                color: config.backgroundColor,
                shape: isSingleDigit ? BoxShape.circle : BoxShape.rectangle,
                borderRadius:
                    isSingleDigit ? null : BorderRadius.circular(minWidth),
              ),
          child: Text(
            config.style.isNinetyNinePlus && unreadCount > 99
                ? '99+'
                : '$unreadCount',
            maxLines: config.maxLines,
            textAlign: TextAlign.center,
            textScaler: config.textScaler,
            style: config.textStyle ??
                TextStyle(
                  color: config.textColor,
                  fontSize: config.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ),
    };
  }
}
