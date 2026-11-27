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

import 'package:flutter/material.dart';

import '../../values/typedefs.dart';

/// Configuration for the `@`-mention (tagging) feature.
///
/// Pass a single instance to `ChatView(mentionConfig: ...)`. It controls both
/// sides of the feature:
///
/// * **Compose** — the suggestion dropdown shown when the user types the
///   [triggerCharacter], and how the in-progress mention is highlighted inside
///   the text field.
/// * **Render** — how a confirmed mention is highlighted (and optionally
///   tapped) inside a sent message bubble.
///
/// The feature must also be enabled via
/// `FeatureActiveConfig(enableMention: true)`.
class MentionConfiguration {
  const MentionConfiguration({
    this.triggerCharacter = '@',
    this.mentionTextStyle,
    this.outgoingMentionTextStyle,
    this.incomingMentionTextStyle,
    this.composeMentionTextStyle,
    this.showEveryone = true,
    this.everyoneTitle,
    this.everyoneId = 'everyone',
    this.excludeCurrentUser = true,
    this.onMentionTap,
    this.onMentionsChanged,
    this.listConfig = const MentionListConfig(),
  });

  /// Character that opens the mention suggestion list. Defaults to `@`.
  ///
  /// Must be a single character and is also used as the prefix of the encoded
  /// mention token, so changing it changes the persisted format.
  final String triggerCharacter;

  /// Base style applied to a confirmed mention inside a sent message bubble
  /// and (unless [composeMentionTextStyle] is set) in the text field.
  ///
  /// Used as the fallback for both bubble directions when
  /// [outgoingMentionTextStyle] / [incomingMentionTextStyle] are not provided.
  ///
  /// When `null`, [defaultMentionTextStyle] (blue + bold) is used. For a
  /// dark/colored outgoing bubble, override [outgoingMentionTextStyle] with a
  /// contrasting color.
  final TextStyle? mentionTextStyle;

  /// Mention style for the current user's (outgoing) bubbles, which usually
  /// have a colored background. Falls back to [mentionTextStyle].
  ///
  /// Use this to pick a color with good contrast against the outgoing bubble
  /// (e.g. a light color on a dark/branded bubble).
  final TextStyle? outgoingMentionTextStyle;

  /// Mention style for other users' (incoming) bubbles. Falls back to
  /// [mentionTextStyle].
  final TextStyle? incomingMentionTextStyle;

  /// Style applied to a mention while it is being composed inside the text
  /// field. Falls back to [mentionTextStyle] when `null`.
  final TextStyle? composeMentionTextStyle;

  /// Whether to prepend the special "everyone" entry to the suggestion list.
  final bool showEveryone;

  /// Label for the everyone entry, e.g. `everyone`. When `null`, the
  /// locale-resolved value from `PackageStrings.currentLocale.everyone`
  /// is used.
  final String? everyoneTitle;

  /// Stable id persisted for the everyone mention. Defaults to `everyone`.
  ///
  /// Use this to distinguish the everyone target in [onMentionTap] or in a
  /// sent message's `Message.mentions` (`mention.isEveryone` is also
  /// available).
  final String everyoneId;

  /// Whether to exclude the current user from the suggestion list.
  /// Defaults to `true` (you usually do not tag yourself).
  final bool excludeCurrentUser;

  /// Called when a highlighted mention is tapped inside a message bubble.
  final MentionTapCallback? onMentionTap;

  /// Called whenever the set of mentions in the text field changes while the
  /// user composes a message.
  ///
  /// For the mentions of a *sent* message, read `Message.mentions` from the
  /// message delivered to `ChatView.onSendMessage` instead.
  final MentionsCallback? onMentionsChanged;

  /// Appearance configuration for the suggestion dropdown.
  final MentionListConfig listConfig;

  /// Resolves the effective base bubble mention style, applying
  /// [defaultMentionTextStyle] when none is provided.
  TextStyle get effectiveMentionTextStyle =>
      mentionTextStyle ?? defaultMentionTextStyle;

  /// Resolves the bubble mention style for the given bubble direction, falling
  /// back to [effectiveMentionTextStyle].
  TextStyle mentionTextStyleFor({required bool isMessageBySender}) =>
      (isMessageBySender
          ? outgoingMentionTextStyle
          : incomingMentionTextStyle) ??
      effectiveMentionTextStyle;

  /// Resolves the effective compose (text field) mention style.
  TextStyle get effectiveComposeMentionTextStyle =>
      composeMentionTextStyle ?? effectiveMentionTextStyle;

  /// Default mention style: blue and bold.
  ///
  /// This reads well in the text field and on light (incoming) bubbles. On a
  /// dark/colored (outgoing) bubble, set [outgoingMentionTextStyle] to a color
  /// that contrasts with that bubble (e.g. white).
  static const TextStyle defaultMentionTextStyle = TextStyle(
    color: Color(0xFF1565C0),
    fontWeight: FontWeight.bold,
  );

  MentionConfiguration copyWith({
    String? triggerCharacter,
    TextStyle? mentionTextStyle,
    TextStyle? outgoingMentionTextStyle,
    TextStyle? incomingMentionTextStyle,
    TextStyle? composeMentionTextStyle,
    bool? showEveryone,
    String? everyoneTitle,
    String? everyoneId,
    bool? excludeCurrentUser,
    MentionTapCallback? onMentionTap,
    MentionsCallback? onMentionsChanged,
    MentionListConfig? listConfig,
  }) {
    return MentionConfiguration(
      triggerCharacter: triggerCharacter ?? this.triggerCharacter,
      mentionTextStyle: mentionTextStyle ?? this.mentionTextStyle,
      outgoingMentionTextStyle:
          outgoingMentionTextStyle ?? this.outgoingMentionTextStyle,
      incomingMentionTextStyle:
          incomingMentionTextStyle ?? this.incomingMentionTextStyle,
      composeMentionTextStyle:
          composeMentionTextStyle ?? this.composeMentionTextStyle,
      showEveryone: showEveryone ?? this.showEveryone,
      everyoneTitle: everyoneTitle ?? this.everyoneTitle,
      everyoneId: everyoneId ?? this.everyoneId,
      excludeCurrentUser: excludeCurrentUser ?? this.excludeCurrentUser,
      onMentionTap: onMentionTap ?? this.onMentionTap,
      onMentionsChanged: onMentionsChanged ?? this.onMentionsChanged,
      listConfig: listConfig ?? this.listConfig,
    );
  }
}

/// Appearance and behaviour of the mention suggestion dropdown shown above the
/// text field.
class MentionListConfig {
  const MentionListConfig({
    this.maxHeight = 250,
    this.backgroundColor,
    this.decoration,
    this.padding,
    this.margin,
    this.elevation = 4,
    this.borderRadius,
    this.itemTextStyle,
    this.showAvatar = true,
    this.avatarRadius = 18,
    this.everyoneAvatar,
    this.itemBuilder,
    this.emptyBuilder,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  /// Maximum height of the dropdown before it becomes scrollable.
  final double maxHeight;

  /// Background color of the dropdown. Ignored when [decoration] is provided.
  final Color? backgroundColor;

  /// Full decoration override for the dropdown container. Takes precedence
  /// over [backgroundColor], [borderRadius] and [elevation].
  final BoxDecoration? decoration;

  /// Inner padding of the dropdown list.
  final EdgeInsets? padding;

  /// Outer margin around the dropdown.
  final EdgeInsets? margin;

  /// Material elevation when [decoration] is not provided.
  final double elevation;

  /// Corner radius when [decoration] is not provided.
  final BorderRadius? borderRadius;

  /// Text style for a member's name in the default item layout.
  final TextStyle? itemTextStyle;

  /// Whether to show member avatars in the default item layout.
  final bool showAvatar;

  /// Radius of the member avatar in the default item layout.
  final double avatarRadius;

  /// Custom leading widget for the everyone entry. Defaults to a group icon.
  final Widget? everyoneAvatar;

  /// Fully custom builder for a suggestion row. When provided it replaces the
  /// default avatar + name layout. Tapping the returned widget still selects
  /// the mention (it is wrapped in an [InkWell]).
  final MentionListItemBuilder? itemBuilder;

  /// Builder shown when the list has no matches for the current query. When
  /// `null`, the dropdown is simply hidden if there are no matches.
  final WidgetBuilder? emptyBuilder;

  /// Open/close animation duration of the dropdown.
  final Duration animationDuration;
}
