import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/constants/constants.dart';
import '../../values/typedefs.dart';

class SwipeToSeeTime extends StatefulWidget {
  const SwipeToSeeTime({
    required this.builder,
    required this.onTap,
    required this.enable,
    required this.isPaused,
    required this.snapBackCurve,
    super.key,
  });

  final SwipeToSeeTimeBuilder builder;

  /// Provides callback when user tap anywhere on whole child.
  final VoidCallback onTap;

  /// Whether the feature is on. When false there is no slide animation
  /// (`null` is passed to `child`) and drags are ignored.
  final bool enable;

  /// Ignores drags while its value is true, for example while the reaction
  /// popup is open. The slide animation stays available.
  ///
  /// Read when a drag event arrives, so toggling it never rebuilds [builder].
  final ValueListenable<bool> isPaused;

  /// Used to give curve of animation which runs while user swipe to see time of
  /// message.
  final Curve snapBackCurve;

  @override
  State<SwipeToSeeTime> createState() => _SwipeToSeeTimeState();
}

class _SwipeToSeeTimeState extends State<SwipeToSeeTime>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;

  /// True while the current drag began in a system gesture (back) area.
  bool _isEdgeDrag = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(SwipeToSeeTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The feature may be turned on after the first build.
    _initializeAnimation();
    // Turned off mid-reveal: the drag end never arrives, so put the messages
    // back here.
    if (oldWidget.enable && !widget.enable) _animationController?.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: widget.enable ? _onHorizontalDragDown : null,
      onHorizontalDragUpdate: widget.enable ? _onHorizontalDrag : null,
      onHorizontalDragEnd: widget.enable
          ? (_) => unawaited(
                _animationController?.animateBack(
                  0,
                  duration: timeRevealSnapBackDuration,
                  curve: widget.snapBackCurve,
                ),
              )
          : null,
      onTap: widget.onTap,
      child: widget.builder(context, widget.enable ? _slideAnimation : null),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  /// Creates the swipe-to-see-time animation, once, and only if the feature
  /// is enabled.
  ///
  /// The controller (0 to 1) tracks the drag. [_slideAnimation] maps it to an
  /// offset from 0 to `-timeRevealDistance` (left). Bubbles listen to
  /// [_slideAnimation] directly, so dragging never rebuilds the list.
  ///
  /// Example: with a [timeRevealDistance] of 120, a 30px drag sets the
  /// controller to 0.25 and the offset to `Offset(-30, 0)`.
  void _initializeAnimation() {
    if (!widget.enable || _animationController != null) return;
    _animationController = AnimationController(
      vsync: this,
      duration: timeRevealSnapBackDuration,
    );
    // No curve, so messages follow the finger 1:1. A curve such as
    // Curves.decelerate would move them 90px after a 60px drag.
    // The curve is applied only on release, in onHorizontalDragEnd.
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-timeRevealDistance, 0),
    ).animate(_animationController!);
  }

  /// Remembers whether the finger landed in a system gesture area, where an
  /// Android back swipe starts, so that swipe does not reveal the time too.
  ///
  /// Uses the touch-down position, because the drag itself is only reported
  /// after the finger has already moved past the touch slop. Reads
  /// [MediaQuery] without subscribing, so a change never rebuilds the list.
  void _onHorizontalDragDown(DragDownDetails details) {
    final media = context.getInheritedWidgetOfExactType<MediaQuery>()?.data;
    if (media == null) {
      _isEdgeDrag = false;
      return;
    }
    final x = details.globalPosition.dx;
    final insets = media.systemGestureInsets;
    _isEdgeDrag = x < insets.left || x > media.size.width - insets.right;
  }

  /// Moves the messages with the finger.
  ///
  /// Each update adds the finger's movement since the last update (`delta`) to
  /// the controller, so the messages follow the finger exactly.
  ///
  /// A leftward drag reveals the time, a rightward drag hides it.
  void _onHorizontalDrag(DragUpdateDetails details) {
    if (_isEdgeDrag || widget.isPaused.value) return;
    if (_animationController case final controller?) {
      controller.value -= details.delta.dx / timeRevealDistance;
    }
  }
}
