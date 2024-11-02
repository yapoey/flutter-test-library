// import 'dart:async';
// import 'package:audio_service/audio_service.dart';
// import 'package:flutter_sound/flutter_sound.dart';
//
// class AudioPlayerTask extends BackgroundAudioTask {
//   FlutterSoundPlayer _player = FlutterSoundPlayer();
//   bool _isPlaying = false;
//
//   @override
//   Future<void> onStart(Map<String, dynamic>? params) async {
//     await _player.openAudioSession();
//     // Listen to player state changes
//     _player.onPlayerStateChanged.listen((state) {
//       _isPlaying = state == PlayerState.playing;
//       if (!_isPlaying) {
//         AudioService.stop();
//       }
//     });
//   }
//
//   @override
//   Future<void> onStop() async {
//     await _player.stopPlayer();
//     await _player.closeAudioSession();
//     super.onStop();
//   }
//
//   Future<void> play(String path) async {
//     await _player.startPlayer(
//       fromURI: path,
//       codec: Codec.aacADTS,
//     );
//   }
//
//   Future<void> pause() async {
//     await _player.pausePlayer();
//   }
//
//   Future<void> resume() async {
//     await _player.resumePlayer();
//   }
// }
