import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditStickerScreen extends StatefulWidget {
  final String stickerPath;

  const EditStickerScreen({Key? key, required this.stickerPath}) : super(key: key);

  @override
  _EditStickerScreenState createState() => _EditStickerScreenState();
}

class _EditStickerScreenState extends State<EditStickerScreen> {
  File? _croppedFile;

  Future<void> _cropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.stickerPath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            cropStyle: CropStyle.circle,
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            hideBottomControls: true,
            lockAspectRatio: false,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _croppedFile = File(croppedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _cropImage(); // Start cropping on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sticker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_croppedFile != null) {
                Navigator.pop(context, _croppedFile!.path);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _croppedFile == null
            ? const CircularProgressIndicator()
            : Image.file(_croppedFile!),
      ),
    );
  }
}
