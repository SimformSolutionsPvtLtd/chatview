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

import '../utils/constants/constants.dart';
import '../values/enumeration.dart';

/// Renders the sending → sent receipt indicator next to an outgoing chat
/// bubble, dispatching to one of the [SendingMessageAnimationType]
/// implementations.
class SendingMessageAnimatingWidget extends StatelessWidget {
  const SendingMessageAnimatingWidget(
    this.status, {
    this.type = SendingMessageAnimationType.slideOut,
    this.color,
    super.key,
  });

  final MessageStatus status;

  /// The animation style used for the pending → sent transition.
  final SendingMessageAnimationType type;

  /// Optional color for the indicator. When null, a default is used. Useful to
  /// match the surrounding bubble (e.g. light color inside a colored bubble).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      SendingMessageAnimationType.slideOut => _SlideOutIndicator(status),
      SendingMessageAnimationType.textLabel => _SendingTextLabel(status),
      SendingMessageAnimationType.clockToTick =>
        _ClockToTickIndicator(status, color: color),
    };
  }
}

/// Default indicator: a small dot that slides out to the right once sent.
class _SlideOutIndicator extends StatefulWidget {
  const _SlideOutIndicator(this.status);

  final MessageStatus status;

  @override
  State<_SlideOutIndicator> createState() => _SlideOutIndicatorState();
}

class _SlideOutIndicatorState extends State<_SlideOutIndicator>
    with SingleTickerProviderStateMixin {
  bool get isSent => widget.status != MessageStatus.pending;

  late final AnimationController _ctrl;
  late final Animation<double> _dx;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: sendingAnimationDuration,
      // Start half-visible while pending, already collapsed when the message
      // was sent before this widget was ever built (e.g. history scroll-in or
      // ShowReceiptsIn.all) so no stuck dot remains.
      value: isSent ? 0.0 : 1.0,
    );
    final curved = CurvedAnimation(parent: _ctrl, curve: sendingAnimationCurve);
    // value=1 → half visible (clip width = _half, circle at dx=0)
    // value=0 → hidden (clip width = 0, circle slid out right by _half)
    _dx = Tween<double>(begin: sendingIndicatorSize / 2, end: 0.0)
        .animate(curved);
    _width = Tween<double>(begin: 0.0, end: sendingIndicatorSize / 2)
        .animate(curved);
  }

  @override
  void didUpdateWidget(_SlideOutIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isSent && oldWidget.status == MessageStatus.pending) {
      Future.delayed(sendingAnimationDuration, () {
        if (mounted) _ctrl.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => SizedBox(
            width: _width.value,
            height: sendingIndicatorSize,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: sendingIndicatorSize,
              maxWidth: sendingIndicatorSize,
              child: Transform.translate(
                offset: Offset(_dx.value, 0),
                child: child,
              ),
            ),
          ),
          child: Container(
            width: sendingIndicatorSize,
            height: sendingIndicatorSize,
            decoration: const BoxDecoration(
              color: sendingIndicatorDefaultColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

/// Minimal "Sending..." text label that fades and collapses away once sent.
class _SendingTextLabel extends StatefulWidget {
  const _SendingTextLabel(this.status);

  final MessageStatus status;

  @override
  State<_SendingTextLabel> createState() => _SendingTextLabelState();
}

class _SendingTextLabelState extends State<_SendingTextLabel>
    with SingleTickerProviderStateMixin {
  bool get isSent => widget.status != MessageStatus.pending;

  late final AnimationController _ctrl;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: sendingAnimationDuration,
      // Start fully visible when pending, collapsed when already sent.
      value: isSent ? 0.0 : 1.0,
    );
    _animation = CurvedAnimation(parent: _ctrl, curve: sendingAnimationCurve);
  }

  @override
  void didUpdateWidget(_SendingTextLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isSent && oldWidget.status == MessageStatus.pending) {
      _ctrl.reverse();
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
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          sendingLabelText,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: 11,
            color: sendingIndicatorDefaultColor,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

/// WhatsApp-style indicator that cross-fades between three states:
/// * [MessageStatus.pending] → a clock icon.
/// * sent (delivered / undelivered) → a single tick.
/// * [MessageStatus.read] → a double tick.
class _ClockToTickIndicator extends StatelessWidget {
  const _ClockToTickIndicator(this.status, {this.color});

  final MessageStatus status;
  final Color? color;

  IconData get _icon => switch (status) {
        MessageStatus.pending => Icons.access_time,
        MessageStatus.read => Icons.done_all,
        _ => Icons.check,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedSwitcher(
        duration: sendingAnimationDuration,
        switchInCurve: sendingAnimationCurve,
        switchOutCurve: sendingAnimationCurve,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          _icon,
          key: ValueKey<IconData>(_icon),
          size: sendingTickIconSize,
          color: color ?? sendingIndicatorDefaultColor,
        ),
      ),
    );
  }
}
