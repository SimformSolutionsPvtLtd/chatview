import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/reactions/reaction_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// S4: rebuilds that don't change the messages (opening the reaction popup)
/// must not re-sort the list or recompute date separators.
void main() {
  testWidgets('S4 popup toggle does not re-sort messages', (tester) async {
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime(2026, 10, 1, 12);
    final messages = List.generate(
      2000,
      (i) => Message(
        id: '$i',
        message: 'message $i',
        // 20 messages per day -> ~100 date separators.
        createdAt: now.add(Duration(hours: i)),
        sentBy: i.isEven ? '1' : '2',
      ),
    );

    var sorterCalls = 0;
    int sorter(Message a, Message b) {
      sorterCalls++;
      return b.createdAt.compareTo(a.createdAt);
    }

    final controller = ChatController(
      initialMessageList: messages,
      scrollController: ScrollController(),
      currentUser: ChatUser(id: '1', name: 'me'),
      otherUsers: [ChatUser(id: '2', name: 'other')],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            chatController: controller,
            chatViewState: ChatViewState.hasMessages,
            chatBackgroundConfig: ChatBackgroundConfiguration(
              sortEnable: true,
              messageSorter: sorter,
            ),
            featureActiveConfig: const FeatureActiveConfig(
              enableTextField: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final callsBefore = sorterCalls;
    // Long press opens the reaction popup, which flips showPopUp and
    // rebuilds the message list.
    // The rebuild runs inside the pumps, so the stopwatch spans the gesture
    // (animation frames included) and is only comparable run to run.
    final sw = Stopwatch()..start();
    await tester.longPress(find.text('message 1999'));
    await tester.pumpAndSettle();
    final popupMicros = sw.elapsedMicroseconds;
    expect(
      tester.widget<ReactionPopup>(find.byType(ReactionPopup)).showPopUp,
      true,
    );

    final popupCalls = sorterCalls - callsBefore;
    // ignore: avoid_print
    print('S4 sorterCalls on popup open: $popupCalls | '
        'long press + settle ${popupMicros}us');
    expect(popupCalls, 0, reason: 'popup toggle must not re-run the sort');

    // Behaviour check: a new message must invalidate the cache.
    controller.addMessage(
      Message(
        id: 'new',
        message: 'brand new',
        createdAt: now.add(const Duration(days: 365)),
        sentBy: '2',
      ),
    );
    await tester.pumpAndSettle();
    expect(sorterCalls, greaterThan(callsBefore));
    expect(find.text('brand new'), findsOneWidget);
  });
}
