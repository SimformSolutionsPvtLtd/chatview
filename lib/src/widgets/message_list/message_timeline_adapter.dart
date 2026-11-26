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

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../extensions/extensions.dart';
import '../../values/enumeration.dart';
import '../../values/typedefs.dart';

/// Turns the controller's message stream into a stream of [MessageTimeline]s:
/// the messages sorted, with their date separators worked out.
///
/// Sorting and separators run once per stream event, not on every rebuild of
/// the list (opening the reaction popup, text field height changes).
///
/// Two adapters with the same fields are equal, so the list only needs a new
/// adapter, and with it a new stream, when the controller or a setting changes.
///
/// Nothing to dispose: [stream] only maps the controller's existing stream.
/// The `StreamBuilder` cancels its own subscription.
@immutable
class MessageTimelineAdapter {
  MessageTimelineAdapter({
    required this.controller,
    required this.sortEnable,
    required this.sorter,
    required this.order,
    required this.enableSeparator,
  });

  final ChatController controller;

  /// Whether to sort the messages. When false they are only reversed.
  final bool sortEnable;

  /// Sorts the messages.
  final MessageSorter sorter;

  final GroupedListOrder order;

  /// Whether to work out where date separators go.
  final bool enableSeparator;

  /// One [MessageTimeline] for every event of the controller's message stream.
  ///
  /// Nothing to dispose: [stream] only maps the controller's existing stream.
  /// The `StreamBuilder` cancels its own subscription.
  late final Stream<MessageTimeline> stream =
      controller.messageStreamController.stream.map(timelineFrom);

  /// The current messages as a timeline.
  ///
  /// Shows a new subscription right away, because the message stream is
  /// broadcast and does not replay its last event.
  MessageTimeline get current => timelineFrom(controller.initialMessageList);

  /// Sorts [data] and works out its date separators.
  MessageTimeline timelineFrom(List<Message> data) {
    final messages = sortEnable ? _sort(data) : data.reversed.toList();

    var separators = <int, DateTime>{};
    var separatorCounts = <int, int>{};
    var itemIndexes = const <Object, int>{};
    if (enableSeparator && messages.isNotEmpty) {
      (separators, separatorCounts, itemIndexes) = _separatorsOf(messages);
    } else {
      itemIndexes = <Object, int>{
        for (var i = 0; i < messages.length; i++) messages[i].id: i,
      };
    }

    return (
      messages: messages,
      separators: separators,
      separatorCounts: separatorCounts,
      itemIndexes: itemIndexes,
    );
  }

  List<Message> _sort(List<Message> messages) {
    // Messages arrive in chronological order, so the list is nearly always
    // already sorted, or exactly reversed. One pass over neighbours tells,
    // and costs far less than a sort, which does not speed up on ordered data.
    // ponytail: needs a consistent comparator, same as `sort`.
    var sorted = true;
    var reversed = true;
    for (var i = 1; i < messages.length && (sorted || reversed); i++) {
      final c = sorter(messages[i - 1], messages[i]);
      if (c > 0) sorted = false;
      if (c < 0) reversed = false;
    }
    // Always a fresh list, so it can be returned directly for the ascending
    // case instead of allocating another list.
    final elements = sorted
        ? messages.toList()
        : reversed
            ? messages.reversed.toList()
            : (messages.toList()..sort(sorter));
    return order.isAsc ? elements : elements.reversed.toList();
  }

  /// return DateTime by checking lastMatchedDate and message created DateTime
  DateTime _groupBy(DateTime messageCreatedAt, DateTime lastMatchedDate) {
    // If the conversation is ongoing on the same date,
    // return the same date [lastMatchedDate].

    // When the conversation starts on a new date,
    // we are returning new date [messageCreatedAt].

    /// Groups by calendar day with [DateTime.isSameCalendarDay], not formatted
    /// strings: no `DateFormat` call per message, so separators stay cheap in
    /// long chats.
    return lastMatchedDate.isSameCalendarDay(messageCreatedAt)
        ? lastMatchedDate
        : messageCreatedAt;
  }

  /// Returns the separators, the separator counts and the list index of every
  /// message and separator for [messages].
  (Map<int, DateTime>, Map<int, int>, Map<Object, int>) _separatorsOf(
    List<Message> messages,
  ) {
    var counter = 0;
    // Starts at the first message's date, not now: the loop below starts at
    // index 1, so a lone (or same-day) first message would get today's separator.
    var lastMatchedDate = messages.firstOrNull?.createdAt ?? DateTime.now();
    final separators = <int, DateTime>{};

    // Build separator counts as we build the separator map
    final separatorCounts = <int, int>{
      0: 0, // Initial count since the loop starts from index 1
    };

    // The first message is always at index 0.
    final itemIndexes = <Object, int>{messages.first.id: 0};

    final messagesLength = messages.length;

    // Build separator map and update counts in the same loop
    for (var i = 1; i < messagesLength; i++) {
      lastMatchedDate = _groupBy(messages[i].createdAt, lastMatchedDate);
      final previousDate = _groupBy(messages[i - 1].createdAt, lastMatchedDate);

      if (previousDate == lastMatchedDate) {
        separatorCounts[i + counter] = counter;
      } else {
        // Group separator when previous message and current message time differ
        final separatorIndex = i + counter++;
        separatorCounts[separatorIndex + 1] = counter;
        separators[separatorIndex] = previousDate;
        itemIndexes[previousDate] = separatorIndex;
      }
      itemIndexes[messages[i].id] = i + counter;
    }

    final separatorIndex = messagesLength + counter;
    separatorCounts[separatorIndex + 1] = counter;
    separators[separatorIndex] = lastMatchedDate;
    itemIndexes[lastMatchedDate] = separatorIndex;

    return (separators, separatorCounts, itemIndexes);
  }

  @override
  bool operator ==(Object other) =>
      other is MessageTimelineAdapter &&
      other.controller == controller &&
      other.sortEnable == sortEnable &&
      other.sorter == sorter &&
      other.order == order &&
      other.enableSeparator == enableSeparator;

  @override
  int get hashCode =>
      Object.hash(controller, sortEnable, sorter, order, enableSeparator);
}
