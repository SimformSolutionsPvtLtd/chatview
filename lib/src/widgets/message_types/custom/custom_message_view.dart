import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../../models/config_models/chat_view/reactions/message_reaction_configuration.dart';
import '../../reactions/reaction_widget.dart';

class CustomMessageView extends StatelessWidget {
  const CustomMessageView({
    required this.customChild,
    required this.reaction,
    required this.showReactions,
    required this.isMessageBySender,
    this.messageReactionConfig,
    super.key,
  });

  final Reaction reaction;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  final Widget customChild;

  final bool showReactions;

  @override
  Widget build(BuildContext context) {
    final reactionsNotEmpty = reaction.reactions.isNotEmpty;
    return showReactions
        ? Stack(
            // A chip wider than a narrow child must not be cut off.
            clipBehavior: Clip.none,
            children: [
              // Room for the chip to hang below the child, like the other
              // message types.
              Padding(
                padding: EdgeInsets.only(
                  bottom: reactionsNotEmpty ? 15 : 0,
                ),
                child: customChild,
              ),
              if (reactionsNotEmpty)
                ReactionWidget(
                  reaction: reaction,
                  isMessageBySender: isMessageBySender,
                  config: messageReactionConfig,
                ),
            ],
          )
        : customChild;
  }
}
