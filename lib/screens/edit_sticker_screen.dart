import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class EditStickerScreen extends StatefulWidget {
  final String stickerPath;

  const EditStickerScreen({Key? key, required this.stickerPath}) : super(key: key);

  @override
  _EditStickerScreenState createState() => _EditStickerScreenState();
}

class _EditStickerScreenState extends State<EditStickerScreen> {
  File? _stickerFile;
  img.Image? _stickerImage;
  List<Offset?> _cropPath = [];
  bool _isLoading = true;
  ui.Image? _uiImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      if (widget.stickerPath.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.stickerPath));
        if (response.statusCode == 200) {
          _stickerImage = img.decodeImage(response.bodyBytes);
          _stickerFile = await _saveImageLocally(response.bodyBytes);
        }
      } else {
        _stickerFile = File(widget.stickerPath);
        if (await _stickerFile!.exists()) {
          _stickerImage = img.decodeImage(await _stickerFile!.readAsBytes());
        }
      }

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


  bool _isPointInPolygon(List<img.Point> polygon, img.Point point) {
    int i = 0, j = polygon.length - 1;
    bool isInside = false;
    for (; i < polygon.length; j = i++) {
      if ((polygon[i].y > point.y) != (polygon[j].y > point.y) &&
          (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x)) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  int _getRed(int color) => (color >> 16) & 0xFF;

  Future<void> _cropImage() async {
    if (_stickerImage != null && _cropPath.isNotEmpty) {
      final width = _stickerImage!.width;
      final height = _stickerImage!.height;

      if (width <= 0 || height <= 0) {
        debugPrint('Error: Invalid image dimensions');
        return;
      }

      debugPrint('Width: $width, Height: $height');

      final mask = img.Image(width: width, height: height);
      final cropPath = _cropPath
          .whereType<Offset>()
          .map((offset) => img.Point(offset.dx.toInt(), offset.dy.toInt()))
          .toList();

      // Create mask based on the polygon
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          if (_isPointInPolygon(cropPath, img.Point(x, y))) {
            mask.setPixel(x, y, img.ColorFloat16.rgba(1.0, 1.0, 1.0, 1.0)); // White (opaque)
          } else {
            mask.setPixel(x, y, img.ColorFloat16.rgba(0.0, 0.0, 0.0, 0.0)); // Fully transparent
          }
        }
      }

      final croppedImage = img.Image(width: width, height: height);

      // Apply the mask to the cropped image
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final originalPixel = _stickerImage!.getPixel(x, y);
          final maskPixel = mask.getPixel(x, y);

          // Check if the mask is opaque
          if (maskPixel != img.ColorFloat16.rgba(0.0, 0.0, 0.0, 0.0)) { // If not transparent
            croppedImage.setPixel(x, y, originalPixel); // Keep original pixel
          } else {
            croppedImage.setPixel(x, y, img.ColorFloat16.rgba(0.0, 0.0, 0.0, 0.0)); // Set to fully transparent
          }
        }
      }

      final croppedBytes = img.encodePng(croppedImage);
      final editedStickerFile = await _saveImageLocally(Uint8List.fromList(croppedBytes));
      debugPrint('Edited sticker file path: ${editedStickerFile.path}');
      Navigator.pop(context, editedStickerFile.path);
    } else {
      debugPrint('Error: Unable to crop image.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            _cropPath.add(null);
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

      final outlinePaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
