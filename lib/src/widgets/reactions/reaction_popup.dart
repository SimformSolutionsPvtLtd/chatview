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

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/config_models/chat_view/reactions/reaction_popup_configuration.dart';
import 'emoji_row.dart';
import 'reaction_popup_background.dart';

class ReactionPopup extends StatefulWidget {
  const ReactionPopup({
    required this.onTap,
    required this.showPopUp,
    super.key,
  });

  /// Provides call back when user taps on reaction pop-up.
  final VoidCallback onTap;

  /// Represents should pop-up show or not.
  final bool showPopUp;

  @override
  ReactionPopupState createState() => ReactionPopupState();
}

class ReactionPopupState extends State<ReactionPopup>
    with SingleTickerProviderStateMixin {
  static const Duration _defaultDuration = Duration(milliseconds: 180);

  /// The duration comes from the config, which can only be read once the
  /// widget is in the tree, so it is set in [didChangeDependencies].
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: _defaultDuration,
  );

  late final CurvedAnimation _scaleAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
    reverseCurve: Curves.easeInOutSine,
  );

  ReactionPopupConfiguration? get reactionPopupConfig =>
      chatListConfig.reactionPopupConfig;

  bool get showPopUp => widget.showPopUp;
  double _yCoordinate = 0;
  double _xCoordinate = 0;
  Message? _message;

  ChatController? chatController;
  ChatUser? currentUser;

  @override
  void initState() {
    super.initState();
    if (showPopUp) unawaited(_animationController.forward());
  }

  @override
  void didUpdateWidget(ReactionPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start the animation only when the popup is really shown or hidden, not
    // on every build.
    if (showPopUp == oldWidget.showPopUp) return;
    if (showPopUp) {
      unawaited(_animationController.forward(from: 0));
    } else {
      // The popup is removed from the tree right away, so there is nothing to
      // animate out. Rewind so the next show starts from 0.
      _animationController.reset();
      _message = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      chatController = chatViewIW!.chatController;
      currentUser = chatController?.currentUser;
    }
    _animationController.duration =
        reactionPopupConfig?.animationDuration ?? _defaultDuration;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = context.widthFraction();
    final toolTipWidth = deviceWidth > 450.0 ? 450.0 : deviceWidth;
    final centeredLeft = _xCoordinate - toolTipWidth * 0.5;
    return showPopUp
        ? Positioned(
            top: _yCoordinate,
            left: _xCoordinate + toolTipWidth > deviceWidth
                ? deviceWidth - toolTipWidth
                : centeredLeft < 0
                    ? 0
                    : centeredLeft,
            child: SizedBox(
              width: toolTipWidth,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ReactionPopupBackground(
                  config: reactionPopupConfig,
                  child: EmojiRow(onEmojiTap: _onEmojiTap),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  void _onEmojiTap(String emoji) {
    widget.onTap();
    if (currentUser != null && _message != null) {
      if (!(reactionPopupConfig?.overrideUserReactionCallback ?? false)) {
        chatController?.setReaction(
          emoji: emoji,
          messageId: _message!.id,
          userId: currentUser!.id,
        );
      }
      reactionPopupConfig?.userReactionCallback?.call(
        _message!,
        emoji,
      );
    }
  }

  void refreshWidget({
    required Message message,
    required double xCoordinate,
    required double yCoordinate,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        final yPosition = yCoordinate -
            (chatViewIW!.reactionPopupKey.currentContext?.size?.height ?? 0);
        _message = message;
        _xCoordinate = xCoordinate;
        _yCoordinate = yPosition < 0 ? 0 : yPosition;
      });
    });
  }

  @override
  void dispose() {
    _scaleAnimation.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
