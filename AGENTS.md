# ChatView: maintainer guide for coding agents

These instructions are for working **on** the `chatview` package. Guidance for
apps that **use** it ships in the package's `skills/` directory.

## Layout

| Path | Owns |
|---|---|
| `lib/chatview.dart` | Public library: exports `src/` and re-exports `chatview_utils`, `audio_waveforms` (recorder/player settings) and `emoji_picker_flutter` |
| `lib/src/widgets/` | `ChatView` (chat screen), `ChatList` (`chat_list/`), bubbles, text field, action buttons |
| `lib/src/models/config_models/` | `*Configuration` / `*Config` classes passed to `ChatView` and `ChatList` |
| `lib/src/values/` | Enums and typedefs (`enumeration.dart`, `typedefs.dart`) |
| `example/` | Example app (also deployed as the web demo) |
| `doc/documentation.md` | Full documentation, published on the documentation site |
| `skills/` | Agent skills shipped to users (see below) |

Core models and controllers (`Message`, `ChatUser`, `ChatController`,
`ChatListController`, `ReplyMessage`, `MessageType`, …) live in the separate
[`chatview_utils`](https://github.com/SimformSolutionsPvtLtd/chatview_utils)
package, which `chatview` pins to an exact version and re-exports. Change them
there, then bump the pin here.

## Keep these in sync with any change

When a public API, configuration field, default or behavior changes, update in
the same PR:

1. `doc/documentation.md` (and `README.md` if it is affected).
2. `CHANGELOG.md` under `## [Unreleased]`, format
   `* **Feat**: [#](PR link) …`, `* **Fix**: …`, `* **Breaking**: …`.
   Breaking changes also need a "Migration Guide" entry in
   `doc/documentation.md`.
3. `example/`.
4. **`skills/`** (see below). Skills ship to users with the package, so a stale
   skill makes their coding agents write broken code. A breaking change must
   also be added to the `chatview-migration` skill.

## Package skills (`skills/`)

The package publishes agent skills following
[Dart package skills](https://dart.dev/tools/pub/package-skills). Users install
them with `dart run skills@ get`.

| Skill | User task |
|---|---|
| `chatview-chat-screen` | Build and customize a chat screen with `ChatView` + `ChatController` |
| `chatview-chat-list` | Build and customize the conversation list with `ChatList` + `ChatListController` |
| `chatview-migration` | Upgrade an app from its current `chatview` version to the latest |

Rules:

- One skill per user task, not per class. Add a new skill only for a new task,
  otherwise extend the existing one.
- Directory name = frontmatter `name` = `chatview-<topic>`. Lowercase, digits
  and single hyphens only; the `skills` CLI silently skips names without the
  `chatview-` prefix.
- Frontmatter: `name` and `description` only. The description says what the
  skill does and when to use it (max 1024 characters).
- Keep `SKILL.md` under 500 lines. Move long tables to `references/` and link
  them with a relative path from the skill root (`references/x.md`).
- Write rules an agent can follow, and complete Dart examples that compile.
  State behavior verified in `lib/` (and `chatview_utils`), not what the docs
  claim.
- `chatview-migration`: every `**Breaking**` CHANGELOG entry gets a
  before/after entry in the reference file for its release, verified against
  the code at the release tags. Changes not yet released go under the
  "From < next release" heading of `references/3.0-to-latest.md`; when
  releasing, rename it to `From < X.Y.Z`, and update the skills' documented
  versions (for example the version index in `SKILL.md`).
- `skills/` must not be excluded by `.gitignore` or a `.pubignore`.

Validate with [`skills_lint`](https://pub.dev/packages/skills_lint). It needs
Dart SDK ^3.12, newer than this package's minimum, so do **not** add it as a
dev dependency; install it globally instead:

```bash
dart pub global activate skills_lint
```

Run from the repository root:

```bash
dart pub global run skills_lint --ignore-config -d skills --check-relative-paths --check-relative-paths-within-skill=true --published-skill-name --published-skill-name-pubspec_path=pubspec.yaml --pub-archive-includes-skill --check-trailing-whitespace --disallowed-field
```

To test an install, create a throwaway Flutter app, add `chatview` with a
`path:` dependency, run `dart run skills@ get --all --agent claude`, and check
`.claude/skills/`. Only **direct** dependencies are scanned. Compile the
skills' Dart examples there with `flutter analyze`.

## Verifying changes

Run what CI runs (`.github/workflows/flutter.yaml`) before opening a PR:

```bash
flutter pub get
dart analyze
dart format --set-exit-if-changed .
flutter pub publish --dry-run
```

For widget changes, also run `example/` and check the affected screens.

## Pull requests

Branch from `main` and follow `.github/pull_request_template.md`: a
Conventional Commit title (`feat:`, `fix:`, `docs:`; add `!` for breaking
changes), and migration instructions for breaking changes.
