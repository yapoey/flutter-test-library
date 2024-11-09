import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../widgets/sticker_selector_widget.dart';
import 'gif_screen.dart';

class StickerScreen extends StatefulWidget {
  const StickerScreen({super.key});

  @override
  StickerScreenState createState() => StickerScreenState();
}

class StickerScreenState extends State<StickerScreen> {
  List<String> stickerMessages = [];
  bool isStickerSelectorVisible = false;
  final String apiKey = 'OoDzqWoXj8fTctIdJe1DJ1k65Zy4W3Nj';

  void addStickerMessage(String stickerUrl) {
    setState(() {
      stickerMessages.add(stickerUrl);
      isStickerSelectorVisible = false; // Hide sticker selector after selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sticker Chat'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: stickerMessages.length,
              itemBuilder: (context, index) {
                return ChatBubble(stickerUrl: stickerMessages[index]);
              },
            ),
          ),
          if (isStickerSelectorVisible)
            SizedBox(
              height: 400,
              child: StickerSelector(
                apiKey: apiKey,
                onStickerSelected: addStickerMessage,
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.sticky_note_2),
                onPressed: () {
                  setState(() {
                    isStickerSelectorVisible = !isStickerSelectorVisible;
                  });
                },
              ),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Type a message...'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String stickerUrl;

  const ChatBubble({super.key, required this.stickerUrl});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 100,
        width: 100,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: stickerUrl.startsWith("http")
            ? CachedNetworkImage(
          height: 100,
          width: 100,
              imageUrl: stickerUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
            : Image.file(
          height: 100,
          width: 100,
              File(stickerUrl),
              fit: BoxFit.contain,
            ),
      ),
    );
  }
}
