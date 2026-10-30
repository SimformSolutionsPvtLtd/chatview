# ChatView 4.0.0 Major Release Plan

**Coordinated release:** `chatview_utils` 4.0.0, for the `ChatController` changes in task 3.4.

> This is a roadmap. Each phase gets its own step-by-step plan, with tests first, when work on it starts.

---

## Phase 0 — Foundation (before any refactor)

| # | Task | Do | Outcome | Without it |
|---|---|---|---|---|
| 0.1 | Toolchain upgrade | Set CI to 3.47.8. Set the floors above in the package and the example. Run `dart fix --apply`. Check that every plugin dependency works with Swift Package Manager, which is the iOS/macOS default since 3.44. | One known toolchain, with access to Dart 3.13 features. | The declared floor `>=3.4.0` is already wrong: `image_picker` 1.2.2 needs Dart 3.9 and Flutter 3.35. Users on older SDKs get resolution errors. |
| 0.3 | Strict analysis | Turn on `strict-casts`, `strict-inference` and `strict-raw-types`. Add the lints `unawaited_futures`, `avoid_catches_without_on_clauses`, `prefer_final_locals`, `always_declare_return_types` and `public_member_api_docs`. | The analyzer catches async and typing bugs. | Bugs like the un-awaited recursive `_onReplyTap` keep shipping. |
| 0.5 | Performance baseline | Write a profile-mode `integration_test` in the example covering 5,000 messages: scroll, keyboard open/close, typing 500 characters, swipe-to-see-time, and an image-heavy chat. Record frame times (p90/p99), rebuild counts and memory. | Numbers to compare against after each phase. | Performance gains can't be proven, and regressions go unnoticed. |

---

## Phase 1 — Critical bug fixes (non-breaking, backport as 3.2.0)

**Status as of 2026-10-30** (checked against branch `perf/01-swipe-rebuild`; numbers are in `perf/baseline.md` and `perf/results.md`):

| # | Status | Evidence / what is left |
|---|---|---|
| 1.1 | Pending | `showPopUp`, `chatTextFieldHeight` and `reactionPopupKey` are still created in `ChatViewInheritedWidget` ([chat_view_inherited_widget.dart:45-47](lib/src/inherited_widgets/chat_view_inherited_widget.dart)). |
| 1.2 | Fixed | `0a02d50`. Listener registered once, `RecorderController` disposed. S3: `addListener` calls over 30 keystrokes 30 → 0. The recorder dispose is not tested (it only exists on iOS and Android). |
| 1.3 | Fixed | `9ec81d9`. Created once via a guard in `_initializeAnimation`, called from `didChangeDependencies`, not `initState`, because the curve comes from the inherited config. No test counts controllers. |
| 1.4 | Partly fixed | `9ec81d9`: a swipe drag no longer rebuilds or re-sorts the list. S2: sorter calls 557,316 → 0, pump p50 18.4ms → 0.8ms. Set aside in `git stash` ("perf: cache sorted list + separators per stream emission (S4)"), not applied: (a) sorted list and separators cached per stream emission (`_cachedSnapshot` in `chat_groupedlist_widget.dart`); S4 sorter calls on popup open 15,481 → 0, and on a Samsung SM-G781B in profile mode frames over 16.7ms across 8 popup opens 17 of 98 → 2 of 105. `test/perf/list_rebuild_test.dart` (S4) fails until it is applied. Uncommitted on this branch: (b) the swipe-to-see-time slide now follows the finger 1:1 over a fixed 120pt (`timeRevealDistance` in `utils/constants/constants.dart`, measured from an Instagram DM recording) with a linear drag and a 200ms curved snap-back, instead of `forward()` per drag frame and 0.2 of the row width; on the SM-G781B in profile mode 1 of 351 frames over 16.7ms, build p50 0.37ms, no frame-time cost. The time label now fades in with the swipe (opacity = slide / 120pt, fully opaque at the full reveal) instead of popping in at the first pixel; on the SM-G781B opacity was 0.42 about halfway and 1.0 at full reveal in 10 of 10 swipes. Not yet copied from the recording: the plain, right-fixed label styling (still the arrow-in-circle `MessageTimeWidget`). Still open: the cache above is not applied; `_messageKeys` is never pruned; the cache is keyed on the stream snapshot, so list edits that bypass the controller show up only on the next emission; popup-open build p99 is still ~12ms (visible bubbles rebuild). |
| 1.5 | Mostly fixed | `mounted` guards after the reply-jump fetch, scroll and highlight timer; the recursion is awaited; a missing target is reported through the new `RepliedMessageConfiguration.onReplyTargetNotFound(String id)` instead of thrown. Covered by `test/bugs/async_safety_test.dart` (3 bug tests plus a control). Still open: the `whenComplete` write in `voice_message_view.dart` has no `mounted` guard and no test. |
| 1.6 | Pending | Not started. Spot checks: `setLocaleMessages` is still called in `chat_view.dart:206`, `snapshot.data!` is still used in `chat_groupedlist_widget.dart`, and `_messageKeys` is never pruned. The scroll listener, image-picker errors and default text colour were not re-checked. |
| 1.7 | Pending | The global `HardwareKeyboard` handler is still attached on web ([chatui_textfield.dart:132-134](lib/src/widgets/message_input/chatui_textfield.dart)). |

| # | Task | Do | Outcome | Without it |
|---|---|---|---|---|
| 1.1 | Inherited widget state reset | Move `showPopUp`, `chatTextFieldHeight` and `reactionPopupKey` out of `ChatViewInheritedWidget` into `_ChatViewState`, and dispose them there. | Popup state and list padding survive host rebuilds and fold/unfold. | Every host rebuild silently resets them and leaks the old notifiers. The cleanup in `dispose` can never reach them. |
| 1.2 | Text field listener leak | Register `_onChanged` once ([chatui_textfield.dart:523](../../../lib/src/widgets/chatui_textfield.dart)). Dispose `RecorderController`. | Typing cost stays constant. The microphone recorder is released. | Each keystroke adds a listener, so typing slows as the text grows, and the recorder leaks. |
| 1.3 | AnimationController leak | Create the controller once in `initState`, not in `didChangeDependencies` ([chat_groupedlist_widget.dart:148](../../../lib/src/widgets/chat_groupedlist_widget.dart)). | One controller per list. | With swipe-to-see-time on, every ChatView rebuild leaks a controller and can trigger debug ticker assertions. |
| 1.4 | Drag-frame recomputation | Animate only the `SlideTransition`. Sort messages and build separators once per message change, not per frame. | Smooth swipe in long chats. | Each drag frame re-sorts the whole list (O(n)), which janks long chats. |
| 1.5 | Async safety | Add `mounted` guards after `Future.delayed`, `whenComplete` and `preparePlayer`. Await the reply-jump recursion. Report its errors through a callback instead of throwing. | No use-after-dispose errors and no unhandled exceptions. | "Used after disposed" errors and uncaught exceptions when jumping to a replied message. |
| 1.6 | Smaller lifecycle fixes | Stop calling `scrollToLastMessage()` and `setLocaleMessages` from build/initState. Add the scroll listener only once (`chat_list.dart`). Remove `snapshot.data!`. Prune `_messageKeys` when messages are removed. Surface image-picker errors. Make the default text field text visible (it is white on a white fill today). | Predictable lifecycle and visible default text. | Hidden scroll jumps, duplicate listeners, unbounded `GlobalKey` growth, swallowed permission errors, and invisible text when the app sets no style. |
| 1.7 | Scope Enter-to-send | Replace the global `HardwareKeyboard` handler with `Focus.onKeyEvent` or `CallbackShortcuts` on the text field. Enable it on desktop as well as web. | Enter sends only when the chat field has focus. | On web, pressing Enter in *any* host-app text field sends the chat message and swallows the key. |

---

## Phase 2 — Structure and naming (mechanical, no behavior change)

| # | Task | Do | Outcome | Without it |
|---|---|---|---|---|
| 2.1 | Feature-first folders | `git mv` into `chat_view/{message_list, message_types, composer, reactions, suggestions, type_indicator, app_bar, config}`, `chat_list/` and `core/`. Land it as one PR with no logic changes. | Each feature lives in one place. | Each feature is spread across `widgets/`, `models/`, `values/` and `typedefs.dart`, so onboarding and reviews are slow. |
| 2.2 | Split oversized files | Split `extensions.dart` (about 20 extensions) and `typedefs.dart` (57 typedefs) per feature. Give constants meaningful names (`bottomPadding1/2/3`, `heart`). | Small files with one purpose each. | 500-line grab-bag files and constants with unclear meaning. |
| 2.3 | Internal renames | Rename `ChatListWidget` to `MessageList` (it isn't the chat list) and `ChatGroupedListWidget` to `MessageListView`. Fix file names (`chatui_textfield` to `chat_ui_text_field`, and similar). Drop the `get` prefix on getters. Use one `BuildContext` extension. Use relative imports throughout `lib/src`, and never import `package:chatview/chatview.dart` from inside `src`. | Names say what the code is, and there are no circular imports through the barrel. | Readers confuse the message list with the conversation list, and imports are mixed (212 relative, 14 `package:`). |
| 2.4 | Public renames (breaking, aliased) | Apply D1. Rename `…CallBack` to `…Callback`. Keep the old names as `@Deprecated` typedefs. Ship `lib/fix_data.yaml` so `dart fix --apply` migrates user code. | A consistent API that users can migrate automatically. | Users keep guessing between `Config`/`Configuration` and `CallBack`/`Callback`. |

---

## Phase 3 — Architecture

| # | Task | Do | Outcome | Without it |
|---|---|---|---|---|
| 3.1 | `ChatViewScope` | Create a `StatefulWidget` scope that owns runtime state, with `ChatViewScope.of` and `maybeOf` (like `Theme.of`). Remove the 55 `chatViewIW` lookups and their `!`. | One owner for state, with clear error messages. | Duplicated lookups in 7 widgets, and `!` crashes when a widget is used outside ChatView. |
| 3.2 | Configs as values | Add `==`, `hashCode` and `copyWith` to all config classes, written by hand with no new dependency. Split `ConfigurationsInheritedWidget` into an `InheritedModel` with one aspect per config section. | A bubble rebuilds only when its own config changes, and users can tweak configs with `copyWith`. | `updateShouldNotify` is identity-based, so every ChatView rebuild rebuilds every visible bubble. |
| 3.3 | Composer controller | Add a `ChatComposerController` (`ChangeNotifier`) that owns reply, edit and selected images. Remove the 3 `GlobalKey`s used to poke child states. Make `SendMessageWidgetState`, `EditMessageViewState` and the others private. Replace `ChatView.getReplyMessage` and `closeReplyMessageView` with controller methods. | A smaller public API and testable composer logic. | Parent widgets mutate child state through public State classes, so every internal change is breaking. |
| 3.4 | Synchronous message source | In `chatview_utils` 4.0.0, expose `ValueListenable<List<Message>>` on `ChatController` and keep the stream as deprecated. Render the list from it. | Messages appear on the first frame. The `StreamController` is no longer public. | A loader flashes on the first frame, `snapshot.data!` can crash, and the internal stream stays exposed. |
| 3.5 | Break up large builds | Split `ChatView.build` (about 150 lines), `ChatUITextField.build` (about 195) and the `_chatStreamBuilder` getter (about 175) into widget classes. Precompute list items (order, separators, group flags) once per change. Add `findChildIndexCallback`. | Smaller rebuild scopes, and bubble state stays tied to its message when new messages are inserted. | Whole subtrees rebuild together, and items can be matched to the wrong state on insert. |
| 3.6 | Layout without measuring | Replace the composer-height measurement (`GlobalKey` size plus post-frame callback) with layout (`Column`/`Expanded` or `CustomMultiChildLayout`). Keep the visuals identical, checked with goldens. | No one-frame jump when the composer grows. | List padding lags the composer by a frame, and extra rebuilds run on every resize. |

---

## Phase 4 — Modern Flutter and platform APIs

| # | Task | Do | Outcome | Without it |
|---|---|---|---|---|
| 4.1 | Precise MediaQuery reads | Change `MediaQuery.of(context).size` (11 places) to `sizeOf`, `paddingOf` or `viewInsetsOf`, or to parent constraints (see 5.1). | No rebuilds on unrelated MediaQuery changes. | Every keyboard-animation frame rebuilds those widgets. |
| 4.2 | Platform checks and Wasm | Remove `dart:io`, `Platform` and the invalid `if (kIsWeb) 'dart:html'` import. Use `defaultTargetPlatform`. Move file deletion behind a conditional import. Check with `pana`. | A Wasm-ready web build and correct pub.dev platform tags. | The `dart:html` reference can block Wasm, and web relies on `dart:io` stubs. |
| 4.3 | Overlays and menus | Move `overlay_action_button` from a manual `OverlayEntry` to `OverlayPortal` with `overlayChildLayoutBuilder`, which 3.47 recommends. Evaluate `MenuAnchor` for the chat-list context menu. | The overlay lifecycle follows the widget. | Manual insert/remove leaks if the widget is disposed while open. Since 3.41, removing an entry twice asserts. |
| 4.4 | Animation APIs | Replace `Opacity` inside animations with `FadeTransition`. Evaluate `RepeatingAnimationBuilder` (3.41) for the 5 controllers in the typing indicator. | Cheaper animations and less code. | Extra layers, and manually managed controllers. |
| 4.5 | Dart 3.13 syntax | Apply dot shorthands, wildcards, switch expressions and primary constructors through the `dart-modernization` skill and `dart fix`. Do this after Phase 3 so it doesn't conflict. | Much less boilerplate across 50+ config classes. | Verbose but working code. This task is quality-only. |
| 4.6 | Image decoding | Set `cacheWidth`/`memCacheWidth` to the display size for file, memory and network images. Switch the 3 uncached `NetworkImage`/`Image.network` uses to `CachedNetworkImageProvider`. | Lower memory in image-heavy chats. | Camera photos decode at full resolution in the list, and some images are re-downloaded. |

---


## Phase 6 — Design system, accessibility, localization

| # | Task | Do | Outcome | Without it |
|---|---|---|---|---|
| 6.1 | `material_ui`/`cupertino_ui` migration | **Spike first:** confirm that types like `ButtonStyle` and `InputBorder` work for apps still on SDK Material. Then run `dart fix --apply --code=migrate_design_widgets` across the 102 Material and 5 Cupertino files and add `material_ui: ^1.8.0` and `cupertino_ui: ^1.1.4`. Document `MaterialUiCompatibilityBridge` for apps. | No warnings when Flutter deprecates the bundled Material (planned for the next stable). | Every user sees deprecation warnings, and a later removal of bundled Material breaks the package. |
| 6.2 | Theme-aware defaults | Add `ChatViewTheme extends ThemeExtension<ChatViewTheme>` with light and dark defaults derived from `ColorScheme`. Replace the roughly 100 hardcoded `Colors.*`. | Dark mode works out of the box, and styling lives in one place. | Apps must set dozens of colors by hand, and dark mode is broken by default. |
| 6.3 | Accessibility | Add `Semantics` to bubbles (sender, time, status), to the send, mic and camera buttons, and to reactions. Use 48×48 tap targets. Respect text scaling. Test with `isSemantics` matchers. | ChatView is usable with TalkBack and VoiceOver. | There are 0 `Semantics` today, so screen readers announce bare icons. |
| 6.4 | Localization gaps | Move `couldNotLaunch` and `couldNotLoadImage` into `ChatViewLocale`. Follow `Localizations.localeOf(context)` when the app hasn't set a locale. | Every visible string is translatable. | Some English strings always show, and the locale is a static global. |

---

## Phase 7 — Public API and release

| # | Task | Do | Outcome | Without it |
|---|---|---|---|---|
| 7.2 | Docs and migration | Write `MIGRATION_4.md` (every break, its `dart fix` coverage, and the remaining manual steps). Update the CHANGELOG, README, `doc/documentation.md` and the example. | Users can upgrade in an afternoon. | Upgrade friction, and many support issues. |
| 7.4 | Final verification | Rerun the 0.5 benchmark and compare with the baseline. Run the full test matrix on all 6 platforms plus foldable emulators. | Measured, documented gains. | Unverified release claims. |

---

## Phase 5 — Foldable and large-screen support (PRIORITY LOW)

On Android 17 (API 37), apps can no longer lock orientation or resizability on screens 600dp and wider ([Flutter notice](https://docs.flutter.dev/release/breaking-changes/android-large-screens-restrictions-ignored)). Every app using chatview will be resized, whether it is ready or not.

| # | Task | Do | Outcome | Without it |
|---|---|---|---|---|
| 5.1 | Size from the parent, not the screen | Replace the 14 full-screen size reads with ChatView's own constraints (`LayoutBuilder`). The main ones: [chat_view.dart:242-244](../../../lib/src/widgets/chat_view.dart) forces full-screen size; bubble max width, the reaction and reply popups, link preview, the reactions sheet, the send widget and the voice waveform all use the screen. | ChatView works inside a pane (list-detail on an unfolded phone, tablet or desktop). | In a split view, ChatView sizes itself to the whole screen, so content overflows and popups land in the wrong place. |
| 5.2 | Readable width on wide screens | Cap bubble width at 75% of ChatView's width, up to a configurable `maxBubbleWidth`. | Comfortable line lengths when unfolded. | Bubbles stretch across an unfolded screen into very long lines. |
| 5.3 | Reflow on fold/unfold | Recompute waveform samples when the width changes (the waveform reads width only once in `initState`). Close or reposition open popups when metrics change. Keep the draft, reply/edit, an active recording and the scroll position. This depends on 1.1. | Folding mid-chat loses nothing. | The waveform keeps its old width, popups float at stale positions, and state resets. |
| 5.4 | Avoid the hinge | Read `MediaQuery.displayFeaturesOf`. Pass `anchorPoint` to the `showModalBottomSheet` calls (emoji picker, reactions). Wrap the reaction popup and overlay menu in `DisplayFeatureSubScreen`. | No UI is split across the fold in the half-opened posture. | Sheets and popups render across the hinge, where they can't be read or tapped. |
| 5.5 | Tabletop layout (optional, see D3) | When a horizontal fold is `DisplayFeatureState.postureHalfOpened`, show messages on the top half and the composer on the bottom half. Make it opt-in. | A native-feeling tabletop mode. | The standard layout is used, which still works after 5.1–5.4. |
| 5.6 | Example list-detail layout | In the example app, show ChatList and ChatView side by side at 840dp and wider or across a vertical hinge (Material size classes: compact under 600, medium 600–839, expanded 840 and up). Don't lock orientation. | A reference implementation and a manual QA target. | Users find foldable issues on their own. |
| 5.7 | Foldable test matrix | Widget tests at compact, medium and expanded widths, with vertical and horizontal hinges faked through `tester.view.displayFeatures`. Resize mid-test with `tester.view.physicalSize`. Do manual QA on Android Studio foldable and resizable emulators, and on a real Fold if one is available. | Foldable behavior is locked in by tests. | Fold regressions return unnoticed. |

