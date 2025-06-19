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

import '../extensions/extensions.dart';
import '../models/config_models/reaction_popup_configuration.dart';
import '../values/typedefs.dart';
import 'emoji_row.dart';
import 'glassmorphism_reaction_popup.dart';

class ReactionPopup extends StatefulWidget {
  const ReactionPopup({
    Key? key,
    required this.onTap,
    required this.showPopUp,
  }) : super(key: key);

  /// Provides call back when user taps on reaction pop-up.
  final VoidCallBack onTap;

  /// Represents should pop-up show or not.
  final bool showPopUp;

  @override
  ReactionPopupState createState() => ReactionPopupState();
}

class ReactionPopupState extends State<ReactionPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: reactionPopupConfig?.animationDuration ??
        const Duration(milliseconds: 180),
  );

  late final Animation<double> _scaleAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
    reverseCurve: Curves.easeInOutSine,
  );

  ReactionPopupConfiguration? get reactionPopupConfig =>
      chatListConfig.reactionPopupConfig;

  bool get showPopUp => widget.showPopUp;
  double _yCoordinate = 0.0;
  double _xCoordinate = 0.0;
  Message? _message;

  ChatController? chatController;
  ChatUser? currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      chatController = chatViewIW!.chatController;
      currentUser = chatController?.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final toolTipWidth = deviceWidth > 450 ? 450 : deviceWidth;
    if (showPopUp) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    return showPopUp
        ? Positioned(
            top: _yCoordinate,
            left: _xCoordinate + toolTipWidth > deviceWidth
                ? deviceWidth - toolTipWidth
                : _xCoordinate - (toolTipWidth / 2) < 0
                    ? 0
                    : _xCoordinate - (toolTipWidth / 2),
            child: SizedBox(
              width: deviceWidth > 450 ? 450 : deviceWidth,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: reactionPopupConfig?.showGlassMorphismEffect ?? false
                      ? GlassMorphismReactionPopup(
                          reactionPopupConfig: reactionPopupConfig,
                          child: _reactionPopupRow,
                        )
                      : Container(
                          constraints: BoxConstraints(
                              maxWidth: reactionPopupConfig?.maxWidth ?? 350),
                          margin: reactionPopupConfig?.margin ??
                              const EdgeInsets.symmetric(horizontal: 25),
                          padding: reactionPopupConfig?.padding ??
                              const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 14,
                              ),
                          decoration: BoxDecoration(
                            color: reactionPopupConfig?.backgroundColor ??
                                Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              reactionPopupConfig?.shadow ??
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 8,
                                    spreadRadius: -2,
                                    offset: const Offset(0, 8),
                                  )
                            ],
                          ),
                          child: _reactionPopupRow,
                        ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget get _reactionPopupRow => EmojiRow(
        onEmojiTap: (emoji) {
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
        },
      );

  void refreshWidget({
    required Message message,
    required double xCoordinate,
    required double yCoordinate,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    _animationController.dispose();
    super.dispose();
  }
}
