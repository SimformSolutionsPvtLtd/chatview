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

import '../../utils/constants/constants.dart';
import 'sending_label_text.dart';

/// Minimal "Sending..." text label that fades and collapses away once sent.
class SendingTextLabel extends StatefulWidget {
  const SendingTextLabel(this.status, {required this.color, super.key});

  /// Status of the message; the label is shown while it is pending.
  final MessageStatus status;

  /// Color of the label.
  final Color color;

  @override
  State<SendingTextLabel> createState() => _SendingTextLabelState();
}

class _SendingTextLabelState extends State<SendingTextLabel>
    with SingleTickerProviderStateMixin {
  /// Created only when the status actually flips (send / retry), so messages
  /// that are built already settled never allocate a controller.
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void didUpdateWidget(SendingTextLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasPending = oldWidget.status.isPending;
    final isPending = widget.status.isPending;
    if (isPending == wasPending) return;

    final controller = _animationController ??= AnimationController(
      vsync: this,
      duration: sendingAnimationDuration,
      // Continue from the state the label was in before this change.
      value: wasPending ? 1.0 : 0.0,
    );
    _animation ??= controller.drive(CurveTween(curve: sendingAnimationCurve));

    // Retry shows the label again; sent collapses it.
    unawaited(isPending ? controller.forward() : controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animation;

    // Settled as sent: no controller, no animation layers and no text. The
    // Align keeps the same layout as the animated one (full width, 0 height)
    // so nothing shifts.
    if (animation == null && !widget.status.isPending) {
      return const Align(alignment: Alignment.centerRight, heightFactor: 0);
    }

    final label = SendingLabelText(color: widget.color);

    // Settled as pending: same layout as the animated one at full height.
    if (animation == null) {
      return Align(
        alignment: Alignment.centerRight,
        heightFactor: 1,
        child: label,
      );
    }

    // Collapse vertically (so no empty space is left below the bubble once
    // sent) while keeping the label pinned to the sender side (right).
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => ClipRect(
        child: Align(
          alignment: Alignment.centerRight,
          heightFactor: animation.value,
          child: child,
        ),
      ),
      child: FadeTransition(opacity: animation, child: label),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
