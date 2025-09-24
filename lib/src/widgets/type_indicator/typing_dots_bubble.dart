import 'package:flutter/material.dart';

import '../../models/chat_bubble.dart';
import '../../models/config_models/type_indicator_configuration.dart';
import '../../utils/constants/constants.dart';
import 'animated_dot_builder.dart';

class TypingDotsBubble extends StatelessWidget {
  const TypingDotsBubble({
    required this.typeIndicatorConfig,
    required this.jumpAnimations,
    required this.dotIntervals,
    required this.repeatAnimationController,
    this.chatBubbleConfig,
    super.key,
  });

  final ChatBubble? chatBubbleConfig;
  final List<Interval> dotIntervals;
  final List<Animation<dynamic>> jumpAnimations;
  final AnimationController repeatAnimationController;
  final TypeIndicatorConfiguration typeIndicatorConfig;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: chatBubbleConfig?.padding ??
          const EdgeInsets.fromLTRB(
            leftPadding3,
            0,
            leftPadding3,
            leftPadding3,
          ),
      margin: chatBubbleConfig?.margin ?? const EdgeInsets.fromLTRB(5, 0, 6, 2),
      decoration: BoxDecoration(
        borderRadius: chatBubbleConfig?.borderRadius ??
            BorderRadius.circular(replyBorderRadius2),
        color: chatBubbleConfig?.color ?? Colors.grey.shade500,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            AnimatedDotBuilder(
              dotInterval: dotIntervals[0],
              jumpAnimation: jumpAnimations[2],
              typeIndicatorConfig: typeIndicatorConfig,
              repeatAnimationController: repeatAnimationController,
            ),
            AnimatedDotBuilder(
              dotInterval: dotIntervals[1],
              jumpAnimation: jumpAnimations[1],
              typeIndicatorConfig: typeIndicatorConfig,
              repeatAnimationController: repeatAnimationController,
            ),
            AnimatedDotBuilder(
              dotInterval: dotIntervals[2],
              jumpAnimation: jumpAnimations[0],
              typeIndicatorConfig: typeIndicatorConfig,
              repeatAnimationController: repeatAnimationController,
            ),
          ],
        ),
      ),
    );
  }
}
