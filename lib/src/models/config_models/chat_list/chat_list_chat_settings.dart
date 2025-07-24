import '../../../values/enumeration.dart';

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
    MuteStatus? muteStatus,
    PinStatus? pinStatus,
    DateTime? pinTime,
    bool forceNullValue = false,
  }) {
    return ChatSettings(
      muteStatus: muteStatus ?? this.muteStatus,
      pinStatus: pinStatus ?? this.pinStatus,
      pinTime: forceNullValue ? pinTime : pinTime ?? this.pinTime,
    );
  }
}
