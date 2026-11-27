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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../utils/mention_parser.dart';
import '../../values/typedefs.dart';

/// Renders an encoded message string with its mentions highlighted (and
/// optionally tappable) inside a message bubble or reply preview.
///
/// Mention tokens are decoded into highlighted spans; any other text is shown
/// as-is. Tap recognizers are created per build and disposed with the widget,
/// avoiding the gesture-recognizer leaks that come from building them in a
/// [StatelessWidget].
class MentionText extends StatefulWidget {
  const MentionText({
    super.key,
    required this.encodedText,
    required this.parser,
    required this.mentionStyle,
    this.style,
    this.textAlign,
    this.onMentionTap,
    this.resolveMention,
  });

  /// The persisted message text containing encoded mention tokens.
  final String encodedText;

  /// Parser configured with the active trigger character.
  final MentionParser parser;

  /// Style applied to highlighted mentions (merged over [style]).
  final TextStyle mentionStyle;

  /// Base text style for non-mention text.
  final TextStyle? style;

  /// Optional text alignment.
  final TextAlign? textAlign;

  /// Called when a mention is tapped. When `null`, mentions are not tappable.
  final MentionTapCallback? onMentionTap;

  /// Resolves a token's `id`/`name` to a full [MentionedUser] (e.g. attaching
  /// the [ChatUser] or flagging the everyone target) for [onMentionTap].
  final MentionedUser Function(String id, String name)? resolveMention;

  @override
  State<MentionText> createState() => _MentionTextState();
}

class _MentionTextState extends State<MentionText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final segments = widget.parser.parseSegments(widget.encodedText);
    final mentionStyle =
        widget.style?.merge(widget.mentionStyle) ?? widget.mentionStyle;

    final spans = <InlineSpan>[
      for (final segment in segments)
        if (segment.isMention)
          TextSpan(
            text: segment.text,
            style: mentionStyle,
            recognizer: _recognizerFor(segment.id!, segment.name!),
          )
        else
          TextSpan(text: segment.text),
    ];

    return Text.rich(
      TextSpan(style: widget.style, children: spans),
      textAlign: widget.textAlign,
    );
  }

  TapGestureRecognizer? _recognizerFor(String id, String name) {
    final onTap = widget.onMentionTap;
    if (onTap == null) return null;
    final recognizer = TapGestureRecognizer()
      ..onTap = () => onTap(
            widget.resolveMention?.call(id, name) ??
                MentionedUser(id: id, name: name),
          );
    _recognizers.add(recognizer);
    return recognizer;
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }
}
