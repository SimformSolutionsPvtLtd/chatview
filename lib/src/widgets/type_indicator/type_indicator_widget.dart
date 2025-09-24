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

import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/chat_bubble.dart';
import '../../models/config_models/profile_circle_configuration.dart';
import '../../models/config_models/type_indicator_configuration.dart';
import 'typing_dots_bubble.dart';
import 'user_typing_builder.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    required this.typeIndicatorConfig,
    this.showIndicator = false,
    this.chatBubbleConfig,
    super.key,
  });

  /// Allow user to turn on/off typing indicator.
  final bool showIndicator;

  /// Provides configurations related to chat bubble such as padding, margin, max
  /// width etc.
  final ChatBubble? chatBubbleConfig;

  /// Provides configurations related to typing indicator appearance.
  final TypeIndicatorConfiguration typeIndicatorConfig;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;

  late Animation<double> _indicatorSpaceAnimation;

  late Animation<double> _largeBubbleAnimation;

  late AnimationController _repeatingController;
  final List<Interval> _dotIntervals = const [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1.0),
  ];

  final List<AnimationController> _jumpControllers = [];
  final List<Animation> _jumpAnimations = [];

  ProfileCircleConfiguration? profileCircleConfiguration;

  EdgeInsets get typeIndicatorPadding => widget.typeIndicatorConfig.padding;

  @override
  void initState() {
    super.initState();
    if (mounted) _initializeAnimationController();
  }

  void _initializeAnimationController() {
    _appearanceController = AnimationController(
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ).drive(
      Tween<double>(
        begin: 0.0,
        end: 60.0,
      ),
    );

    _largeBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    for (int i = 0; i < 3; i++) {
      _jumpControllers.add(
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
        ),
      );
      _jumpAnimations.add(
        CurvedAnimation(
          parent: _jumpControllers[i],
          curve: Interval((0.2 * i), 0.7, curve: Curves.easeOutSine),
          reverseCurve: Interval((0.2 * i), 0.7, curve: Curves.easeOut),
        ).drive(
          Tween<double>(
            begin: 0,
            end: 10,
          ),
        ),
      );
    }

    if (widget.showIndicator) {
      _showIndicator();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showIndicator != oldWidget.showIndicator) {
      if (widget.showIndicator) {
        _showIndicator();
      } else {
        _hideIndicator();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      profileCircleConfiguration = chatViewIW!.profileCircleConfiguration;
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _repeatingController.dispose();
    for (var element in _jumpControllers) {
      element.dispose();
    }
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 750)
      ..forward();
    _repeatingController.repeat();
    for (int i = 0; i < 3; i++) {
      _jumpControllers[i].repeat(reverse: true);
    }
  }

  void _hideIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 150)
      ..reverse();
    _repeatingController.stop();
    for (int i = 0; i < 3; i++) {
      _jumpControllers[i].stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomIndicator =
        widget.typeIndicatorConfig.customIndicator != null;

    if (isCustomIndicator && widget.showIndicator) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: typeIndicatorPadding,
          child: UserTypingBuilder(
            animation: _largeBubbleAnimation,
            profileConfig: profileCircleConfiguration,
            bubble: widget.typeIndicatorConfig.customIndicator!,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _indicatorSpaceAnimation,
      builder: (context, child) {
        return SizedBox(
          height: _indicatorSpaceAnimation.value,
          child: child,
        );
      },
      child: Stack(
        children: [
          Positioned(
            left: typeIndicatorPadding.left,
            bottom: typeIndicatorPadding.bottom,
            child: UserTypingBuilder(
              animation: _largeBubbleAnimation,
              profileConfig: profileCircleConfiguration,
              bubble: TypingDotsBubble(
                dotIntervals: _dotIntervals,
                jumpAnimations: _jumpAnimations,
                chatBubbleConfig: widget.chatBubbleConfig,
                repeatAnimationController: _repeatingController,
                typeIndicatorConfig: widget.typeIndicatorConfig,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
