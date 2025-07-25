import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/package_strings.dart';

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
    final menu = config.builder?.call(context, chat, child);
    if (menu != null) return menu;

    final newMuteStatus = chat.settings.muteStatus.toggle;
    final newPinStatus = chat.settings.pinStatus.toggle;
    final delayDuration = config.callbackDelayDuration;

    final actions = <Widget>[
      ...?config.actions?.call(chat),
      if (config.muteStatusCallback case final callback?)
        CupertinoContextMenuAction(
          trailingIcon: config.muteStatusIcon?.call(newMuteStatus) ??
              newMuteStatus.iconData,
          child: Text(
            newMuteStatus.menuName,
            style: config.textStyle,
            overflow: config.overflow,
            maxLines: config.maxLines,
          ),
          onPressed: () => _menuCallback(
            context: context,
            callbackDelayDuration: delayDuration,
            callback: () => callback.call(
              (chat: chat, status: newMuteStatus),
            ),
          ),
        ),
      if (config.pinStatusCallback case final callback?)
        CupertinoContextMenuAction(
          trailingIcon:
              config.pinStatusIcon?.call(newPinStatus) ?? newPinStatus.iconData,
          child: Text(
            newPinStatus.menuName,
            style: config.textStyle,
            overflow: config.overflow,
            maxLines: config.maxLines,
          ),
          onPressed: () => _menuCallback(
            context: context,
            callbackDelayDuration: delayDuration,
            callback: () => callback.call(
              (chat: chat, status: newPinStatus),
            ),
          ),
        ),
      if (config.deleteCallback case final callback?)
        CupertinoContextMenuAction(
          isDestructiveAction: true,
          trailingIcon: config.deleteIcon ?? Icons.delete_forever,
          child: Text(
            PackageStrings.currentLocale.deleteChat,
            style: config.textStyle,
            overflow: config.overflow,
            maxLines: config.maxLines,
          ),
          onPressed: () => _menuCallback(
            context: context,
            callbackDelayDuration: delayDuration,
            callback: () => callback.call(chat),
          ),
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

  void _menuCallback({
    required BuildContext context,
    required VoidCallback callback,
    Duration? callbackDelayDuration,
  }) {
    if (callbackDelayDuration == null) {
      callback.call();
    } else {
      Future.delayed(callbackDelayDuration, callback);
    }
    Navigator.of(context).pop();
  }
}
