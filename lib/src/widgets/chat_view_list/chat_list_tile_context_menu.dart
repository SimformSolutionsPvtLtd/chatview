import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/models.dart';
import '../../utils/package_strings.dart';
import 'chat_list_tile_context_menu_web.dart';

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

    final actions = _getActions(
      context: context,
      newMuteStatus: chat.settings.muteStatus.toggle,
      newPinStatus: chat.settings.pinStatus.toggle,
      delayDuration: config.callbackDelayDuration,
    );

    return actions.isEmpty
        ? child
        : defaultTargetPlatform.isMobile
            ? CupertinoContextMenu.builder(
                builder: (_, __) => Material(
                  color: chatTileColor,
                  child: child,
                ),
                actions: actions,
              )
            : ChatListTileContextMenuWeb(
                actions: actions,
                highlightColor: config.highlightColor,
                // Used same color as destructive red of cupertino context menu
                errorColor: CupertinoColors.destructiveRed,
                child: child,
              );
  }

  List<Widget> _getActions({
    required BuildContext context,
    required MuteStatus newMuteStatus,
    required PinStatus newPinStatus,
    Duration? delayDuration,
  }) {
    return <Widget>[
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
  }

  void _menuCallback({
    required BuildContext context,
    required VoidCallback callback,
    Duration? callbackDelayDuration,
  }) {
    if (!defaultTargetPlatform.isMobile) {
      callback.call();
      return;
    }

    if (callbackDelayDuration == null) {
      callback.call();
    } else {
      // Call this after the animation of menu is completed
      // To show chatview list animation
      Future.delayed(callbackDelayDuration, callback);
    }
    Navigator.of(context).pop();
  }
}
