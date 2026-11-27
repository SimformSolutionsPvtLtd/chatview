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

import '../../models/config_models/mention_configuration.dart';

/// Exposes the [MentionConfiguration] to the whole chat subtree so that both
/// the compose text field and the message bubbles share a single source of
/// truth for mention styling and behaviour.
class MentionConfigIW extends InheritedWidget {
  const MentionConfigIW({
    super.key,
    required super.child,
    this.mentionConfig,
  });

  /// The configuration for the `@`-mention feature, or `null` when not
  /// provided by the host app.
  final MentionConfiguration? mentionConfig;

  static MentionConfigIW? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MentionConfigIW>();

  @override
  bool updateShouldNotify(covariant MentionConfigIW oldWidget) =>
      oldWidget.mentionConfig != mentionConfig;
}
