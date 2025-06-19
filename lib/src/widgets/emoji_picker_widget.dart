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
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class EmojiPickerWidget extends StatelessWidget {
  const EmojiPickerWidget({
    Key? key,
    required this.onSelected,
    this.emojiPickerSheetConfig,
  }) : super(key: key);

  /// Provides callback when user selects emoji.
  final ValueSetter<String> onSelected;

  /// Configuration for emoji picker sheet
  final Config? emojiPickerSheetConfig;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      decoration: BoxDecoration(
        color: emojiPickerSheetConfig?.emojiViewConfig.backgroundColor ??
            Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      height: size.height * 0.6,
      width: size.width,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            width: 35,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          Expanded(
            child: EmojiPicker(
              onEmojiSelected: (Category? category, Emoji emoji) =>
                  onSelected(emoji.emoji),
              config: emojiPickerSheetConfig ??
                  Config(
                    emojiViewConfig: EmojiViewConfig(
                      columns: 7,
                      emojiSizeMax:
                          32 * ((!kIsWeb && Platform.isIOS) ? 1.30 : 1.0),
                      recentsLimit: 28,
                      backgroundColor: Colors.white,
                    ),
                    searchViewConfig: const SearchViewConfig(
                      buttonIconColor: Colors.black,
                    ),
                    categoryViewConfig: const CategoryViewConfig(
                      initCategory: Category.RECENT,
                      recentTabBehavior: RecentTabBehavior.NONE,
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(
                      backgroundColor: Colors.white,
                      buttonIconColor: Colors.black,
                      buttonColor: Colors.white,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
