import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:path_provider/path_provider.dart';

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key});

  @override
  ImageEditorScreenState createState() => ImageEditorScreenState();
}

class ImageEditorScreenState extends State<ImageEditorScreen> {
  XFile? _imageFile;
  File? _editedImageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _editedImageFile = null;
      });
    }
  }

  Future<void> _editImage() async {
    if (_imageFile == null && _editedImageFile == null) return;
    final imageToEdit = _editedImageFile ?? File(_imageFile!.path);
    final editedImage = await Navigator.of(context).push<File?>(
      MaterialPageRoute(
        builder: (context) => ProImageEditor.file(
          imageToEdit,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (edited) {
              final editedFile = File('${_imageFile!.path}_edited.png');
              editedFile.writeAsBytesSync(edited);
              setState(() {
                _imageFile = XFile(editedFile.path);
                _editedImageFile = editedFile;
              });
              return Future<void>(() => editedFile);
            },
            onCloseEditor: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );

    if (editedImage != null) {
      setState(() {
        _imageFile = XFile(editedImage.path);
        _editedImageFile = editedImage;
      });
    }
  }

  Future<void> _saveImage() async {
    if (_editedImageFile == null) return;
    final directory = await getApplicationDocumentsDirectory();
    final savedImagePath = '${directory.path}/saved_edited_image.png';
    await _editedImageFile!.copy(savedImagePath);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image saved to: $savedImagePath')),
    );
  }

  void _deleteImage() {
    setState(() {
      _imageFile = null;
      _editedImageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Image Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveImage,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteImage,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _editedImageFile != null
                  ? Image.file(_editedImageFile!)
                  : _imageFile != null
                  ? Image.file(File(_imageFile!.path))
                  : const Text('No image selected.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: _editImage,
                child: const Text('Edit Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
