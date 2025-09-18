import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/config_models/type_indicator_configuration.dart';

class AnimatedDotBuilder extends StatelessWidget {
  const AnimatedDotBuilder({
    required this.jumpAnimation,
    required this.dotInterval,
    required this.repeatAnimationController,
    required this.typeIndicatorConfig,
    super.key,
  });

  final Animation jumpAnimation;
  final Interval dotInterval;
  final AnimationController repeatAnimationController;
  final TypeIndicatorConfiguration typeIndicatorConfig;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: jumpAnimation,
      builder: (context, child) {
        final circleFlashPercent =
            dotInterval.transform(repeatAnimationController.value);
        final circleColorPercent = sin(pi * circleFlashPercent);
        return Transform.translate(
          offset: Offset(0, jumpAnimation.value),
          child: Container(
            width: typeIndicatorConfig.indicatorSize,
            height: typeIndicatorConfig.indicatorSize,
            margin: EdgeInsets.symmetric(
              horizontal: typeIndicatorConfig.indicatorSpacing,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(
                typeIndicatorConfig.flashingCircleDarkColor,
                typeIndicatorConfig.flashingCircleBrightColor,
                circleColorPercent,
              ),
            ),
          ),
        );
      },
    );
  }
}
