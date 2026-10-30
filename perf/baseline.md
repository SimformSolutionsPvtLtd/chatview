# Perf baseline (branch perf/01-swipe-rebuild, lib/ unmodified)

Harness: `flutter test test/perf/swipe_rebuild_test.dart` - 2000 text messages,
~100 date separators, sortEnable on, swipe-to-see-time on, 30 drag frames +
release. Host: macOS, JIT test runner: timings are relative only, counts exact.

## S2 - horizontal swipe drag

| Run    | sorter calls (drag+release) | pump p50 | pump p90 | pump max |
|--------|-----------------------------|----------|----------|----------|
| 1      | 557,316                     | 18,436us | 37,207us | 45,063us |
| 2      | 557,316                     | 19,783us | 31,636us | 42,686us |
| 3      | 557,316                     | 18,337us | 31,088us | 42,385us |
| median | 557,316                     | 18,436us | 31,636us | 42,686us |

## S4 - reaction popup open (no message change)

`flutter test test/perf/list_rebuild_test.dart` - 2000 text messages, ~100 date
separators, sortEnable on, inline messageSorter. Long press a bubble, then
pumpAndSettle. The stopwatch spans the whole gesture (long-press animation and
popup build included), so it is not the cost of the sort alone.

| Run    | sorter calls | long press + settle |
|--------|--------------|---------------------|
| 1      | 15,481       | 193,786us           |
| 2      | 15,481       | 139,774us           |
| 3      | 15,481       | 142,582us           |
| median | 15,481       | 142,582us           |

15,481 is one full sort of the 2000 messages, so opening the popup re-sorts the
list once.

Not yet measured: S1 (fling), S5-S8.
