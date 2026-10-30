import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/message_types/chat_bubble_widget.dart';
import 'package:chatview/src/widgets/reply/reply_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plan 1.5 (async safety): jumping to a replied message must not touch the
/// list after it is disposed, and must not leak an unhandled error.
///
/// Every test drives the real flow: tap the reply preview inside a bubble.
void main() {
  const highlight = Duration(milliseconds: 500);
  final base = DateTime(2026, 10, 1, 12);

  Message plain(String id, String text, int hour) => Message(
        id: id,
        message: text,
        createdAt: base.add(Duration(hours: hour)),
        sentBy: '2',
      );

  /// Newest message replies to [targetId]; the other two stay on screen.
  List<Message> messagesReplyingTo(String targetId) => [
        plain('0', 'target', 0),
        plain('1', 'filler', 1),
        Message(
          id: '2',
          message: 'the reply',
          createdAt: base.add(const Duration(hours: 2)),
          sentBy: '1',
          replyMessage: ReplyMessage(
            messageId: targetId,
            message: 'target',
            replyBy: '1',
            replyTo: '2',
          ),
        ),
      ];

  ChatController controllerFor(List<Message> messages) => ChatController(
        initialMessageList: messages,
        scrollController: ScrollController(),
        currentUser: ChatUser(id: '1', name: 'me'),
        otherUsers: [ChatUser(id: '2', name: 'other')],
      );

  Widget app(
    ChatController controller,
    OldReplyMessageFetchCallback loadOldReplyMessage, {
    ValueSetter<String>? onReplyTargetNotFound,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            chatController: controller,
            chatViewState: ChatViewState.hasMessages,
            featureActiveConfig: const FeatureActiveConfig(
              enableTextField: false,
            ),
            repliedMessageConfig: RepliedMessageConfiguration(
              loadOldReplyMessage: loadOldReplyMessage,
              onReplyTargetNotFound: onReplyTargetNotFound,
              repliedMsgAutoScrollConfig: const RepliedMsgAutoScrollConfig(
                highlightDuration: highlight,
              ),
            ),
          ),
        ),
      );

  final highlighted = find.byWidgetPredicate(
    (w) => w is ChatBubbleWidget && w.shouldHighlight,
  );

  Future<void> useBigView(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// The chat scrolls to the last message on a 300ms timer at startup.
  Future<void> settleStartup(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  /// Taps the quoted text inside the reply preview, as a user would.
  Future<void> tapReplyPreview(WidgetTester tester) => tester.tap(
        find.descendant(
          of: find.byType(ReplyMessageWidget),
          matching: find.text('target'),
        ),
      );

  /// Pumps in small steps until [finder] matches, so the check never lands
  /// after the highlight has already been cleared.
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 60 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> disposeChat(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
  }

  testWidgets(
    'highlight timer firing after the chat is disposed does not throw',
    (tester) async {
      await useBigView(tester);
      final controller = controllerFor(messagesReplyingTo('0'));
      await tester.pumpWidget(app(controller, (_) async {}));
      await settleStartup(tester);

      await tapReplyPreview(tester);
      // Once the highlight is applied, a timer is armed to clear it.
      await pumpUntilFound(tester, highlighted);
      expect(highlighted, findsOneWidget, reason: 'highlight must be active');

      await disposeChat(tester);
      await tester.pump(highlight + const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'loadOldReplyMessage completing after the chat is disposed does not throw',
    (tester) async {
      await useBigView(tester);
      // The reply target is not in the list, so it has to be fetched first.
      final controller = controllerFor(messagesReplyingTo('old'));
      final fetch = Completer<void>();
      final requested = <String>[];
      await tester.pumpWidget(
        app(controller, (id) {
          requested.add(id);
          return fetch.future;
        }),
      );
      await settleStartup(tester);

      await tapReplyPreview(tester);
      await tester.pump();
      expect(requested, ['old'], reason: 'the fetch must have started');

      await disposeChat(tester);
      fetch.complete();
      await tester.pump(highlight);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'control: a fetched reply target is still highlighted while mounted',
    (tester) async {
      await useBigView(tester);
      final controller = controllerFor(messagesReplyingTo('old'));
      await tester.pumpWidget(
        app(controller, (id) async {
          controller.addMessage(
            Message(
              id: id,
              message: 'fetched old message',
              createdAt: base.subtract(const Duration(hours: 1)),
              sentBy: '2',
            ),
          );
        }),
      );
      await settleStartup(tester);

      await tapReplyPreview(tester);
      await pumpUntilFound(tester, highlighted);

      expect(find.text('fetched old message'), findsOneWidget);
      expect(highlighted, findsOneWidget);
      await tester.pump(highlight * 2);
    },
  );

  testWidgets(
    'a reply target that never loads is reported, not thrown',
    (tester) async {
      await useBigView(tester);
      final controller = controllerFor(messagesReplyingTo('gone'));
      var fetches = 0;
      final notFound = <String>[];
      await tester.pumpWidget(
        app(
          controller,
          (_) async {
            // The app could not find the message either.
            fetches++;
          },
          onReplyTargetNotFound: notFound.add,
        ),
      );
      await settleStartup(tester);

      await tapReplyPreview(tester);
      await tester.pumpAndSettle();
      expect(fetches, 1, reason: 'the fetch must have run');

      expect(tester.takeException(), isNull);
      expect(notFound, ['gone']);
    },
  );
}
