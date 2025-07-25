import 'package:flutter/cupertino.dart';

import '../../../values/enumeration.dart';
import '../../../values/typedefs.dart';

class ChatMenuConfig {
  const ChatMenuConfig({
    this.enabled = true,
    this.actions,
    this.textStyle,
    this.menuBuilder,
    this.muteStatusCallback,
    this.pinStatusCallback,
    this.muteStatusTrailingIcon,
    this.pinStatusTrailingIcon,
  });

  final bool enabled;
  final TextStyle? textStyle;
  final List<Widget>? actions;
  final MenuBuilderCallback? menuBuilder;
  final ChatStatusCallback<MuteStatus>? muteStatusCallback;
  final ChatStatusCallback<PinStatus>? pinStatusCallback;
  final StatusTrailingIcon<MuteStatus>? muteStatusTrailingIcon;
  final StatusTrailingIcon<PinStatus>? pinStatusTrailingIcon;
}
