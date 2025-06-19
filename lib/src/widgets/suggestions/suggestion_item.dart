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

import '../../extensions/extensions.dart';
import '../../models/config_models/reply_suggestions_config.dart';

class SuggestionItem extends StatelessWidget {
  const SuggestionItem({
    super.key,
    required this.suggestionItemData,
  });

  final SuggestionItemData suggestionItemData;

  @override
  Widget build(BuildContext context) {
    final suggestionsConfig =
        context.suggestionsConfig ?? const ReplySuggestionsConfig();
    final suggestionsListConfig = suggestionsConfig.itemConfig;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        suggestionsConfig.onTap?.call(suggestionItemData);
        if (suggestionsConfig.autoDismissOnSelection) {
          context.chatViewIW?.chatController.removeReplySuggestions();
        }
      },
      child: Container(
        padding: suggestionItemData.config?.padding ??
            suggestionsListConfig?.padding ??
            const EdgeInsets.all(6),
        decoration: suggestionItemData.config?.decoration ??
            suggestionsListConfig?.decoration ??
            BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                color: theme.primaryColor,
              ),
            ),
        child: Text(
          suggestionItemData.text,
          style: suggestionItemData.config?.textStyle ??
              suggestionsListConfig?.textStyle,
        ),
      ),
    );
  }
}
