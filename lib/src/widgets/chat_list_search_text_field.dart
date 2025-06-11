import 'package:flutter/material.dart';

import '../chat_list_view_controller.dart';
import '../models/config_models/search_config.dart';
import '../utils/constants/constants.dart';
import '../utils/package_strings.dart';

class ChatViewListSearch extends StatefulWidget {
  const ChatViewListSearch({
    super.key,
    required this.searchConfig,
    this.chatViewListController,
  });

  /// Configuration for the search text field.
  final SearchConfig searchConfig;

  /// Controller for managing the chat list.
  final ChatViewListController? chatViewListController;

  @override
  State<ChatViewListSearch> createState() => _ChatViewListSearchState();
}

class _ChatViewListSearchState extends State<ChatViewListSearch> {
  SearchConfig get searchConfig => widget.searchConfig;

  InputBorder get _outlineBorder =>
      searchConfig.border ??
      OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: searchConfig.borderRadius ??
            BorderRadius.circular(textFieldBorderRadius),
      );

  final ValueNotifier<String> _inputText = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchConfig.textEditingController,
      style: searchConfig.textStyle,
      maxLines: searchConfig.maxLines ?? 1,
      minLines: searchConfig.minLines ?? 1,
      keyboardType: searchConfig.textInputType,
      inputFormatters: searchConfig.inputFormatters,
      onChanged: (value) async {
        _inputText.value = value;
        final chatList = await searchConfig.onSearch?.call(value);
        if (chatList != null) {
          widget.chatViewListController?.addSearchResults(chatList);
        } else if (value.isEmpty) {
          widget.chatViewListController?.clearSearch();
        }
      },
      enabled: searchConfig.enabled,
      textCapitalization:
          searchConfig.textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        hintText: searchConfig.hintText ?? PackageStrings.currentLocale.search,
        fillColor: searchConfig.textFieldBackgroundColor ?? Colors.white,
        filled: true,
        prefixIcon: searchConfig.prefixIcon ??
            const Icon(
              Icons.search,
            ),
        suffixIcon: searchConfig.suffixIcon ??
            ValueListenableBuilder(
              valueListenable: _inputText,
              builder: (context, value, child) {
                return value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _inputText.value = '';
                          widget.searchConfig.textEditingController.clear();

                          FocusManager.instance.primaryFocus?.unfocus();
                          widget.chatViewListController?.clearSearch();
                        },
                      )
                    : const SizedBox.shrink();
              },
            ),
        hintStyle: searchConfig.hintStyle ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
              letterSpacing: 0.25,
            ),
        contentPadding: searchConfig.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 6),
        border: _outlineBorder,
        focusedBorder: _outlineBorder,
        enabledBorder: _outlineBorder,
        disabledBorder: _outlineBorder,
      ),
    );
  }
}
