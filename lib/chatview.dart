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

library chatview;

export 'package:audio_waveforms/audio_waveforms.dart'
    show
        WaveStyle,
        PlayerWaveStyle,
        AndroidEncoder,
        IosEncoder,
        AndroidOutputFormat;
export 'package:chatview_utils/chatview_utils.dart';
export 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

export 'src/extensions/extensions.dart' show MessageTypes;
export 'src/models/config_models/receipts_widget_config.dart';
export 'src/models/models.dart';
export 'src/utils/chat_view_locale.dart';
export 'src/utils/package_strings.dart';
export 'src/values/enumeration.dart';
export 'src/values/typedefs.dart';
export 'src/widgets/action_widgets/camera_action_button.dart';
export 'src/widgets/action_widgets/emoji_picker_action_button.dart';
export 'src/widgets/action_widgets/gallery_action_button.dart';
export 'src/widgets/action_widgets/overlay_action_button.dart';
export 'src/widgets/action_widgets/text_field_action_button.dart';
export 'src/widgets/chat_view.dart';
export 'src/widgets/chat_view_appbar.dart';
