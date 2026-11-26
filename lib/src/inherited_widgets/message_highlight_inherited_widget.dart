import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Gives the widgets below a message whether that message is highlighted.
///
/// It is created by `MessageHighlightScope` and read by `HighlightAware`.
class MessageHighlightInheritedWidget extends InheritedWidget {
  const MessageHighlightInheritedWidget({
    required this.isHighlighted,
    required super.child,
    super.key,
  });

  /// Whether the message is highlighted. It only notifies when that changes.
  final ValueListenable<bool> isHighlighted;

  /// The flag of the closest scope above [context], or null if there is none.
  ///
  /// Reading it does not make [context] depend on this widget, so listen to the
  /// returned notifier instead.
  static ValueListenable<bool>? maybeOf(BuildContext context) => context
      .getInheritedWidgetOfExactType<MessageHighlightInheritedWidget>()
      ?.isHighlighted;

  // The notifier never changes for a given scope, so nothing depends on it.
  @override
  bool updateShouldNotify(MessageHighlightInheritedWidget oldWidget) => false;
}
