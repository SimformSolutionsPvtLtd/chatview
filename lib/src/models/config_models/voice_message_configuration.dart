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

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import '../../values/typedefs.dart';

/// A configuration model class for voice message bubble.
class VoiceMessageConfiguration {
  const VoiceMessageConfiguration({
    @Deprecated(
        'Use `outgoingPlayerWaveStyle`/`inComingPlayerWaveStyle` instead.')
    this.playerWaveStyle,
    this.outgoingPlayerWaveStyle,
    this.inComingPlayerWaveStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.margin,
    this.decoration,
    this.animationCurve,
    this.animationDuration,
    this.pauseIcon,
    this.playIcon,
    this.waveformMargin,
    this.waveformPadding,
    this.enableSeekGesture = true,
  });

  /// Applies style to waveform.
  ///
  /// **Note:** if both [playerWaveStyle] and [outgoingPlayerWaveStyle]/[inComingPlayerWaveStyle] are provided,
  /// then [outgoingPlayerWaveStyle]/[inComingPlayerWaveStyle] will take precedence.
  final PlayerWaveStyle? playerWaveStyle;

  /// Applies style to outgoing waveform.
  final PlayerWaveStyle? outgoingPlayerWaveStyle;

  /// Applies style to incoming waveform.
  final PlayerWaveStyle? inComingPlayerWaveStyle;

  /// Applies padding to message bubble.
  final EdgeInsets padding;

  /// Applies margin to message bubble.
  final EdgeInsets? margin;

  /// Applies padding to waveform.
  final EdgeInsets? waveformPadding;

  /// Applies padding to waveform.
  final EdgeInsets? waveformMargin;

  /// BoxDecoration for voice message bubble.
  final BoxDecoration? decoration;

  /// Duration for grow animation for waveform. Default to 500 ms.
  final Duration? animationDuration;

  /// Curve for for grow animation for waveform. Default to Curve.easeIn.
  final Curve? animationCurve;

  /// Callback to build custom icon for playing audio
  final CustomVoiceActionIconCallback? playIcon;

  /// Callback to build custom icon for pausing audio
  final CustomVoiceActionIconCallback? pauseIcon;

  /// Enable/disable seeking with gestures. Enabled by default.
  final bool enableSeekGesture;
}
