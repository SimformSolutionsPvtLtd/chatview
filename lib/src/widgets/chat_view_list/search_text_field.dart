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
import 'dart:async';

import 'package:flutter/material.dart';

import '../../controller/chat_list_view_controller.dart';
import '../../models/config_models/chat_view_list/search_config.dart';
import '../../utils/package_strings.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    required this.config,
    this.chatViewListController,
    this.disposeResources = true,
    super.key,
  });

  /// Configuration for the search text field.
  final SearchConfig config;

  /// Controller for managing the chat list.
  final ChatViewListController? chatViewListController;

  final bool disposeResources;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final ValueNotifier<String> _inputText = ValueNotifier('');

  SearchConfig get _config => widget.config;

  InputBorder get _outlineBorder =>
      _config.border ??
      OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: _config.borderRadius,
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _config.textEditingController,
      style: _config.textStyle,
      enabled: _config.enabled,
      maxLines: _config.maxLines,
      minLines: _config.minLines,
      maxLength: _config.maxLength,
      onChanged: _onSearchChanged,
      onTapOutside: _config.onTapOutside,
      keyboardType: _config.textInputType,
      textInputAction: _config.textInputAction,
      inputFormatters: _config.inputFormatters,
      textCapitalization: _config.textCapitalization,
      decoration: _config.decoration ??
          InputDecoration(
            filled: true,
            border: _outlineBorder,
            focusedBorder: _outlineBorder,
            enabledBorder: _outlineBorder,
            disabledBorder: _outlineBorder,
            contentPadding: _config.contentPadding,
            fillColor: _config.textFieldBackgroundColor,
            hintText: _config.hintText ?? PackageStrings.currentLocale.search,
            prefixIcon: _config.prefixIcon,
            suffixIcon: _config.suffixIcon ??
                ValueListenableBuilder(
                  valueListenable: _inputText,
                  builder: (context, value, _) => value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _onTapClear,
                        ),
                ),
            hintStyle: _config.hintStyle ??
                TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.25,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.disposeResources) _config.textEditingController.dispose();
  }

  void _onTapClear() {
    _inputText.value = '';
    _config.textEditingController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    widget.chatViewListController?.clearSearch();
  }

  FutureOr<void> _onSearchChanged(String value) async {
    _inputText.value = value;
    final chatList = await _config.onSearch?.call(value);
    if (chatList != null) {
      widget.chatViewListController?.setSearchChats(chatList);
    } else if (value.isEmpty) {
      widget.chatViewListController?.clearSearch();
    }
  }
}
