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

/// A single piece of a parsed message string — either plain [text] or a
/// resolved mention (when [isMention] is `true`).
class MentionSegment {
  /// Creates a plain-text segment.
  const MentionSegment.text(this.text)
      : id = null,
        name = null;

  /// Creates a mention segment. [text] is the visible (highlighted) label,
  /// e.g. `@John Doe`, while [name] excludes the trigger character.
  const MentionSegment.mention({
    required this.id,
    required this.name,
    required this.text,
  });

  /// The visible text for this segment.
  final String text;

  /// The mention id, or `null` when this is a plain-text segment.
  final String? id;

  /// The mention display name (without the trigger), or `null` for plain text.
  final String? name;

  /// Whether this segment represents a mention.
  bool get isMention => id != null;
}

/// Encodes and decodes mention tokens embedded in a message string.
///
/// Mentions are persisted using a Slack/Discord-style token so they survive
/// reloads and remain robust against display-name changes or duplicate names:
///
/// ```text
/// Hey @[John Doe](u_12), ping @[everyone](everyone)
/// ```
///
/// The visible (decoded) form of the example above is
/// `Hey @John Doe, ping @everyone`.
///
/// The token layout is `<trigger>[<display name>](<id>)`. Display names that
/// contain `]` or ids that contain `)` are not supported inside a token.
class MentionParser {
  MentionParser({this.triggerCharacter = '@'});

  /// The character that begins a mention (defaults to `@`).
  final String triggerCharacter;

  RegExp? _cachedTokenRegExp;

  /// Matches a single encoded mention token, capturing the display name
  /// (group 1) and the id (group 2).
  RegExp get tokenRegExp => _cachedTokenRegExp ??=
      RegExp('${_escapeRegExp(triggerCharacter)}\\[([^\\]]+)\\]\\(([^)]+)\\)');

  /// Builds the encoded token for a mention with [name] and [id].
  String buildToken(String name, String id) => '$triggerCharacter[$name]($id)';

  /// Splits [input] (an encoded message string) into ordered [MentionSegment]s.
  List<MentionSegment> parseSegments(String input) {
    final segments = <MentionSegment>[];
    var lastEnd = 0;
    for (final match in tokenRegExp.allMatches(input)) {
      if (match.start > lastEnd) {
        segments
            .add(MentionSegment.text(input.substring(lastEnd, match.start)));
      }
      final name = match.group(1) ?? '';
      final id = match.group(2) ?? '';
      segments.add(
        MentionSegment.mention(
          id: id,
          name: name,
          text: '$triggerCharacter$name',
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < input.length) {
      segments.add(MentionSegment.text(input.substring(lastEnd)));
    }
    return segments;
  }

  /// Returns `true` if [input] contains at least one encoded mention token.
  bool hasMentions(String input) => tokenRegExp.hasMatch(input);

  /// Converts an encoded message string to its visible plain-text form by
  /// replacing every token with `<trigger><display name>`.
  ///
  /// Useful for notification previews, search indexing, or any place a message
  /// is shown without mention highlighting.
  String toPlainText(String input) => input.replaceAllMapped(
        tokenRegExp,
        (match) => '$triggerCharacter${match.group(1)}',
      );

  /// Extracts every mention contained in [input].
  ///
  /// When [resolve] is provided it is called with each token's `id` and
  /// `name`, allowing the caller to map back to a full [MentionedUser]
  /// (e.g. resolving the everyone target or attaching a [ChatUser]).
  List<MentionedUser> extractMentions(
    String input, {
    MentionedUser Function(String id, String name)? resolve,
  }) {
    final mentions = <MentionedUser>[];
    for (final match in tokenRegExp.allMatches(input)) {
      final name = match.group(1) ?? '';
      final id = match.group(2) ?? '';
      mentions.add(
        resolve?.call(id, name) ?? MentionedUser(id: id, name: name),
      );
    }
    return mentions;
  }

  /// Escapes regular-expression metacharacters in [input] so an arbitrary
  /// [triggerCharacter] can be embedded safely in a pattern.
  static String _escapeRegExp(String input) => input.replaceAllMapped(
        RegExp(r'[.*+?^${}()|[\]\\]'),
        (match) => '\\${match[0]}',
      );
}
