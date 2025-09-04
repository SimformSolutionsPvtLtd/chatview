import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';

class ChatListTileContextMenuWeb extends StatelessWidget {
  const ChatListTileContextMenuWeb({
    required this.child,
    required this.actions,
    required this.errorColor,
    required this.highlightColor,
    super.key,
  });

  final Widget child;
  final Color errorColor;
  final Color highlightColor;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final highlightNotifier = ValueNotifier(false);
    return ValueListenableBuilder<bool>(
      valueListenable: highlightNotifier,
      builder: (context, highlighted, _) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (details) => kIsWeb
            ? _showMenu(
                context: context,
                errorColor: errorColor,
                highlightNotifier: highlightNotifier,
                globalPosition: details.globalPosition,
              )
            : null,
        onSecondaryTapDown: kIsWeb
            ? null
            : (details) => _showMenu(
                  context: context,
                  errorColor: errorColor,
                  highlightNotifier: highlightNotifier,
                  globalPosition: details.globalPosition,
                ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(color: highlighted ? highlightColor : null),
          child: child,
        ),
      ),
    );
  }

  void _showMenu({
    required Color errorColor,
    required BuildContext context,
    required Offset globalPosition,
    required ValueNotifier<bool> highlightNotifier,
  }) {
    highlightNotifier.value = true;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
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
      if (highlightNotifier.value) {
        highlightNotifier.value = false;
      }
    });
  }
}
