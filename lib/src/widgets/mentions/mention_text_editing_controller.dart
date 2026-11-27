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

import 'dart:math' as math;

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/config_models/mention_configuration.dart';
import '../../utils/mention_parser.dart';
import '../../values/typedefs.dart';

/// Describes the in-progress mention query the user is currently typing, i.e.
/// the run of text between a trigger character and the caret.
@immutable
class MentionQuery {
  const MentionQuery({
    required this.text,
    required this.start,
    required this.end,
  });

  /// Text typed after the trigger character (may be empty right after the
  /// trigger is inserted).
  final String text;

  /// Index of the trigger character in the field text.
  final int start;

  /// Caret index (exclusive end of the query range).
  final int end;

  @override
  bool operator ==(Object other) =>
      other is MentionQuery &&
      other.text == text &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(text, start, end);
}

/// Internal record of a confirmed mention currently present in the field.
class _ActiveMention {
  const _ActiveMention({
    required this.id,
    required this.name,
    required this.start,
    required this.length,
    required this.isEveryone,
  });

  final String id;
  final String name;
  final int start;
  final int length;
  final bool isEveryone;

  int get end => start + length;

  _ActiveMention copyWith({int? start}) => _ActiveMention(
        id: id,
        name: name,
        start: start ?? this.start,
        length: length,
        isEveryone: isEveryone,
      );
}

/// A [TextEditingController] that powers the `@`-mention feature.
///
/// Responsibilities:
/// * Highlights confirmed mentions inside the text field via [buildTextSpan].
/// * Exposes the active [MentionQuery] ([queryNotifier]) so a suggestion list
///   can react while the user types.
/// * Inserts a mention atomically on [selectMention] and deletes it atomically
///   on a single backspace.
/// * Produces the persisted [encodedText] (with mention tokens) and can be
///   rehydrated from one via [setFromEncoded] (used for editing).
class MentionTextEditingController extends TextEditingController {
  MentionTextEditingController({
    super.text,
    this.triggerCharacter = '@',
    this.everyoneId = 'everyone',
    this.composeMentionStyle = MentionConfiguration.defaultMentionTextStyle,
    this.onMentionsChanged,
    this.userResolver,
  }) : _parser = MentionParser(triggerCharacter: triggerCharacter);

  /// Character that begins a mention.
  final String triggerCharacter;

  /// Reserved id used for the everyone target.
  final String everyoneId;

  /// Style applied to confirmed mentions while composing.
  final TextStyle composeMentionStyle;

  /// Notified whenever the set of mentions changes.
  final MentionsCallback? onMentionsChanged;

  /// Optional resolver mapping a mention id to its [ChatUser] (used to attach
  /// the full user to reported [MentionedUser]s).
  ChatUser? Function(String id)? userResolver;

  final MentionParser _parser;

  List<_ActiveMention> _mentions = [];

  final ValueNotifier<MentionQuery?> _query = ValueNotifier(null);

  /// Listenable for the active mention query (null when not mentioning).
  ValueListenable<MentionQuery?> get queryNotifier => _query;

  /// Guards programmatic mutations so they bypass the diff-based range sync.
  bool _suppressSync = false;

  /// The mentions currently present in the field.
  List<MentionedUser> get mentions => [
        for (final m in _mentions)
          MentionedUser(
            id: m.id,
            name: m.name,
            isEveryone: m.isEveryone,
            user: m.isEveryone ? null : userResolver?.call(m.id),
          ),
      ];

  /// Whether the field currently holds at least one mention.
  bool get hasMentions => _mentions.isNotEmpty;

  /// The message text with mentions encoded as tokens, ready to be sent.
  String get encodedText {
    if (_mentions.isEmpty) return text;
    final sorted = [..._mentions]..sort((a, b) => a.start.compareTo(b.start));
    final buffer = StringBuffer();
    var cursor = 0;
    final value = text;
    for (final m in sorted) {
      if (m.start < cursor || m.end > value.length) continue;
      if (m.start > cursor) buffer.write(value.substring(cursor, m.start));
      buffer.write(_parser.buildToken(m.name, m.id));
      cursor = m.end;
    }
    if (cursor < value.length) buffer.write(value.substring(cursor));
    return buffer.toString();
  }

  /// Replaces the active query with the chosen [user] as a confirmed mention
  /// and appends a trailing space.
  void selectMention(MentionedUser user) {
    final query = _query.value;
    if (query == null) return;

    final display = '$triggerCharacter${user.name}';
    final insert = '$display ';
    final newText = text.replaceRange(query.start, query.end, insert);
    final delta = insert.length - (query.end - query.start);

    final updated = <_ActiveMention>[];
    for (final m in _mentions) {
      if (m.end <= query.start) {
        updated.add(m);
      } else if (m.start >= query.end) {
        updated.add(m.copyWith(start: m.start + delta));
      }
      // Mentions overlapping the query range cannot exist by construction.
    }
    updated.add(
      _ActiveMention(
        id: user.id,
        name: user.name,
        start: query.start,
        length: display.length,
        isEveryone: user.isEveryone,
      ),
    );
    updated.sort((a, b) => a.start.compareTo(b.start));
    _mentions = updated;

    _runSuppressed(() {
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: query.start + insert.length),
      );
    });
    _setQuery(null);
    _notifyMentionsChanged();
  }

  /// Rehydrates the field from an [encoded] string (tokens → visible text +
  /// highlighted mentions). Used when editing an existing message.
  void setFromEncoded(String encoded) {
    final segments = _parser.parseSegments(encoded);
    final buffer = StringBuffer();
    final newMentions = <_ActiveMention>[];
    for (final segment in segments) {
      if (segment.isMention) {
        final start = buffer.length;
        buffer.write(segment.text);
        newMentions.add(
          _ActiveMention(
            id: segment.id!,
            name: segment.name!,
            start: start,
            length: segment.text.length,
            isEveryone: segment.id == everyoneId,
          ),
        );
      } else {
        buffer.write(segment.text);
      }
    }
    _mentions = newMentions;
    final resolved = buffer.toString();
    _runSuppressed(() {
      value = TextEditingValue(
        text: resolved,
        selection: TextSelection.collapsed(offset: resolved.length),
      );
    });
    _setQuery(null);
    _notifyMentionsChanged();
  }

  /// Cancels the active query without selecting anything.
  void cancelQuery() => _setQuery(null);

  @override
  set value(TextEditingValue newValue) {
    if (_suppressSync) {
      super.value = newValue;
      return;
    }

    final oldValue = super.value;
    final oldText = oldValue.text;
    final newText = newValue.text;

    if (oldText == newText) {
      // Selection / composing-only change.
      super.value = newValue;
      _updateQuery();
      return;
    }

    // A single-character backspace landing inside a mention removes only the
    // last word of that mention (and demotes the rest to plain text), instead
    // of clearing the whole mention at once.
    final wordDelete = _tryMentionWordDelete(oldText, newText);
    if (wordDelete != null) {
      super.value = wordDelete;
      _updateQuery();
      _notifyMentionsChanged();
      return;
    }

    _syncMentions(oldText, newText);
    super.value = newValue;
    _updateQuery();
    _notifyMentionsChanged();
  }

  @override
  void clear() {
    _mentions = [];
    _runSuppressed(super.clear);
    _setQuery(null);
    _notifyMentionsChanged();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_mentions.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final mentionStyle =
        (style ?? const TextStyle()).merge(composeMentionStyle);
    final value = text;
    final sorted = [..._mentions]..sort((a, b) => a.start.compareTo(b.start));
    final children = <InlineSpan>[];
    var cursor = 0;
    for (final m in sorted) {
      if (m.start < cursor || m.end > value.length) continue;
      if (m.start > cursor) {
        children.add(TextSpan(text: value.substring(cursor, m.start)));
      }
      children.add(
        TextSpan(text: value.substring(m.start, m.end), style: mentionStyle),
      );
      cursor = m.end;
    }
    if (cursor < value.length) {
      children.add(TextSpan(text: value.substring(cursor)));
    }
    return TextSpan(style: style, children: children);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  void _runSuppressed(VoidCallback action) {
    _suppressSync = true;
    try {
      action();
    } finally {
      _suppressSync = false;
    }
  }

  _ActiveMention? _mentionContaining(int charIndex) {
    for (final m in _mentions) {
      if (charIndex >= m.start && charIndex < m.end) return m;
    }
    return null;
  }

  /// Handles a single-character deletion that falls inside a mention by
  /// removing only the mention's **last word**, keeping the remainder as a
  /// live, highlighted mention.
  ///
  /// For a multi-word name like `@John Doe`, a backspace trims it to `@John`
  /// (still highlighted and still tagged to the same user). The mention is only
  /// fully removed once its last remaining word is deleted. A single-word
  /// mention (e.g. `@Alice` or `@everyone`) is therefore removed in one step.
  /// Returns the corrected value, or `null` if this was not such a deletion.
  TextEditingValue? _tryMentionWordDelete(String oldText, String newText) {
    if (newText.length != oldText.length - 1) return null;

    var i = 0;
    while (i < newText.length && oldText[i] == newText[i]) {
      i++;
    }
    final removedIndex = i;
    final mention = _mentionContaining(removedIndex);
    if (mention == null) return null;

    final mentionText = oldText.substring(mention.start, mention.end);
    final lastSpace = mentionText.lastIndexOf(' ');

    // No internal space left -> the whole (single-word) mention is removed.
    if (lastSpace <= 0) {
      final replaced = oldText.replaceRange(mention.start, mention.end, '');
      _mentions = [
        for (final other in _mentions)
          if (!identical(other, mention))
            other.start >= mention.end
                ? other.copyWith(start: other.start - mention.length)
                : other,
      ];
      return TextEditingValue(
        text: replaced,
        selection: TextSelection.collapsed(offset: mention.start),
      );
    }

    // Multi-word: keep `<trigger><leading words>` as a still-active mention and
    // drop only the trailing word.
    final keptText = mentionText.substring(0, lastSpace);
    final removedLength = mention.end - (mention.start + keptText.length);
    final replaced =
        oldText.replaceRange(mention.start + keptText.length, mention.end, '');
    final trimmedMention = _ActiveMention(
      id: mention.id,
      name: keptText.substring(triggerCharacter.length),
      start: mention.start,
      length: keptText.length,
      isEveryone: mention.isEveryone,
    );
    _mentions = [
      for (final other in _mentions)
        if (identical(other, mention))
          trimmedMention
        else if (other.start >= mention.end)
          other.copyWith(start: other.start - removedLength)
        else
          other,
    ];
    return TextEditingValue(
      text: replaced,
      selection: TextSelection.collapsed(offset: mention.start + keptText.length),
    );
  }

  /// Shifts/invalidates mention ranges after an arbitrary text edit, using a
  /// common-prefix/suffix diff between [oldText] and [newText].
  void _syncMentions(String oldText, String newText) {
    if (_mentions.isEmpty) return;

    final minLen = math.min(oldText.length, newText.length);
    var prefix = 0;
    while (prefix < minLen && oldText[prefix] == newText[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < (minLen - prefix) &&
        oldText[oldText.length - 1 - suffix] ==
            newText[newText.length - 1 - suffix]) {
      suffix++;
    }

    final changeStart = prefix;
    final changeEnd = oldText.length - suffix;
    final delta = newText.length - oldText.length;

    final survivors = <_ActiveMention>[];
    for (final m in _mentions) {
      if (m.end <= changeStart) {
        survivors.add(m);
      } else if (m.start >= changeEnd) {
        survivors.add(m.copyWith(start: m.start + delta));
      }
      // Otherwise the edit overlaps the mention → drop it.
    }
    _mentions = survivors;
  }

  void _updateQuery() {
    final sel = selection;
    if (!sel.isValid || !sel.isCollapsed) {
      _setQuery(null);
      return;
    }
    final cursor = sel.baseOffset;
    final value = text;
    if (cursor < 0 || cursor > value.length) {
      _setQuery(null);
      return;
    }

    final before = value.substring(0, cursor);
    final atIndex = before.lastIndexOf(triggerCharacter);
    if (atIndex == -1) {
      _setQuery(null);
      return;
    }
    if (_mentionContaining(atIndex) != null) {
      _setQuery(null);
      return;
    }
    if (atIndex > 0 && !_isWhitespace(value[atIndex - 1])) {
      _setQuery(null);
      return;
    }
    final query = before.substring(atIndex + triggerCharacter.length);
    if (query.contains('\n') || query.startsWith(' ')) {
      _setQuery(null);
      return;
    }
    _setQuery(MentionQuery(text: query, start: atIndex, end: cursor));
  }

  void _setQuery(MentionQuery? query) => _query.value = query;

  void _notifyMentionsChanged() => onMentionsChanged?.call(mentions);

  bool _isWhitespace(String char) =>
      char == ' ' || char == '\n' || char == '\t' || char == '\r';
}
