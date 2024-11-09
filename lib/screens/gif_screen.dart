import 'package:components_test/widgets/gif_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GifScreen extends StatefulWidget {
  const GifScreen({super.key});

  @override
  GifScreenState createState() => GifScreenState();
}

class GifScreenState extends State<GifScreen> {
  List<String> gifMessages = [];
  bool isGifSelectorVisible = false;

  final String apiKey = 'OoDzqWoXj8fTctIdJe1DJ1k65Zy4W3Nj';

  void addGifMessage(String gifUrl) {
    setState(() {
      gifMessages.add(gifUrl);
      isGifSelectorVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('GIF Chat'),backgroundColor: Colors.white,),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gifMessages.length,
              itemBuilder: (context, index) => ChatBubble(gifUrl: gifMessages[index]),
            ),
          ),
          if (isGifSelectorVisible)
            GifSelector(
              apiKey: apiKey,
              onGifSelected: addGifMessage,
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.gif),
                onPressed: () {
                  setState(() => isGifSelectorVisible = !isGifSelectorVisible);
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
  final String gifUrl;

  const ChatBubble({super.key, required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CachedNetworkImage(
          imageUrl: gifUrl,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
