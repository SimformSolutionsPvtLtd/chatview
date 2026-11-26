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
import '../../models/config_models/chat_view/chat_bubble.dart';
import '../../models/config_models/chat_view/profile_circle_configuration.dart';
import '../../models/config_models/chat_view/type_indicator/type_indicator_configuration.dart';
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

  /// Provides configurations related to chat bubble such as padding, margin,
  /// max width etc.
  final ChatBubble? chatBubbleConfig;

  /// Provides configurations related to typing indicator appearance.
  final TypeIndicatorConfiguration typeIndicatorConfig;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _appearanceController =
      AnimationController(vsync: this);

  late final CurvedAnimation _indicatorSpaceCurve = CurvedAnimation(
    parent: _appearanceController,
    curve: const Interval(0, 0.4, curve: Curves.easeOut),
    reverseCurve: const Interval(0, 1, curve: Curves.easeOut),
  );

  late final Animation<double> _indicatorSpaceAnimation =
      _indicatorSpaceCurve.drive(Tween<double>(begin: 0, end: 60));

  late final CurvedAnimation _largeBubbleAnimation = CurvedAnimation(
    parent: _appearanceController,
    curve: const Interval(0.3, 1, curve: Curves.elasticOut),
    reverseCurve: const Interval(0.5, 1, curve: Curves.easeOut),
  );

  late final AnimationController _repeatingController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  static const List<Interval> _dotIntervals = [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1),
  ];

  /// One controller drives all three dots, each one picks its own part of it
  /// with an [Interval], so they stay in step with a single ticker.
  late final AnimationController _jumpController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 500),
  );

  late final List<CurvedAnimation> _jumpCurves = List.generate(
    3,
    (i) => CurvedAnimation(
      parent: _jumpController,
      curve: Interval(0.2 * i, 0.7, curve: Curves.easeOutSine),
      reverseCurve: Interval(0.2 * i, 0.7, curve: Curves.easeOut),
    ),
  );

  late final List<Animation<double>> _jumpAnimations = [
    for (final curve in _jumpCurves)
      curve.drive(Tween<double>(begin: 0, end: 10)),
  ];

  ProfileCircleConfiguration? profileCircleConfiguration;

  EdgeInsets get typeIndicatorPadding => widget.typeIndicatorConfig.padding;

  @override
  void initState() {
    super.initState();
    if (widget.showIndicator) _showIndicator();
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
    _indicatorSpaceCurve.dispose();
    _largeBubbleAnimation.dispose();
    for (final curve in _jumpCurves) {
      curve.dispose();
    }
    _appearanceController.dispose();
    _repeatingController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController.duration = const Duration(milliseconds: 750);
    unawaited(_appearanceController.forward());
    // A custom indicator replaces the dots, so don't tick them for nothing.
    if (widget.typeIndicatorConfig.customIndicator != null) return;
    unawaited(_repeatingController.repeat());
    unawaited(_jumpController.repeat(reverse: true));
  }

  void _hideIndicator() {
    _appearanceController.duration = const Duration(milliseconds: 150);
    // Keep the dots moving until the bubble has gone, so they do not freeze
    // while it shrinks.
    unawaited(
      _appearanceController.reverse().then((_) {
        if (mounted && !widget.showIndicator) _stopDots();
      }),
    );
  }

  void _stopDots() {
    _repeatingController
      ..stop()
      ..value = 0;
    _jumpController
      ..stop()
      ..value = 0;
  }

  @override
  Widget build(BuildContext context) {
    // Without the dots the custom indicator is also scaled in and out, instead
    // of the default dots taking its place while it leaves.
    if (widget.typeIndicatorConfig.customIndicator case final custom?) {
      return AnimatedBuilder(
        animation: _appearanceController,
        builder: (context, child) =>
            !widget.showIndicator && _appearanceController.isDismissed
                ? const SizedBox.shrink()
                : child!,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: typeIndicatorPadding,
            child: UserTypingBuilder(
              showProfileCircle: false,
              animation: _largeBubbleAnimation,
              profileConfig: profileCircleConfiguration,
              bubble: custom,
            ),
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
              bubble: RepaintBoundary(
                child: TypingDotsBubble(
                  dotIntervals: _dotIntervals,
                  jumpAnimations: _jumpAnimations,
                  chatBubbleConfig: widget.chatBubbleConfig,
                  repeatAnimationController: _repeatingController,
                  typeIndicatorConfig: widget.typeIndicatorConfig,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
