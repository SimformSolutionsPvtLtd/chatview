import 'package:audio_waveforms/audio_waveforms.dart';

/// Manages audio playback across the chat application.
///
/// Ensures only one voice message is playing at a time and provides
/// utilities for controlling audio playback state.
class AudioManager {
  AudioManager._();

  static final AudioManager _instance = AudioManager._();

  /// Gets the singleton instance of AudioManager.
  static AudioManager get instance => _instance;

  /// Holds the currently playing voice message controller (if any).
  ///
  /// Used to ensure only one voice note is playing/active across the chat,
  /// and to allow stopping playback when starting a recording.
  PlayerController? _currentlyPlayingController;

  /// Starts playing audio with the given controller.
  ///
  /// If [singlePlayerMode] is true and another audio is already playing,
  /// it will be paused before starting the new audio.
  ///
  /// If [singlePlayerMode] is false, multiple audios can play simultaneously.
  ///
  /// [controller] - The PlayerController to start playing.
  /// [singlePlayerMode] - If true, only one audio can play at a time.
  void startPlaying(PlayerController controller,
      {bool singlePlayerMode = false}) {
    if (singlePlayerMode) {
      final previousController = _currentlyPlayingController;

      /// If another audio is already playing, stop it first.
      if (previousController != null &&
          !identical(previousController, controller)) {
        previousController.pausePlayer();
      }

      _currentlyPlayingController = controller;
    }

    controller.startPlayer();
    controller.setFinishMode(finishMode: FinishMode.pause);
  }

  /// Pauses the currently playing audio.
  ///
  /// [controller] - The PlayerController to pause.
  /// [singlePlayerMode] - If true, clears the currently playing controller reference.
  void pausePlaying(PlayerController controller,
      {bool singlePlayerMode = false}) {
    controller.pausePlayer();
    if (singlePlayerMode &&
        identical(_currentlyPlayingController, controller)) {
      _currentlyPlayingController = null;
    }
  }

  /// Stops all audio playback.
  ///
  /// This is useful when starting a recording or when needing to
  /// ensure no audio is playing.
  void stopPreviousPlayback() {
    final controller = _currentlyPlayingController;
    if (controller != null) {
      controller.pausePlayer();
      _currentlyPlayingController = null;
    }
  }

  /// Clears the currently playing controller reference.
  ///
  /// Should be called when a controller is disposed to prevent
  /// holding references to disposed controllers.
  ///
  /// [controller] - The PlayerController being disposed.
  void clearController(PlayerController controller) {
    if (identical(_currentlyPlayingController, controller)) {
      _currentlyPlayingController = null;
    }
  }
}
