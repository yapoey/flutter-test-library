import 'package:flutter/material.dart';
import 'image_editor_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pro Image Editor Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageEditorScreen(),
              ),
            );
          },
          child: Text('Open Image Editor'),
        ),
      ),
    );
  }
}
