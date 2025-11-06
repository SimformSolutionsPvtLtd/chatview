import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';

class ChatListTileContextMenuWeb extends StatelessWidget {
  const ChatListTileContextMenuWeb({
    required this.chatId,
    required this.child,
    required this.actions,
    required this.errorColor,
    required this.highlightColor,
    required this.highlightNotifier,
    super.key,
  });

  final String chatId;
  final Widget child;
  final Color errorColor;
  final Color highlightColor;
  final List<Widget> actions;
  final ValueNotifier<String?> highlightNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: highlightNotifier,
      builder: (context, highlightedChatId, _) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        // On web, show menu on long press instead of right-click,
        // since right-click conflicts with the browser’s context menu.
        onLongPressStart: (details) => kIsWeb
            ? _showMenu(
                chatId: chatId,
                context: context,
                errorColor: errorColor,
                highlightNotifier: highlightNotifier,
                globalPosition: details.globalPosition,
              )
            : null,
        // On desktop, show menu on right-click. On web, this is disabled
        // to avoid conflict with the browser’s context menu.
        onSecondaryTapDown: kIsWeb
            ? null
            : (details) => _showMenu(
                  chatId: chatId,
                  context: context,
                  errorColor: errorColor,
                  highlightNotifier: highlightNotifier,
                  globalPosition: details.globalPosition,
                ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: highlightedChatId == chatId ? highlightColor : null,
          ),
          child: child,
        ),
      ),
    );
  }

  void _showMenu({
    required String chatId,
    required Color errorColor,
    required BuildContext context,
    required Offset globalPosition,
    required ValueNotifier<String?> highlightNotifier,
  }) {
    highlightNotifier.value = chatId;
    final overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    final actionsLength = actions.length;
    showMenu<int>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(40, 40),
        Offset.zero & (overlayBox?.size ?? Size.zero),
      ),
      items: [
        for (var i = 0; i < actionsLength; i++)
          if (actions[i] case final actionChild)
            actionChild is CupertinoContextMenuAction
                ? actionChild.toPopUpMenuItem<int>(
                    value: i,
                    errorColor: errorColor,
                  )
                : PopupMenuItem<int>(
                    value: i,
                    child: actionChild,
                  ),
      ],
    ).whenComplete(() {
      if (highlightNotifier.value != null) {
        highlightNotifier.value = null;
      }
    });
  }
}
