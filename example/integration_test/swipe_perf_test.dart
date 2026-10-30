import 'dart:ui';

import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/message_types/chat_bubble_widget.dart';
import 'package:chatview/src/widgets/message_types/message_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Profile-mode swipe-to-see-time measurement. Run on a device:
/// `flutter test integration_test/swipe_perf_test.dart -d <id> --profile`
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('swipe to see time', (tester) async {
    final now = DateTime(2026, 10, 1, 12);
    final controller = ChatController(
      initialMessageList: List.generate(
        2000,
        (i) => Message(
          id: '$i',
          message: 'message $i ${'lorem ipsum ' * (i % 5)}',
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
              enableSwipeToSeeTime: true,
              // A bubble's own swipe-to-reply would win the drag.
              enableSwipeToReply: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final timings = <FrameTiming>[];
    void onTimings(List<FrameTiming> t) => timings.addAll(t);
    WidgetsBinding.instance.addTimingsCallback(onTimings);

    final center = tester.getCenter(find.byType(ChatView));
    final firstVisibleMs = <int>[];
    final fullyRevealedMs = <int>[];
    final slideAtEnd = <double>[];
    // The bubble's own slide is the first Transform inside it.
    double slideDx() => tester
        .widget<Transform>(find
            .descendant(
              of: find.byType(ChatBubbleWidget).first,
              matching: find.byType(Transform),
            )
            .first)
        .transform
        .getTranslation()
        .x;
    double labelOpacity() => find.byType(MessageTimeWidget).evaluate().isEmpty
        ? 0
        : tester
            .widget<Opacity>(find
                .ancestor(
                  of: find.byType(MessageTimeWidget).first,
                  matching: find.byType(Opacity),
                )
                .first)
            .opacity;
    final opacityMid = <double>[];
    final opacityEnd = <double>[];
    const swipes = 10;
    const framesPerSwipe = 16;
    for (var s = 0; s < swipes; s++) {
      final gesture = await tester.startGesture(center);
      final sw = Stopwatch()..start();
      int? visibleAt;
      int? fullAt;
      for (var i = 0; i < framesPerSwipe; i++) {
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump(const Duration(milliseconds: 16));
        // After 6 frames the finger has moved ~60px, half the reveal distance.
        if (i == 5) opacityMid.add(labelOpacity());
        if (visibleAt == null &&
            find.byType(MessageTimeWidget).evaluate().isNotEmpty) {
          visibleAt = sw.elapsedMilliseconds;
        }
        if (fullAt == null && slideDx() <= -119.5) {
          fullAt = sw.elapsedMilliseconds;
        }
      }
      firstVisibleMs.add(visibleAt ?? -1);
      fullyRevealedMs.add(fullAt ?? -1);
      slideAtEnd.add(slideDx());
      opacityEnd.add(labelOpacity());
      await gesture.up();
      await tester.pumpAndSettle();
    }
    // Timings are delivered asynchronously.
    await tester.pump(const Duration(seconds: 1));
    WidgetsBinding.instance.removeTimingsCallback(onTimings);

    double pct(List<int> v, double p) =>
        (v.toList()..sort())[((v.length - 1) * p).round()] / 1000;
    final build = timings.map((t) => t.buildDuration.inMicroseconds).toList();
    final raster = timings.map((t) => t.rasterDuration.inMicroseconds).toList();
    final total = timings.map((t) => t.totalSpan.inMicroseconds).toList();
    binding.reportData = {
      'frames': timings.length,
      'build_ms': {
        'p50': pct(build, .5),
        'p90': pct(build, .9),
        'p99': pct(build, .99)
      },
      'raster_ms': {
        'p50': pct(raster, .5),
        'p90': pct(raster, .9),
        'p99': pct(raster, .99)
      },
      'total_ms': {
        'p90': pct(total, .9),
        'p99': pct(total, .99),
        'max': pct(total, 1)
      },
      'janky_over_16_7ms': total.where((t) => t > 16700).length,
      'first_label_visible_ms': firstVisibleMs,
      'fully_revealed_ms': fullyRevealedMs,
      'slide_dx_px_after_16_frames': slideAtEnd,
      'label_opacity_at_60px': opacityMid,
      'label_opacity_at_160px': opacityEnd,
    };
    // ignore: avoid_print
    print('PERF frames=${timings.length} '
        'build ms p50=${pct(build, .5)} p90=${pct(build, .9)} '
        'p99=${pct(build, .99)} | '
        'raster ms p50=${pct(raster, .5)} p90=${pct(raster, .9)} '
        'p99=${pct(raster, .99)} | '
        'total ms p90=${pct(total, .9)} p99=${pct(total, .99)} '
        'max=${pct(total, 1)} | '
        'janky(>16.7ms)=${total.where((t) => t > 16700).length}');
    // ignore: avoid_print
    print('PERF first label visible after (ms, per swipe, -1 = never): '
        '$firstVisibleMs');
  });
}
