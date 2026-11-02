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

import '../../utils/constants/constants.dart';
import '../../utils/package_strings.dart';

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
  bool get isSent => !widget.status.isPending;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: sendingAnimationDuration,
    // Start fully visible when pending, collapsed when already sent.
    value: isSent ? 0.0 : 1.0,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: sendingAnimationCurve,
  );

  @override
  void didUpdateWidget(SendingTextLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasPending = oldWidget.status.isPending;
    final isPending = widget.status.isPending;
    if (isPending && !wasPending) {
      // Retry: show the label again.
      _animationController.forward();
    } else if (!isPending && wasPending) {
      // Sent: collapse the label.
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Collapse vertically (so no empty space is left below the bubble once
    // sent) while keeping the label pinned to the sender side (right).
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => ClipRect(
        child: Align(
          alignment: Alignment.centerRight,
          heightFactor: _animation.value.clamp(0.0, 1.0),
          child: Opacity(
            opacity: _animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          PackageStrings.currentLocale.sending,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: 11,
            color: widget.color,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
