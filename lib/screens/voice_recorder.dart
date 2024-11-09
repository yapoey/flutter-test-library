import 'package:components_test/widgets/voice_recorder_widget.dart';
import 'package:flutter/material.dart';


class VoiceRecorderScreen extends StatefulWidget {
  const VoiceRecorderScreen({super.key});
  @override
  VoiceRecorderScreenState createState() => VoiceRecorderScreenState();
}

class VoiceRecorderScreenState extends State<VoiceRecorderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Voice Recorder'),
      ),
      body: const Center(
        child: VoiceRecorderWidget(),
      ),
    );
  }
}
