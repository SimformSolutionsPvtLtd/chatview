/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/config_models/chat_view/reactions/message_reaction_configuration.dart';
import '../../utils/measure_size.dart';
import 'reactions_bottomsheet.dart';

class ReactionWidget extends StatefulWidget {
  const ReactionWidget({
    required this.reaction,
    required this.isMessageBySender,
    super.key,
    this.config,
  });

  /// Provides reaction instance of message.
  final Reaction reaction;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? config;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  @override
  State<ReactionWidget> createState() => _ReactionWidgetState();
}

class _ReactionWidgetState extends State<ReactionWidget> {
  static const TextStyle _reactionTextStyle = TextStyle(fontSize: 13);
  bool needToExtend = false;

  MessageReactionConfiguration? get config => widget.config;

  ChatController? chatController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      chatController = chatViewIW!.chatController;
    }
  }

  @override
  Widget build(BuildContext context) {
    //// Convert into set to remove reduntant values
    final reactionsSet = widget.reaction.reactions.toSet();
    final reactionsSetLength = reactionsSet.length;
    final reactedUserIdsLength = widget.reaction.reactedUserIds.length;
    // Read on every build: other users can be added later with
    // `ChatController.updateOtherUser`.
    // TODO: add a non-copying `hasOtherUsers` getter to ChatController
    // (chatview_utils), `otherUsers` copies the map.
    final hasOtherUsers = chatController?.otherUsers.isNotEmpty ?? false;
    return Positioned(
      bottom: 0,
      right: widget.isMessageBySender && needToExtend ? 0 : null,
      child: InkWell(
        onTap: () => chatController != null
            ? ReactionsBottomSheet().show(
                context: context,
                reaction: widget.reaction,
                chatController: chatController!,
                reactionsBottomSheetConfig: config?.reactionsBottomSheetConfig,
              )
            : null,
        child: MeasureSize(
          enabled: widget.isMessageBySender,
          onSizeChange: (extend) {
            if (extend != needToExtend && mounted) {
              setState(() => needToExtend = extend);
            }
          },
          child: Container(
            padding: config?.padding ??
                const EdgeInsets.symmetric(vertical: 1.7, horizontal: 6),
            margin: config?.margin ??
                EdgeInsets.only(
                  left: widget.isMessageBySender ? 10 : 16,
                  right: 10,
                ),
            decoration: BoxDecoration(
              color: config?.backgroundColor ?? Colors.grey.shade200,
              borderRadius: config?.borderRadius ??
                  const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                color: config?.borderColor ?? Colors.white,
                width: config?.borderWidth ?? 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  reactionsSet.join(' '),
                  style: TextStyle(
                    fontSize: config?.reactionSize ?? 13,
                  ),
                ),
                if (hasOtherUsers) ...[
                  if (!(reactedUserIdsLength > 3) && !(reactionsSetLength > 1))
                    ...List.generate(
                      reactedUserIdsLength,
                      (reactedUserIndex) => widget
                          .reaction.reactedUserIds[reactedUserIndex]
                          .getUserProfilePicture(
                        getChatUser: (userId) =>
                            chatController?.getUserFromId(userId),
                        profileCirclePadding: config?.profileCirclePadding,
                        profileCircleRadius: config?.profileCircleRadius,
                      ),
                    ),
                  if (reactedUserIdsLength > 3 && !(reactionsSetLength > 1))
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '+$reactedUserIdsLength',
                        style: config?.reactedUserCountTextStyle ??
                            _reactionTextStyle,
                      ),
                    ),
                  if (reactionsSetLength > 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        reactedUserIdsLength.toString(),
                        style: config?.reactionCountTextStyle ??
                            _reactionTextStyle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
