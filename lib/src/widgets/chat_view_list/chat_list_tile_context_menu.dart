import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../values/enumeration.dart';

class ChatListTileContextMenu extends StatelessWidget {
  const ChatListTileContextMenu({
    required this.chat,
    required this.child,
    required this.config,
    required this.chatTileColor,
    super.key,
  });

  final Widget child;
  final ChatViewListItem chat;
  final ChatMenuConfig config;
  final Color chatTileColor;

  @override
  Widget build(BuildContext context) {
    if (!config.enabled) return child;

    final menu = config.menuBuilder?.call(context, chat, child);
    if (menu != null) return menu;

    final newMuteStatus = switch (chat.settings.muteStatus) {
      MuteStatus.muted => MuteStatus.unmute,
      MuteStatus.unmute => MuteStatus.muted,
    };
    final newPinStatus = switch (chat.settings.pinStatus) {
      PinStatus.pinned => PinStatus.unpinned,
      PinStatus.unpinned => PinStatus.pinned,
    };

    final actions = <Widget>[
      ...?config.actions?.call(chat),
      if (config.muteStatusCallback != null)
        CupertinoContextMenuAction(
          trailingIcon: config.muteStatusTrailingIcon?.call(
                newMuteStatus,
              ) ??
              newMuteStatus.iconData,
          child: Text(
            newMuteStatus.menuName,
            style: config.textStyle,
          ),
          onPressed: () => config.muteStatusCallback?.call((
            chat: chat,
            status: newMuteStatus,
          )),
        ),
      if (config.pinStatusCallback != null)
        CupertinoContextMenuAction(
          trailingIcon: config.pinStatusTrailingIcon?.call(
                newPinStatus,
              ) ??
              newPinStatus.iconData,
          child: Text(
            newPinStatus.menuName,
            style: config.textStyle,
          ),
          onPressed: () => config.pinStatusCallback?.call((
            chat: chat,
            status: newPinStatus,
          )),
        ),
    ];

    return actions.isEmpty
        ? child
        : CupertinoContextMenu.builder(
            builder: (_, __) => Material(
              color: chatTileColor,
              child: child,
            ),
            actions: actions,
          );
  }
}
