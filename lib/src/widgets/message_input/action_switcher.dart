import 'package:flutter/material.dart';

import '../../utils/constants/constants.dart';

/// Animates the text field's leading or trailing actions as they change: the
/// bar resizes while the old actions fade and slide out and the new ones in.
class ActionSwitcher extends StatelessWidget {
  const ActionSwitcher({
    required this.isLeading,
    required this.child,
    super.key,
  });

  /// Whether the actions sit before the text field (left) or after it (right).
  final bool isLeading;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final alignment = isLeading ? Alignment.centerLeft : Alignment.centerRight;
    return AnimatedSize(
      duration: textFieldActionAnimationDuration,
      curve: Curves.easeOutCubic,
      alignment: alignment,
      child: AnimatedSwitcher(
        duration: textFieldActionAnimationDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        // Aligned to the text field's side, with the incoming child on top, so
        // the bar never expands to the union of both children.
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: alignment,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        transitionBuilder: (child, animation) => ClipRect(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(isLeading ? -0.35 : 0.35, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
