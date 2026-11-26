import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../../models/config_models/chat_view/reactions/message_reaction_configuration.dart';
import '../../../utils/constants/constants.dart';
import '../../reactions/reaction_widget.dart';

class EmojiMessageView extends StatelessWidget {
  const EmojiMessageView({
    required this.message,
    required this.reaction,
    required this.highlightScale,
    required this.isMessageBySender,
    this.padding,
    this.textStyle,
    this.chatBubbleMaxWidth,
    this.messageReactionConfig,
    super.key,
  });

  final String message;
  final Reaction reaction;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: padding ??
              EdgeInsets.fromLTRB(
                leftPadding2,
                4,
                leftPadding2,
                reaction.reactions.isNotEmpty ? 14 : 0,
              ),
          constraints: BoxConstraints(
            maxWidth:
                chatBubbleMaxWidth ?? MediaQuery.sizeOf(context).width * 0.75,
          ),
          child: Transform.scale(
            scale: highlightScale,
            child: Text(
              message,
              style: textStyle ?? const TextStyle(fontSize: 30),
            ),
          ),
        ),
        if (reaction.reactions.isNotEmpty)
          ReactionWidget(
            reaction: reaction,
            config: messageReactionConfig,
            isMessageBySender: isMessageBySender,
          ),
      ],
    );
  }
}
