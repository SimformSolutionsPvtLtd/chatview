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

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../values/enumeration.dart';
import 'suggestion_list_config.dart';

/// Configuration for reply suggestions in a chat view.
class ReplySuggestionsConfig {
  const ReplySuggestionsConfig({
    this.listConfig,
    this.itemConfig,
    this.onTap,
    this.autoDismissOnSelection = true,
    this.suggestionItemType = SuggestionItemsType.scrollable,
    this.spaceBetweenSuggestionItemRow = 10,
  });

  /// Used to give configuration for suggestion item.
  final SuggestionItemConfig? itemConfig;

  /// Used to give configuration for suggestion list.
  final SuggestionListConfig? listConfig;

  /// Provides callback when user taps on suggestion item.
  final ValueSetter<SuggestionItemData>? onTap;

  /// If true, the suggestion popup will be dismissed automatically when a suggestion is selected.
  final bool autoDismissOnSelection;

  /// Defines the type of suggestion items, whether they are scrollable or not.
  final SuggestionItemsType suggestionItemType;

  /// Defines the space between each row of suggestion items.
  final double spaceBetweenSuggestionItemRow;
}
