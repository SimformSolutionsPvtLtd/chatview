# Results (before -> after, medians of 3)

| # | Fix | Scenario | Before | After | Verdict |
|---|-----|----------|--------|-------|---------|
| 1 | Stop rebuilding the list on swipe frames | S2 sorter calls | 557,316 | 0 | keep |
|   |     | S2 pump p50 | 18,436us | 822us | keep |
|   |     | S2 pump p90 | 31,636us | 2,006us | keep |
|   |     | S2 behaviour (time label hidden -> shown while swiped -> hidden) | pass | pass | unchanged |
| 2 | Register text controller listener once; dispose RecorderController | S3 addListener calls over 30 keystrokes | 30 | 0 | keep |
|   |     | S3 `_onChanged` runs per keystroke (after n keystrokes) | n+1 | 1 | keep |
| 3 | **Stashed, not applied** (`git stash list`): cache sorted list + separators until stream emits (`_messageKeys` pruning not done). Numbers below are from when it was applied. | S4 sorter calls on reaction-popup open (2000 msgs) | 15,481 | 0 | keep |
|   |     | S4 long press + settle (host test, median of 3, noisy) | 182,035us | 155,199us | within noise |
|   |     | Device (SM-G781B, profile, 8 popup opens): frames over 16.7ms | 17 of 98 | 2 of 105 | keep |
|   |     | Device: build p99 / frame total p90 | 26.1ms / 25.0ms | 12.5ms / 11.0ms | keep |
| 4 | Swipe-to-see-time slide follows the finger (`value -= dx / 120`, linear) instead of `forward()` per drag update; slide is a fixed 120pt, snap-back is 200ms with `messageTimeAnimationCurve` | Device (SM-G781B, profile, 10 swipes at ~10px/frame): first visible movement | ~60ms | ~45ms | keep |
|   |     | Device: bubble at full 120pt after 16 frames of 10px (the old 0.2-of-row slide reached 91-93% of its distance after ~230ms) | not reached | 10 of 10 swipes (~320ms, finger-paced) | keep |
|   |     | Device: frames over 16.7ms / build p50 / raster p50 | 1 of 271 / 0.55ms / 2.9ms | 1 of 351 / 0.37ms / 3.2ms | no cost |
| 5 | Time label fades in with the swipe (`Opacity` = slide / 120pt) instead of appearing at full opacity on the first pixel | Device (SM-G781B, profile, 10 swipes): label opacity after ~60px of finger travel | 1.0 (instant) | 0.42 | keep |
|   |     | Device: label opacity at full reveal | 1.0 | 1.0 (10 of 10) | unchanged |
|   |     | Device: frames over 16.7ms / build p50 / raster p50 | 1 of 351 / 0.37ms / 3.2ms | 1 of 351 / 0.39ms / 3.3ms | no cost |

## How the device numbers were taken

- Tests: `example/integration_test/swipe_perf_test.dart` and `popup_perf_test.dart`, driven by `example/test_driver/integration_test.dart`.
- Command (profile mode, one device):
  `cd example && flutter drive --profile -d <device> --driver=test_driver/integration_test.dart --target=integration_test/swipe_perf_test.dart`
- Swipe-to-reply is turned off in the swipe test, otherwise a bubble's own drag wins the gesture and the list-level swipe never fires.
- Baselines were taken by stashing the change (swipe) or forcing the cache to recompute (popup), one run each. Frame-count differences of 1-3 janky frames are noise; the popup 17 -> 2 difference is not.
- Scripted drags are not a real finger. Not yet checked by hand on the device.
