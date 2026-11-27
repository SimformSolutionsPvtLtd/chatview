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

import 'package:chatview/chatview.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Simulates a user edit by replacing the controller value the way a
  /// [TextField] would (text + collapsed caret position).
  void type(MentionTextEditingController c, String text, int caret) {
    c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  group('Query detection', () {
    test('reports the query typed after the trigger', () {
      final c = MentionTextEditingController();
      type(c, 'Hey @Jo', 7);
      expect(c.queryNotifier.value?.text, 'Jo');
      expect(c.queryNotifier.value?.start, 4);
      expect(c.queryNotifier.value?.end, 7);
    });

    test('reports an empty query right after the trigger', () {
      final c = MentionTextEditingController();
      type(c, 'Hey @', 5);
      expect(c.queryNotifier.value?.text, '');
    });

    test('triggers at the start of the line', () {
      final c = MentionTextEditingController();
      type(c, '@bo', 3);
      expect(c.queryNotifier.value?.text, 'bo');
    });

    test('does not trigger when @ is attached to a word (email)', () {
      final c = MentionTextEditingController();
      type(c, 'mail@x', 6);
      expect(c.queryNotifier.value, isNull);
    });

    test('does not trigger when a space follows the trigger immediately', () {
      final c = MentionTextEditingController();
      type(c, '@ hello', 7);
      expect(c.queryNotifier.value, isNull);
    });

    test('cancels the query when the caret leaves the run', () {
      final c = MentionTextEditingController();
      type(c, 'Hey @Jo', 7);
      expect(c.queryNotifier.value, isNotNull);
      // Move caret to the very start (no @ before it).
      c.selection = const TextSelection.collapsed(offset: 0);
      expect(c.queryNotifier.value, isNull);
    });
  });

  group('selectMention', () {
    test('inserts the highlighted display name and a trailing space', () {
      final c = MentionTextEditingController();
      type(c, 'Hey @Jo', 7);
      c.selectMention(const MentionedUser(id: 'u1', name: 'John Doe'));

      expect(c.text, 'Hey @John Doe ');
      expect(c.selection.baseOffset, 'Hey @John Doe '.length);
      expect(c.queryNotifier.value, isNull);
      expect(c.hasMentions, isTrue);
      expect(c.mentions.single.id, 'u1');
    });

    test('encodes the confirmed mention as a token', () {
      final c = MentionTextEditingController();
      type(c, 'Hey @Jo', 7);
      c.selectMention(const MentionedUser(id: 'u1', name: 'John Doe'));
      expect(c.encodedText, 'Hey @[John Doe](u1) ');
    });

    test('supports multiple mentions in one message', () {
      final c = MentionTextEditingController();
      type(c, '@a', 2);
      c.selectMention(const MentionedUser(id: '1', name: 'Alice'));
      // text is now '@Alice '
      final len = c.text.length;
      type(c, '${c.text}@b', len + 2);
      c.selectMention(const MentionedUser(id: '2', name: 'Bob'));

      expect(c.text, '@Alice @Bob ');
      expect(c.encodedText, '@[Alice](1) @[Bob](2) ');
      expect(c.mentions.map((m) => m.id).toList(), ['1', '2']);
    });

    test('reports the everyone target through mentions', () {
      final c = MentionTextEditingController(everyoneId: 'all');
      type(c, '@e', 2);
      c.selectMention(
        const MentionedUser.everyone(id: 'all', name: 'everyone'),
      );
      expect(c.mentions.single.isEveryone, isTrue);
      expect(c.encodedText, '@[everyone](all) ');
    });
  });

  group('Mention deletion (word-wise)', () {
    test('a backspace removes a single-word mention entirely', () {
      final c = MentionTextEditingController();
      type(c, 'Hi @Jo', 6);
      c.selectMention(const MentionedUser(id: 'u1', name: 'Jo'));
      expect(c.text, 'Hi @Jo ');

      // Delete the trailing space — the mention stays intact.
      type(c, 'Hi @Jo', 6);
      expect(c.text, 'Hi @Jo');
      expect(c.mentions, hasLength(1));

      // Backspace into the single-word mention — it is removed entirely.
      type(c, 'Hi @J', 5);
      expect(c.text, 'Hi ');
      expect(c.mentions, isEmpty);
    });

    test('a backspace trims the last word but keeps the mention highlighted',
        () {
      final c = MentionTextEditingController();
      type(c, '@j', 2);
      c.selectMention(const MentionedUser(id: 'u1', name: 'John Doe'));
      expect(c.text, '@John Doe ');

      // Delete the trailing space — the mention stays intact.
      type(c, '@John Doe', 9);
      expect(c.mentions, hasLength(1));

      // Backspace removes only the last word ("Doe"); "@John" remains a live,
      // highlighted mention tagged to the same user.
      type(c, '@John Do', 8);
      expect(c.text, '@John');
      expect(c.mentions, hasLength(1));
      expect(c.mentions.single.id, 'u1');
      expect(c.mentions.single.name, 'John');
      expect(c.encodedText, '@[John](u1)');

      // Backspace again removes the now single-word mention entirely.
      type(c, '@Joh', 4);
      expect(c.text, '');
      expect(c.mentions, isEmpty);
    });

    test('trims one word at a time for a three-word name', () {
      final c = MentionTextEditingController();
      type(c, '@m', 2);
      c.selectMention(const MentionedUser(id: 'u2', name: 'Mary Jane Watson'));
      expect(c.text, '@Mary Jane Watson ');

      // Drop the trailing space first.
      type(c, '@Mary Jane Watson', 17);
      // ⌫ -> removes "Watson", keeps "@Mary Jane" highlighted.
      type(c, '@Mary Jane Watso', 16);
      expect(c.text, '@Mary Jane');
      expect(c.mentions.single.name, 'Mary Jane');
      // ⌫ -> removes "Jane", keeps "@Mary" highlighted.
      type(c, '@Mary Jan', 9);
      expect(c.text, '@Mary');
      expect(c.mentions.single.name, 'Mary');
      expect(c.encodedText, '@[Mary](u2)');
    });

    test('editing before a mention shifts its range', () {
      final c = MentionTextEditingController();
      type(c, '@a', 2);
      c.selectMention(const MentionedUser(id: '1', name: 'Al'));
      // 'Al' mention at start; prepend text before it.
      type(c, 'yo @Al ', 3);
      expect(c.encodedText, 'yo @[Al](1) ');
      expect(c.mentions.single.id, '1');
    });
  });

  group('setFromEncoded', () {
    test('decodes tokens into display text plus highlighted mentions', () {
      final c = MentionTextEditingController();
      c.setFromEncoded('Hi @[John](u1) there');

      expect(c.text, 'Hi @John there');
      expect(c.mentions.single.id, 'u1');
      // Round-trips back to the same encoded form.
      expect(c.encodedText, 'Hi @[John](u1) there');
    });

    test('flags the everyone target by id on decode', () {
      final c = MentionTextEditingController(everyoneId: 'all');
      c.setFromEncoded('Yo @[everyone](all)');
      expect(c.mentions.single.isEveryone, isTrue);
    });
  });

  group('Custom trigger', () {
    test('uses the configured trigger character end to end', () {
      final c = MentionTextEditingController(triggerCharacter: '#');
      type(c, 'tag #ro', 7);
      expect(c.queryNotifier.value?.text, 'ro');
      c.selectMention(const MentionedUser(id: 'u9', name: 'Room'));
      expect(c.text, 'tag #Room ');
      expect(c.encodedText, 'tag #[Room](u9) ');
    });
  });

  group('clear', () {
    test('removes text and mentions', () {
      final c = MentionTextEditingController();
      type(c, '@a', 2);
      c.selectMention(const MentionedUser(id: '1', name: 'Al'));
      c.clear();
      expect(c.text, isEmpty);
      expect(c.mentions, isEmpty);
      expect(c.encodedText, isEmpty);
    });
  });
}
