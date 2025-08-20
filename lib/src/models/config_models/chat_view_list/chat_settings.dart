import '../../../values/enumeration.dart';
import '../../../values/typedefs.dart';
import '../../omit.dart';

class ChatSettings {
  const ChatSettings({
    this.muteStatus = MuteStatus.unmute,
    this.pinStatus = PinStatus.unpinned,
    this.pinTime,
  });

  final MuteStatus muteStatus;
  final PinStatus pinStatus;
  final DateTime? pinTime;

  ChatSettings copyWith({
    Defaulted<MuteStatus> muteStatus = const Omit(),
    Defaulted<PinStatus> pinStatus = const Omit(),
    Defaulted<DateTime>? pinTime = const Omit(),
  }) {
    return ChatSettings(
      muteStatus:
          muteStatus is Omit ? this.muteStatus : muteStatus as MuteStatus,
      pinStatus: pinStatus is Omit ? this.pinStatus : pinStatus as PinStatus,
      pinTime: pinTime is Omit ? this.pinTime : pinTime as DateTime?,
    );
  }
}
