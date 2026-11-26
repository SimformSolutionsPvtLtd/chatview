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
import 'dart:async';

import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import 'reply_icon.dart';

class SwipeToReply extends StatefulWidget {
  const SwipeToReply({
    required this.onSwipe,
    required this.child,
    super.key,
    this.isMessageByCurrentUser = true,
  });

  /// Provides callback when user swipes chat bubble from left side.
  final VoidCallback onSwipe;

  /// Allow user to set widget which is showed while user swipes chat bubble.
  final Widget child;

  /// A boolean variable that indicates if the message is sent by the current user.
  ///
  /// This is `true` if the message is authored by the sender (the current user),
  /// and `false` if it is authored by someone else.
  final bool isMessageByCurrentUser;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  // How far the bubble is dragged (0..paddingLimit); only the builder listens.
  final _offset = ValueNotifier<double>(0);

  /// Eases the bubble back on release. Created on the first release only, so
  /// bubbles that are never swiped carry no controller.
  AnimationController? _settle;

  // Finger x at drag start, the swipe distance is measured from it.
  double initialTouchPoint = 0;

  // Makes onSwipe fire once per drag.
  bool isCallBackTriggered = false;

  late bool isMessageByCurrentUser = widget.isMessageByCurrentUser;

  final paddingLimit = 50;
  final double replyIconSize = 25;

  @override
  Widget build(BuildContext context) {
    return !(chatViewIW?.featureActiveConfig.enableSwipeToReply ?? true)
        ? widget.child
        : GestureDetector(
            onHorizontalDragStart: (details) {
              // A new drag cancels a running snap back.
              _settle?.stop();
              initialTouchPoint = details.globalPosition.dx;
            },
            onHorizontalDragEnd: (_) => _reset(),
            onHorizontalDragCancel: _reset,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            child: ValueListenableBuilder(
              valueListenable: _offset,
              child: widget.child,
              builder: (context, paddingValue, child) => Stack(
                alignment: isMessageByCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                fit: StackFit.passthrough,
                children: [
                  // Show the icon only once the bubble has moved past
                  // the icon's size. Before that it is invisible anyway.
                  //
                  // The empty SizedBox keeps the bubble as the 2nd child.
                  // Without it the bubble would shift position, and Flutter
                  // would rebuild it and lose its state.
                  if (paddingValue > replyIconSize)
                    ReplyIcon(
                      replyIconSize: replyIconSize,
                      animationValue: paddingValue / paddingLimit,
                    )
                  else
                    const SizedBox.shrink(),
                  // Translate instead of Padding: padding re-lays out the bubble
                  // on every drag frame, translate only repaints it.
                  Transform.translate(
                    offset: Offset(
                      isMessageByCurrentUser ? -paddingValue : paddingValue,
                      0,
                    ),
                    child: child,
                  ),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    // Disposing a controller also drops its listener.
    _settle?.dispose();
    _offset.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Distance dragged towards the reply side (own messages go left).
    final swipeDistance = isMessageByCurrentUser
        ? (initialTouchPoint - details.globalPosition.dx)
        : (details.globalPosition.dx - initialTouchPoint);

    // Never negative, never past the limit.
    final swipeOffset = swipeDistance.clamp(0.0, paddingLimit).toDouble();
    // Skip the write (and the rebuild) when nothing changed.
    if (swipeOffset != _offset.value) _offset.value = swipeOffset;

    // Reached the limit: trigger the reply once.
    if (swipeOffset >= paddingLimit && !isCallBackTriggered) {
      isCallBackTriggered = true;
      widget.onSwipe();
    }
  }

  void _reset() {
    isCallBackTriggered = false;
    // Nothing to snap back.
    if (_offset.value == 0) return;
    // Start where the bubble is, on every release.
    final snapBack = (_settle ??= _createSnapBackController())
      ..value = _offset.value;
    // Ease the bubble back to 0.
    unawaited(snapBack.animateBack(0, curve: Curves.easeOut));
  }

  AnimationController _createSnapBackController() {
    // Its value is the offset itself (0..paddingLimit).
    final controller = AnimationController(
      vsync: this,
      upperBound: paddingLimit.toDouble(),
      duration: const Duration(milliseconds: 150),
    );
    // Copy each animation frame into the offset the builder listens to.
    return controller..addListener(() => _offset.value = controller.value);
  }
}
