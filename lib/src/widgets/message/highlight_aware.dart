import 'package:flutter/widgets.dart';

import '../../inherited_widgets/message_highlight_inherited_widget.dart';

/// Rebuilds [builder] when the surrounding `MessageHighlightScope` says the
/// message is (un)highlighted. [child] is built once and reused.
///
/// [highlighted] is the value from the caller's own API, such as
/// `TextMessageView.highlightMessage`. It still works with no scope above, and
/// either source can turn the highlight on.
class HighlightAware extends StatelessWidget {
  const HighlightAware({
    required this.builder,
    this.highlighted = false,
    this.child,
    super.key,
  });

  final bool highlighted;
  final Widget? child;
  final Widget Function(BuildContext context, bool highlighted, Widget? child)
      builder;

  @override
  Widget build(BuildContext context) {
    final scope = MessageHighlightInheritedWidget.maybeOf(context);
    if (scope == null) return builder(context, highlighted, child);
    return ValueListenableBuilder<bool>(
      valueListenable: scope,
      child: child,
      builder: (context, isHighlighted, child) =>
          builder(context, highlighted || isHighlighted, child),
    );
  }
}
