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
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInToLinear,
        ),
        child: child,
      ),
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
