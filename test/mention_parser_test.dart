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
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MentionParser', () {
    final parser = MentionParser();

    test('buildToken produces the expected token layout', () {
      expect(parser.buildToken('John Doe', 'u1'), '@[John Doe](u1)');
    });

    test('hasMentions detects encoded tokens', () {
      expect(parser.hasMentions('hello @[John](u1)'), isTrue);
      expect(parser.hasMentions('plain @text with no token'), isFalse);
      expect(parser.hasMentions('email me at john@x.com'), isFalse);
    });

    test('parseSegments splits plain text and mentions in order', () {
      final segments =
          parser.parseSegments('Hi @[John Doe](u1) and @[everyone](everyone)!');

      expect(segments.length, 5);

      expect(segments[0].isMention, isFalse);
      expect(segments[0].text, 'Hi ');

      expect(segments[1].isMention, isTrue);
      expect(segments[1].id, 'u1');
      expect(segments[1].name, 'John Doe');
      expect(segments[1].text, '@John Doe');

      expect(segments[2].isMention, isFalse);
      expect(segments[2].text, ' and ');

      expect(segments[3].isMention, isTrue);
      expect(segments[3].id, 'everyone');
      expect(segments[3].text, '@everyone');

      expect(segments[4].isMention, isFalse);
      expect(segments[4].text, '!');
    });

    test('toPlainText replaces tokens with visible @name form', () {
      expect(
        parser.toPlainText('Hi @[John Doe](u1) and @[everyone](everyone)!'),
        'Hi @John Doe and @everyone!',
      );
      expect(parser.toPlainText('no tokens here'), 'no tokens here');
    });

    test('extractMentions returns every mention with id and name', () {
      final mentions =
          parser.extractMentions('@[A](1) hi @[B](2) bye @[A](1)');
      expect(mentions.map((m) => m.id).toList(), ['1', '2', '1']);
      expect(mentions.map((m) => m.name).toList(), ['A', 'B', 'A']);
    });

    test('extractMentions uses the resolver when provided', () {
      final mentions = parser.extractMentions(
        '@[All](everyone)',
        resolve: (id, name) => id == 'everyone'
            ? MentionedUser.everyone(id: id, name: name)
            : MentionedUser(id: id, name: name),
      );
      expect(mentions.single.isEveryone, isTrue);
    });

    test('respects a custom trigger character', () {
      final hashParser = MentionParser(triggerCharacter: '#');
      expect(hashParser.buildToken('Room', 'r1'), '#[Room](r1)');
      expect(hashParser.toPlainText('go #[Room](r1)'), 'go #Room');
      // The default '@' must not be treated as a token for this parser.
      expect(hashParser.hasMentions('hi @[John](u1)'), isFalse);
    });

    test('names containing spaces and punctuation round-trip', () {
      const name = "O'Brien Jr.";
      final encoded = 'ping ${parser.buildToken(name, 'u9')}';
      final segments = parser.parseSegments(encoded);
      expect(segments.last.name, name);
      expect(parser.toPlainText(encoded), 'ping @$name');
    });
  });
}
