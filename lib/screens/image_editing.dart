import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageEditingScreen extends StatefulWidget {
  const ImageEditingScreen({super.key});

  @override
  ImageEditingScreenState createState() => ImageEditingScreenState();
}

class ImageEditingScreenState extends State<ImageEditingScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String? _imagePath;
  double _zoomLevel = 1.0;
  double _rotationAngle = 0.0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _imagePath = image.path;
      });
      _cropImage();
    } catch (e) {

    }
  }

  Future<void> _cropImage() async {
    if (_imagePath == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _imagePath!,
        uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _imagePath = croppedFile.path;
      });
    }
  }

  void _rotateImage() {
    setState(() {
      _rotationAngle += 90.0;
      if (_rotationAngle == 360.0) _rotationAngle = 0.0;
    });
  }

  void _flipImage() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_imagePath == null ? 'Take a picture' : 'Set your image'),
        backgroundColor: Colors.black,
      ),
      body: _imagePath == null ? _buildCameraPreview() : _buildImageEditingView(),
      floatingActionButton: _imagePath == null
          ? FloatingActionButton(
        onPressed: _captureImage,
        child: const Icon(Icons.camera),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              CameraPreview(_controller),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  width: 200,
                  height: 200,
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error initializing camera'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildImageEditingView() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipOval(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(_zoomLevel)
                  ..rotateZ(_rotationAngle * 3.1415927 / 180)
                  ..scale(_isFlipped ? -1.0 : 1.0, 1.0, 1.0),  // Updated scaling for x, y, z
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        Slider(
          value: _zoomLevel,
          min: 1.0,
          max: 3.0,
          divisions: 20,
          label: "${(_zoomLevel * 100).toInt()}%",
          onChanged: (value) {
            setState(() {
              _zoomLevel = value;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.crop, color: Colors.white),
                onPressed: _cropImage,
              ),
              IconButton(
                icon: const Icon(Icons.flip, color: Colors.white),
                onPressed: _flipImage,
              ),
              IconButton(
                icon: const Icon(Icons.rotate_right, color: Colors.white),
                onPressed: _rotateImage,
              ),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.yellow,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          onPressed: () {
            // Navigate to FullScreenImageView with the edited image path
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImageView(imagePath: _imagePath!),
              ),
            );
          },
          child: const Text("Finish"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// New screen to display the final edited image
class FullScreenImageView extends StatelessWidget {
  final String imagePath;

  const FullScreenImageView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edited Image"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
