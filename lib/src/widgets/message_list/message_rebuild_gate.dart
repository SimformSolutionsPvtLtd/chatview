import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Builds [builder] once and hands the same widget instance back on later
/// rebuilds, until the [MessageSignature] changes.
///
/// The message list gets a new delegate on every stream event (a send, a
/// reaction), and Flutter rebuilds every mounted item for a new delegate. An
/// item that returns the identical widget instance is skipped by the framework,
/// so unchanged bubbles do no work. Anything the bubble depends on through an
/// `InheritedWidget` still rebuilds it on its own.
class MessageRebuildGate extends StatefulWidget {
  const MessageRebuildGate({
    required this.signature,
    required this.builder,
    super.key,
  });

  /// What the built bubble shows. A different value rebuilds it.
  final MessageSignature signature;

  /// Called only when [signature] changed. It must not read anything that
  /// changes without changing [signature].
  final Widget Function() builder;

  @override
  State<MessageRebuildGate> createState() => _MessageRebuildGateState();
}

class _MessageRebuildGateState extends State<MessageRebuildGate> {
  MessageSignature? _signature;
  Widget? _child;

  @override
  Widget build(BuildContext context) {
    if (_child == null || _signature != widget.signature) {
      _signature = widget.signature;
      _child = widget.builder();
    }
    return _child!;
  }
}

/// The parts of a bubble's inputs that can change.
///
/// [Message] is compared by identity, not by value: the controller replaces a
/// message with a new instance (with its own status notifier) when it changes,
/// and the old bubble must not keep listening to the old one. Reactions and
/// the voice duration are changed in place on the same instance, so their
/// current values are copied here.
///
/// The [sender] is compared by identity too: `ChatController.updateOtherUser`
/// replaces a user with a new instance, and the bubble shows the user's name
/// and photo.
@immutable
class MessageSignature {
  MessageSignature({
    required this.message,
    required this.slideAnimation,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.enableScrollToRepliedMsg,
    this.sender,
  })  : reactions = List.of(message.reaction.reactions),
        reactedUserIds = List.of(message.reaction.reactedUserIds),
        voiceMessageDuration = message.voiceMessageDuration,
        status = message.status;

  final Message message;
  final Object? slideAnimation;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool enableScrollToRepliedMsg;
  final ChatUser? sender;
  final List<String> reactions;
  final List<String> reactedUserIds;
  final Duration? voiceMessageDuration;
  final MessageStatus status;

  @override
  bool operator ==(Object other) =>
      other is MessageSignature &&
      identical(other.message, message) &&
      identical(other.slideAnimation, slideAnimation) &&
      identical(other.sender, sender) &&
      other.isFirstInGroup == isFirstInGroup &&
      other.isLastInGroup == isLastInGroup &&
      other.enableScrollToRepliedMsg == enableScrollToRepliedMsg &&
      other.voiceMessageDuration == voiceMessageDuration &&
      other.status == status &&
      listEquals(other.reactions, reactions) &&
      listEquals(other.reactedUserIds, reactedUserIds);

  @override
  int get hashCode => Object.hash(
        identityHashCode(message),
        isFirstInGroup,
        isLastInGroup,
        status,
        reactions.length,
      );
}
