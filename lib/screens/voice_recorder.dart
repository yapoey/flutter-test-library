import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:path_provider/path_provider.dart';

class VoiceRecorderScreen extends StatefulWidget {
  const VoiceRecorderScreen({super.key});

  @override
  VoiceRecorderScreenState createState() => VoiceRecorderScreenState();
}

class VoiceRecorderScreenState extends State<VoiceRecorderScreen> {
  FlutterSoundRecorder? _recorder;
  final audio.AudioPlayer _audioPlayer = audio.AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  Duration _pausedPosition = Duration.zero;
  PlayerController? playerController;
  StreamSubscription? _positionSubscription;
  RecorderController recorderController = RecorderController();
  Duration _totalDuration = Duration.zero;
  final List<double> _playbackSpeeds = [1.0, 1.5, 2.0];
  int _currentSpeedIndex = 0;

  void _changePlaybackSpeed() {
    setState(() {
      _currentSpeedIndex = (_currentSpeedIndex + 1) % _playbackSpeeds.length;
      _audioPlayer.setPlaybackRate(_playbackSpeeds[_currentSpeedIndex]);
    });
  }

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    playerController = PlayerController();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      return;
    }
  }

  Future<void> _startRecording() async {
    if (_recorder != null && !_recorder!.isRecording) {
      await _recorder!.openRecorder();
      await recorderController.record();
      final dir = await getApplicationDocumentsDirectory();
      _recordingPath = '${dir.path}/recording.aac';

      await _recorder!.startRecorder(toFile: _recordingPath);

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_recorder != null) {
      await _recorder!.stopRecorder();
      await _recorder!.closeRecorder();
      await recorderController.stop();
      setState(() {
        _isRecording = false;
      });

      if (_recordingPath != null) {
        await playerController!.preparePlayer(path: _recordingPath!);
        _totalDuration = await _audioPlayer.getDuration() ?? Duration.zero;
      }
    }
  }

  Future<void> _playRecording() async {
    if (_recordingPath != null && !_isPlaying) {
      await _audioPlayer.play(audio.DeviceFileSource(_recordingPath!),
          position: _pausedPosition);

      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == audio.PlayerState.playing;
        });
      });

      _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          playerController!.seekTo(position.inMilliseconds);
        }
      });

      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _pausePlayback() async {
    if (_audioPlayer.state == audio.PlayerState.playing) {
      _pausedPosition =
          await _audioPlayer.getCurrentPosition() ?? Duration.zero;
      await _audioPlayer.pause();
    }
    _positionSubscription?.cancel();

    setState(() {
      _isPlaying = false;
    });
  }

  void _seekToPosition(Offset localPosition, Size waveformSize) {
    if (_totalDuration == Duration.zero) return;
    double percentage = localPosition.dx / waveformSize.width;
    percentage = percentage.clamp(0.0, 1.0);
    final seekPosition = Duration(
        milliseconds: (percentage * _totalDuration.inMilliseconds).toInt());
    _audioPlayer.seek(seekPosition);
    setState(() {
      _pausedPosition = seekPosition;
    });
  }

   getWaves() async{
    return await playerController?.extractWaveformData(path: _recordingPath!);
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _audioPlayer.dispose();
    _positionSubscription?.cancel();
    playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Voice Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording)
              AudioWaveforms(
                size: const Size(double.infinity, 100),
                recorderController: recorderController,
                enableGesture: true,
              ),
            if (!_isRecording && _recordingPath != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: _isPlaying ? _pausePlayback : _playRecording,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTapDown: (details) {
                            final size = context.size ?? Size.zero;
                            _seekToPosition(details.localPosition, size);
                          },
                          onHorizontalDragUpdate: (details) {
                            final size = context.size ?? Size.zero;
                            _seekToPosition(details.localPosition, size);
                          },
                          child: AudioFileWaveforms(
                            size: const Size(double.infinity, 100),
                            playerController: playerController!,
                            waveformType: WaveformType.long,
                            enableSeekGesture: true,
                            waveformData: getWaves(),
                            playerWaveStyle: const PlayerWaveStyle(
                              fixedWaveColor: Colors.orange,
                              liveWaveColor: Colors.blue,
                              showSeekLine: true,
                              seekLineColor: Colors.green,
                              seekLineThickness: 2,
                              waveThickness: 3,
                              spacing: 5,
                              scaleFactor: 300,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: _changePlaybackSpeed,
                        child: Text("${_playbackSpeeds[_currentSpeedIndex]}x"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: Icon(
                Icons.mic,
                color: _isRecording ? Colors.red : Colors.black,
                size: 70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
