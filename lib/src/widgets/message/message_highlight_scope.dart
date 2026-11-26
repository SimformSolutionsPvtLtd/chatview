import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../inherited_widgets/message_highlight_inherited_widget.dart';

/// Tells the bubble below whether its message is the highlighted one, without
/// rebuilding the bubble when that changes.
///
/// The list keeps one notifier, [highlightedId], with the id of the message to
/// highlight. If every message listened to it directly, as the list did
/// before, each change would rebuild every visible bubble, although only two
/// messages change: the one losing the highlight and the one gaining it.
///
/// So each message gets this scope. It listens to [highlightedId], keeps its
/// own flag for [id] and updates it only when the answer for [id] changes.
/// Only those two messages are notified, and only a `HighlightAware` below
/// them rebuilds. [child] is never rebuilt by a highlight change.
class MessageHighlightScope extends StatefulWidget {
  const MessageHighlightScope({
    required this.id,
    required this.highlightedId,
    required this.child,
    super.key,
  });

  final String id;
  final ValueListenable<String?> highlightedId;
  final Widget child;

  @override
  State<MessageHighlightScope> createState() => _MessageHighlightScopeState();
}

class _MessageHighlightScopeState extends State<MessageHighlightScope> {
  late final _isHighlighted = ValueNotifier<bool>(_check());

  bool _check() => widget.highlightedId.value == widget.id;

  @override
  void initState() {
    super.initState();
    widget.highlightedId.addListener(_onChange);
  }

  @override
  void didUpdateWidget(MessageHighlightScope old) {
    super.didUpdateWidget(old);
    if (old.highlightedId != widget.highlightedId) {
      old.highlightedId.removeListener(_onChange);
      widget.highlightedId.addListener(_onChange);
    }
    _onChange();
  }

  @override
  void dispose() {
    widget.highlightedId.removeListener(_onChange);
    _isHighlighted.dispose();
    super.dispose();
  }

  // ValueNotifier only notifies when the value changes.
  void _onChange() => _isHighlighted.value = _check();

  @override
  Widget build(BuildContext context) => MessageHighlightInheritedWidget(
        isHighlighted: _isHighlighted,
        child: widget.child,
      );
}
