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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Collects, in order, every [TextSpan] that carries visible text. This is
  /// robust to the extra wrapping span that [Text.rich] adds for the default
  /// text style.
  List<TextSpan> leafTextSpans(InlineSpan root) {
    final result = <TextSpan>[];
    void visit(InlineSpan span) {
      if (span is! TextSpan) return;
      if (span.text != null) result.add(span);
      final children = span.children;
      if (children != null) {
        for (final child in children) {
          visit(child);
        }
      }
    }

    visit(root);
    return result;
  }

  Future<List<TextSpan>> pumpAndReadSpans(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    final richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(MentionText),
        matching: find.byType(RichText),
      ),
    );
    return leafTextSpans(richText.text);
  }

  testWidgets('highlights mention spans and keeps plain text intact',
      (tester) async {
    final spans = await pumpAndReadSpans(
      tester,
      MentionText(
        encodedText: 'Hi @[John](u1)!',
        parser: MentionParser(),
        style: const TextStyle(color: Colors.black),
        mentionStyle:
            const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );

    expect(spans.map((s) => s.text).toList(), ['Hi ', '@John', '!']);
    expect(spans[1].style?.color, Colors.blue);
    expect(spans[1].style?.fontWeight, FontWeight.bold);
  });

  testWidgets('invokes onMentionTap with the resolved mention', (tester) async {
    MentionedUser? tapped;
    final spans = await pumpAndReadSpans(
      tester,
      MentionText(
        encodedText: 'ping @[everyone](all)',
        parser: MentionParser(),
        style: const TextStyle(color: Colors.black),
        mentionStyle: const TextStyle(color: Colors.blue),
        onMentionTap: (mention) => tapped = mention,
        resolveMention: (id, name) => id == 'all'
            ? MentionedUser.everyone(id: id, name: name)
            : MentionedUser(id: id, name: name),
      ),
    );

    final mentionSpan = spans.firstWhere((s) => s.text == '@everyone');
    expect(mentionSpan.recognizer, isA<TapGestureRecognizer>());
    (mentionSpan.recognizer! as TapGestureRecognizer).onTap!();
    expect(tapped, isNotNull);
    expect(tapped!.isEveryone, isTrue);
  });

  testWidgets('does not attach a recognizer when onMentionTap is null',
      (tester) async {
    final spans = await pumpAndReadSpans(
      tester,
      MentionText(
        encodedText: 'hi @[John](u1)',
        parser: MentionParser(),
        mentionStyle: const TextStyle(color: Colors.blue),
      ),
    );
    final mentionSpan = spans.firstWhere((s) => s.text == '@John');
    expect(mentionSpan.recognizer, isNull);
  });
}
