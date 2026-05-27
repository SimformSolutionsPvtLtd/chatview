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

import '../models/config_models/send_message_configuration.dart';
import '../utils/constants/constants.dart';
import '../utils/package_strings.dart';
import 'chat_textfield_view_builder.dart';

/// A widget shown above the text field when the user is editing a message.
///
/// Displays an "Editing" header and a close button to cancel the edit.
class EditMessageView extends StatefulWidget {
  const EditMessageView({
    super.key,
    required this.sendMessageConfig,
    required this.onChange,
  });

  /// Configuration for the send-message text field area.
  final SendMessageConfiguration? sendMessageConfig;

  /// Called whenever the edit-mode message changes (including when cleared).
  final ValueSetter<Message?> onChange;

  @override
  State<EditMessageView> createState() => EditMessageViewState();
}

class EditMessageViewState extends State<EditMessageView> {
  /// The message currently being edited. `null` means edit mode is inactive.
  final ValueNotifier<Message?> editMessage = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    editMessage.addListener(_handleChange);
  }

  @override
  Widget build(BuildContext context) {
    return ChatTextFieldViewBuilder<Message?>(
      valueListenable: editMessage,
      builder: (_, state, __) {
        if (state == null) return const SizedBox.shrink();

        final editLabel =
            (widget.sendMessageConfig?.editLabel?.trim().isNotEmpty ?? false)
                ? widget.sendMessageConfig!.editLabel!.trim()
                : PackageStrings.currentLocale.editing;
        final titleColor = widget.sendMessageConfig?.replyTitleColor ??
            Theme.of(context).colorScheme.primary;

        return Container(
          decoration: BoxDecoration(
            color: widget.sendMessageConfig?.textFieldBackgroundColor ??
                Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
          ),
          padding: const EdgeInsets.only(left: leftPadding, right: leftPadding, bottom: 48),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  editLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  Icons.close,
                  color: widget.sendMessageConfig?.closeIconColor ??
                      Colors.black54,
                  size: 18,
                ),
                onPressed: onClose,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleChange() {
    widget.onChange.call(editMessage.value);
  }

  /// Clears the edit state, exiting edit mode.
  void onClose() {
    editMessage.value = null;
  }

  @override
  void dispose() {
    editMessage
      ..removeListener(_handleChange)
      ..dispose();
    super.dispose();
  }
}
