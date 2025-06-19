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

import '../../utils/constants/constants.dart';
import '../../values/enumeration.dart';
import '../../values/typedefs.dart';

class ReceiptsWidgetConfig {
  const ReceiptsWidgetConfig({
    this.receiptsBuilder,
    this.lastSeenAgoBuilder,
    this.showReceiptsIn = ShowReceiptsIn.lastMessage,
  });

  /// The builder that builds widget that right next to the senders message bubble.
  /// Right now it's implemented to show animation only at the last message just
  /// like instagram.
  /// By default [sendMessageAnimationBuilder]
  final ReceiptBuilder? receiptsBuilder;

  /// Just like Instagram messages receipts are displayed at the bottom of last
  /// message. If in case you want to modify it using your custom widget you can
  /// utilize this function.
  final LastSeenAgoBuilder? lastSeenAgoBuilder;

  /// Whether to show receipts in all messages or not defaults to [ShowReceiptsIn.lastMessage]
  final ShowReceiptsIn showReceiptsIn;
}
