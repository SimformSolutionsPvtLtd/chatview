import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/config_models/chat_view_list/last_message_status_config.dart';

class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon({
    required this.status,
    required this.config,
    super.key,
  });

  final MessageStatus status;
  final LastMessageStatusConfig config;

  @override
  Widget build(BuildContext context) {
    return config.statusBuilder?.call(status) ??
        Icon(
          config.icon?.call(status) ?? status.icon,
          size: config.size,
          color: config.color?.call(status) ?? status.iconColor,
        );
  }
}
