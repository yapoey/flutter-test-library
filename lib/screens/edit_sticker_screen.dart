import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class EditStickerScreen extends StatefulWidget {
  final String stickerPath; // Can be a URL or local file path

  const EditStickerScreen({Key? key, required this.stickerPath}) : super(key: key);

  @override
  _EditStickerScreenState createState() => _EditStickerScreenState();
}

class _EditStickerScreenState extends State<EditStickerScreen> {
  File? _stickerFile; // Make it nullable
  img.Image? _stickerImage; // Image object for editing
  List<Offset?> _cropPath = [];
  bool _isLoading = true; // Loading state for the image
  ui.Image? _uiImage; // Flutter ui.Image for rendering

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      if (widget.stickerPath.startsWith('http')) {
        // Load image from URL
        final response = await http.get(Uri.parse(widget.stickerPath));
        if (response.statusCode == 200) {
          _stickerImage = img.decodeImage(response.bodyBytes);
          // You can save the downloaded image locally if needed
          _stickerFile = await _saveImageLocally(response.bodyBytes);
        }
      } else {
        // Load local image file
        _stickerFile = File(widget.stickerPath);
        if (await _stickerFile!.exists()) {
          _stickerImage = img.decodeImage(await _stickerFile!.readAsBytes());
        }
      }

      // Convert img.Image to ui.Image for rendering
      if (_stickerImage != null) {
        final bytes = img.encodePng(_stickerImage!);
        _uiImage = await _loadUiImage(bytes);
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<File> _saveImageLocally(Uint8List bytes) async {
    // Specify the path where you want to save the image
    final directory = await Directory.systemTemp.createTemp();
    final file = File('${directory.path}/sticker_${DateTime.now().millisecondsSinceEpoch}.png');
    return await file.writeAsBytes(bytes);
  }

  Future<ui.Image> _loadUiImage(List<int> bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.Codec codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    codec.getNextFrame().then((info) {
      completer.complete(info.image);
    });
    return completer.future;
  }

  Future<void> _cropImage() async {
    // Check if _stickerFile is null
    if (_stickerFile != null) {
      // Here you can implement the cropping logic and save the cropped image
      // For now, we will simply return the original image for demonstration
      Navigator.pop(context, _stickerFile!.path);
    } else {
      debugPrint('Error: Sticker file is null.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sticker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _cropImage,
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _cropPath.add(details.localPosition);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _cropPath.add(details.localPosition);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _cropPath.add(null); // Null to indicate the end of the path
          });
        },
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _uiImage != null
              ? CustomPaint(
            painter: ImagePainter(image: _uiImage!, cropPath: _cropPath),
            child: Container(),
          )
              : const Text('Error loading image'),
        ),
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final List<Offset?> cropPath;

  ImagePainter({required this.image, required this.cropPath});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());

    // Draw cropping path
    if (cropPath.isNotEmpty) {
      final paint = Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      final path = Path();
      for (int i = 0; i < cropPath.length; i++) {
        if (cropPath[i] != null) {
          if (i == 0) {
            path.moveTo(cropPath[i]!.dx, cropPath[i]!.dy);
          } else {
            path.lineTo(cropPath[i]!.dx, cropPath[i]!.dy);
          }
        }
      }
      path.close();
      canvas.drawPath(path, paint);

      // Draw the path outline
      final outlinePaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever the offsets change
  }
}
