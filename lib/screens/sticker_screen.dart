import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'edit_sticker_screen.dart';

class StickerScreen extends StatefulWidget {
  const StickerScreen({super.key});

  @override
  StickerScreenState createState() => StickerScreenState();
}

class StickerScreenState extends State<StickerScreen> {
  List<String> stickerMessages = []; // Stores URLs of selected stickers
  List<String> favoriteStickers = []; // Stores favorite sticker URLs
  bool isStickerSelectorVisible = false; // Controls visibility of the sticker selector
  List<String> stickerUrls = []; // List to hold sticker search results
  List<String> customStickers = []; // List to hold sticker search results
  final String apiKey = 'OoDzqWoXj8fTctIdJe1DJ1k65Zy4W3Nj'; // Replace with your Sticker API Key
  final TextEditingController _searchController = TextEditingController();
  int offsetTrending = 0;
  final int limitTrending = 10;
  int offsetSearching = 0;
  final int limitSearching = 10;
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore && hasMoreData) {
      if (_searchController.text.isEmpty) {
        fetchTrendingStickers();
      } else {
        fetchStickers(_searchController.text);
      }
    }
  }

  Future<void> addCustomSticker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
        final editedStickerPath = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditStickerScreen(stickerPath: image.path),
          ),
        );
        if (editedStickerPath != null) {
          setState(() {
            customStickers.add(editedStickerPath);
          });
          print('Edited sticker file path: $editedStickerPath  2');
        }
    }
  }

  void removeSticker(int index) {
    setState(() {
      customStickers.removeAt(index);
    });
  }

  Future<void> fetchStickers(String query, {bool isFirst = false}) async {
    if (isFirst) {
      setState(() {
        stickerUrls.clear();
        offsetSearching = 0;
        hasMoreData = true;
      });
    }

    if (!hasMoreData) return;

    setState(() => isLoadingMore = true);

    final response = await http.get(
      Uri.parse('https://api.giphy.com/v1/stickers/search?api_key=$apiKey&q=$query&limit=$limitSearching&offset=$offsetSearching'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newStickers = List<String>.from(data['data'].map((sticker) => sticker['images']['fixed_height']['url']));

      setState(() {
        stickerUrls.addAll(newStickers.where((stickerUrl) => !stickerUrls.contains(stickerUrl)));
        offsetSearching += limitSearching;
        hasMoreData = newStickers.length == limitSearching;
      });
    } else {
      print('Error fetching stickers: ${response.statusCode}');
    }

    setState(() => isLoadingMore = false);
  }

  Future<void> fetchTrendingStickers() async {
    if (!hasMoreData) return;

    setState(() => isLoadingMore = true);

    final response = await http.get(
      Uri.parse('https://api.giphy.com/v1/stickers/trending?api_key=$apiKey&limit=$limitTrending&offset=$offsetTrending'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newStickers = List<String>.from(data['data'].map((sticker) => sticker['images']['fixed_height']['url']));

      setState(() {
        stickerUrls.addAll(newStickers.where((stickerUrl) => !stickerUrls.contains(stickerUrl)));
        offsetTrending += limitTrending;
        hasMoreData = newStickers.length == limitTrending;
      });
    } else {
      print('Error fetching trending stickers: ${response.statusCode}');
    }

    setState(() => isLoadingMore = false);
  }

  void addStickerMessage(String stickerUrl) {
    setState(() {
      stickerMessages.add(stickerUrl);
      isStickerSelectorVisible = false;
      _searchController.clear();
    });
  }

  void showStickerOptions(String stickerUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            children: [
              if (!stickerUrl.startsWith("http"))
                ListTile(
                  title: const Text('Add to Stickers'),
                  onTap: () {
                    if (!favoriteStickers.contains(stickerUrl)) {
                      setState(() {
                        favoriteStickers.add(stickerUrl);
                      });
                    }
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                title: const Text('Edit'),
                onTap: () async {
                  final editedStickerPath = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditStickerScreen(stickerPath: stickerUrl),
                    ),
                  );
                  if (editedStickerPath != null) {
                    setState(() {
                      customStickers.add(editedStickerPath);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              if (!stickerUrl.startsWith("http"))
                ListTile(
                  title: const Text('Remove'),
                  onTap: () {
                    if (customStickers.contains(stickerUrl)) {
                      removeSticker(customStickers.indexOf(stickerUrl));
                    }
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
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
                return GestureDetector(
                  onLongPress: () => showStickerOptions(stickerMessages[index]),
                  child: ChatBubble(
                    stickerUrl: stickerMessages[index],
                  ),
                );
              },
            ),
          ),
          if (isStickerSelectorVisible)
              SizedBox(
                height: 400,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Stickers',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => fetchStickers(_searchController.text, isFirst: true),
                          ),
                        ),
                        onSubmitted: (query) => fetchStickers(query, isFirst: true),
                      ),
                    ),

                      Expanded(
                        child: ListView(
                          children: [
                            if(customStickers.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Custom Stickers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            if(customStickers.isNotEmpty)
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                itemCount: customStickers.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onLongPress: () => showStickerOptions(customStickers[index]),
                                    onTap: () => addStickerMessage(customStickers[index]),
                                    child: Image.file(
                                      File(customStickers[index]),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            if(customStickers.isNotEmpty)
                              const Divider(thickness: 2, height: 30),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('API Stickers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                              itemCount: stickerUrls.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => addStickerMessage(stickerUrls[index]),
                                  onLongPress: () => showStickerOptions(stickerUrls[index]),
                                  child: stickerUrls[index].startsWith("http")
                                      ? CachedNetworkImage(
                                    imageUrl: stickerUrls[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  )
                                      : Image.file(
                                    File(stickerUrls[index]),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                            if (isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.sticky_note_2),
                onPressed: () {
                  setState(() {
                    isStickerSelectorVisible = !isStickerSelectorVisible;
                    _searchController.clear();
                    fetchTrendingStickers();
                  });
                },
              ),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Type a message...'),
                ),
              ),
              if (isStickerSelectorVisible)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      addCustomSticker();
                    });
                  },
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          stickerUrl.startsWith("http") ? CachedNetworkImage(
            imageUrl: stickerUrl,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ) : Image.file(
            File(stickerUrl),
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}