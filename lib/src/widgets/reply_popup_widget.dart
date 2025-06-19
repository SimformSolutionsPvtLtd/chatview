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

import '../utils/package_strings.dart';

class ReplyPopupWidget extends StatelessWidget {
  const ReplyPopupWidget({
    Key? key,
    required this.sentByCurrentUser,
    required this.onUnsendTap,
    required this.onReplyTap,
    required this.onReportTap,
    required this.onMoreTap,
    this.buttonTextStyle,
    this.topBorderColor,
  }) : super(key: key);

  /// Represents message is sent by current user or not.
  final bool sentByCurrentUser;

  /// Provides call back when user tap on unsend button.
  final VoidCallback onUnsendTap;

  /// Provides call back when user tap on reply button.
  final VoidCallback onReplyTap;

  /// Provides call back when user tap on report button.
  final VoidCallback onReportTap;

  /// Provides call back when user tap on more button.
  final VoidCallback onMoreTap;

  /// Allow user to set text style of button are showed in reply snack bar.
  final TextStyle? buttonTextStyle;

  /// Allow user to set color of top border of reply snack bar.
  final Color? topBorderColor;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        buttonTextStyle ?? const TextStyle(fontSize: 14, color: Colors.black);
    final deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      height: deviceWidth > 500 ? deviceWidth * 0.05 : deviceWidth * 0.13,
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: topBorderColor ?? Colors.grey.shade400, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onReplyTap,
              child: Text(
                PackageStrings.currentLocale.reply,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
          ),
          if (sentByCurrentUser)
            Expanded(
              child: InkWell(
                onTap: onUnsendTap,
                child: Text(
                  PackageStrings.currentLocale.unsend,
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
            ),
          if (!sentByCurrentUser)
            Expanded(
              child: InkWell(
                onTap: onReportTap,
                child: Text(
                  PackageStrings.currentLocale.report,
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
            ),
          Expanded(
            child: InkWell(
              onTap: onMoreTap,
              child: Text(
                PackageStrings.currentLocale.more,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
