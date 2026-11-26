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
import '../../inherited_widgets/chat_view_inherited_widget.dart';
import '../../models/config_models/chat_view/chat_bubble.dart';
import '../../utils/constants/constants.dart';
import 'message_last_seen_ago.dart';
import 'seen_label_transition.dart';

/// The "Seen" label under the newest message, once it is read.
///
/// It slides and fades in when the message becomes read, and out when it stops
/// being the newest.
class MessageSeenLabel extends StatelessWidget {
  const MessageSeenLabel({
    required this.message,
    this.controller,
    this.outgoingChatBubbleConfig,
    super.key,
  });

  final Message message;

  /// Used to find out whether [message] is the newest message.
  final ChatController? controller;

  /// Can replace the label with its own `lastSeenAgoBuilder`.
  final ChatBubble? outgoingChatBubbleConfig;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MessageStatus>(
      valueListenable: message.statusNotifier,
      builder: (context, status, child) {
        final showSeen =
            controller?.initialMessageList.lastOrNull?.id == message.id &&
                status.isRead &&
                (ChatViewInheritedWidget.of(context)
                        ?.featureActiveConfig
                        .lastSeenAgoBuilderVisibility ??
                    true);
        return AnimatedSwitcher(
          duration: seenAppearanceAnimationDuration,
          switchInCurve: seenAppearanceAnimationCurve,
          // Flipped so the label leaves quickly instead of slowing down.
          switchOutCurve: seenAppearanceAnimationCurve.flipped,
          // A tear-off, not an inline closure: it is the same object on every
          // rebuild, so the size, fade and slide transitions are not rebuilt
          // each time this bubble rebuilds.
          transitionBuilder: SeenLabelTransition.builder,
          child: showSeen
              ? Align(
                  key: const ValueKey('seen'),
                  widthFactor: 1,
                  alignment: Alignment.centerRight,
                  child: outgoingChatBubbleConfig
                          ?.receiptsWidgetConfig?.lastSeenAgoBuilder
                          ?.call(
                        message,
                        message.createdAt.applicationDateFormatter,
                      ) ??
                      MessageLastSeenAgo(
                        createAt: message.createdAt,
                      ),
                )
              : const SizedBox(key: ValueKey('seen-empty')),
        );
      },
    );
  }
}
