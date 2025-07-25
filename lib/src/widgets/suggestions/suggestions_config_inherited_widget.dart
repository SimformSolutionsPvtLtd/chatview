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

import '../../models/config_models/reply_suggestions_config.dart';

/// This widget for alternative of excessive amount of passing arguments
/// over widgets.
class SuggestionsConfigIW extends InheritedWidget {
  const SuggestionsConfigIW({
    super.key,
    required super.child,
    this.suggestionsConfig,
  });

  /// The [suggestionsConfig] is used to provide the configuration for suggestion reply
  final ReplySuggestionsConfig? suggestionsConfig;

  /// This is used to access the [suggestionsConfig] from the widget tree.
  static SuggestionsConfigIW? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SuggestionsConfigIW>();

  @override
  bool updateShouldNotify(covariant SuggestionsConfigIW oldWidget) => false;
}
