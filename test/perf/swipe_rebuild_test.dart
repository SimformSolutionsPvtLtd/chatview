import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/message_types/message_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// S2: dragging horizontally (swipe-to-see-time) must not re-run the message
/// list's stream builder (sort + separator computation) on every frame.
void main() {
  testWidgets('S2 swipe drag does not re-sort messages per frame',
      (tester) async {
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
              messageSorter: (a, b) {
                sorterCalls++;
                return b.createdAt.compareTo(a.createdAt);
              },
            ),
            featureActiveConfig: const FeatureActiveConfig(
              enableTextField: false,
              enableSwipeToSeeTime: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Behaviour check: the time label is hidden until the list is swiped.
    expect(find.byType(MessageTimeWidget), findsNothing);

    // The label is the bubble's Opacity that wraps MessageTimeWidget.
    double labelOpacity() => tester
        .widget<Opacity>(find
            .ancestor(
              of: find.byType(MessageTimeWidget).first,
              matching: find.byType(Opacity),
            )
            .first)
        .opacity;

    final callsBeforeDrag = sorterCalls;
    final gesture = await tester.startGesture(const Offset(400, 800));
    // Pass the touch slop first so the horizontal drag recognizer wins.
    await gesture.moveBy(const Offset(-60, 0));
    await tester.pump();
    // Early in the swipe the label is only partly visible, not popped in.
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump();
    final partial = labelOpacity();
    expect(partial, greaterThan(0));
    expect(partial, lessThan(1));
    final frameTimes = <int>[];
    const frames = 30;
    for (var i = 0; i < frames; i++) {
      await gesture.moveBy(const Offset(-10, 0));
      final sw = Stopwatch()..start();
      await tester.pump(const Duration(milliseconds: 16));
      frameTimes.add(sw.elapsedMicroseconds);
    }
    // Every drag update restarts the controller, so it only advances once the
    // finger pauses.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MessageTimeWidget), findsWidgets);
    // Past the full reveal distance the label is fully opaque.
    expect(labelOpacity(), 1.0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(MessageTimeWidget), findsNothing);

    final dragCalls = sorterCalls - callsBeforeDrag;
    expect(dragCalls, 0, reason: 'drag must not re-run the sort');
    frameTimes.sort();
    // ignore: avoid_print
    print('S2 sorterCalls total=$sorterCalls | during drag: $dragCalls '
        'over $frames frames | pump p50=${frameTimes[frames ~/ 2]}us '
        'p90=${frameTimes[(frames * 0.9).floor()]}us '
        'max=${frameTimes.last}us');
  });
}
