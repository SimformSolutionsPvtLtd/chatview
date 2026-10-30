import 'dart:ui';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Profile-mode reaction-popup open measurement. Run on a device:
/// `flutter drive --profile -d <id> --driver=test_driver/integration_test.dart
///  --target=integration_test/popup_perf_test.dart`
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('open reaction popup', (tester) async {
    final now = DateTime(2026, 10, 1, 12);
    final controller = ChatController(
      initialMessageList: List.generate(
        2000,
        (i) => Message(
          id: '$i',
          message: 'message $i',
          createdAt: now.add(Duration(hours: i)),
          sentBy: i.isEven ? '1' : '2',
        ),
      ),
      scrollController: ScrollController(),
      currentUser: const ChatUser(id: '1', name: 'me'),
      otherUsers: [const ChatUser(id: '2', name: 'other')],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            chatController: controller,
            chatViewState: ChatViewState.hasMessages,
            featureActiveConfig: const FeatureActiveConfig(
              enableTextField: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final timings = <FrameTiming>[];
    void onTimings(List<FrameTiming> t) => timings.addAll(t);
    WidgetsBinding.instance.addTimingsCallback(onTimings);

    const opens = 8;
    final openMs = <int>[];
    for (var i = 0; i < opens; i++) {
      final sw = Stopwatch()..start();
      await tester.longPress(find.text('message ${1999 - i}'));
      await tester.pump();
      // Frames until the popup has finished animating in.
      await tester.pumpAndSettle();
      openMs.add(sw.elapsedMilliseconds);
      // Dismiss the popup by tapping an empty corner.
      await tester.tapAt(const Offset(2, 60));
      await tester.pumpAndSettle();
    }
    await tester.pump(const Duration(seconds: 1));
    WidgetsBinding.instance.removeTimingsCallback(onTimings);

    double pct(List<int> v, double p) =>
        (v.toList()..sort())[((v.length - 1) * p).round()] / 1000;
    final build = timings.map((t) => t.buildDuration.inMicroseconds).toList();
    final total = timings.map((t) => t.totalSpan.inMicroseconds).toList();
    binding.reportData = {
      'frames': timings.length,
      'build_ms': {
        'p50': pct(build, .5),
        'p99': pct(build, .99),
        'max': pct(build, 1)
      },
      'total_ms': {
        'p90': pct(total, .9),
        'p99': pct(total, .99),
        'max': pct(total, 1)
      },
      'janky_over_16_7ms': total.where((t) => t > 16700).length,
      'long_press_to_settled_ms': openMs,
    };
  });
}
