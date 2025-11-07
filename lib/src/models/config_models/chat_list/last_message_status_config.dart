import '../../../values/typedefs.dart';

class LastMessageStatusConfig {
  const LastMessageStatusConfig({
    this.size = 14,
    this.color,
    this.icon,
    this.statusBuilder,
    this.showStatusFor,
  });

  /// Callback to decide if the status should be shown
  /// in the chat list for a given message.
  ///
  /// By default, displays the last message status for
  /// read, delivered, undelivered, and pending states.
  final MessageStatusIconEnableCallback? showStatusFor;

  /// Color of the message status.
  ///
  /// Defaults to:
  /// {@macro chatview.extensions.MessageStatus.iconColor}
  final MessageStatusColorResolver? color;

  /// Resolver for the icon representing the last message status.
  ///
  /// Defaults to:
  /// {@macro chatview.extensions.MessageStatus.icon}
  final MessageStatusIconResolver? icon;

  /// Size of the active status indicator.
  ///
  /// Defaults to `14`.
  final double size;

  /// Custom widget builder for the active status indicator.
  final MessageStatusBuilder? statusBuilder;
}
