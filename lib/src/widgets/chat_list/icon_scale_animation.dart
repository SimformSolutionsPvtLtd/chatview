import 'package:flutter/material.dart';

class IconScaleAnimation extends StatelessWidget {
  const IconScaleAnimation({
    required this.child,
    required this.tag,
    this.enable = true,
    super.key,
  });

  final String tag;
  final Widget child;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      // Curves via switchIn/OutCurve, not a CurvedAnimation in the builder:
      // the builder re-runs on every rebuild and each CurvedAnimation adds a
      // listener to the parent that is never removed.
      switchInCurve: Curves.easeInToLinear,
      switchOutCurve: Curves.easeInToLinear,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: enable
          ? SizedBox(
              key: ValueKey('$tag-icon'),
              child: child,
            )
          : SizedBox.shrink(
              key: ValueKey('$tag-icon-empty'),
            ),
    );
  }
}
