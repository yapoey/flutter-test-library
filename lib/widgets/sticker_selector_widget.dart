import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../screens/edit_sticker_screen.dart';

class StickerSelector extends StatefulWidget {
  final String apiKey;
  final Function(String) onStickerSelected;

  const StickerSelector({
    super.key,
    required this.apiKey,
    required this.onStickerSelected,
  });

  @override
  _StickerSelectorState createState() => _StickerSelectorState();
}

class _StickerSelectorState extends State<StickerSelector> {
  List<String> stickerUrls = [];
  List<String> customStickers = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int offsetTrending = 0;
  final int limitTrending = 10;
  int offsetSearching = 0;
  final int limitSearching = 10;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchTrendingStickers();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMoreData) {
      if (_searchController.text.isEmpty) {
        fetchTrendingStickers();
      } else {
        fetchStickers(_searchController.text);
      }
    }
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
      Uri.parse('https://api.giphy.com/v1/stickers/search?api_key=${widget.apiKey}&q=$query&limit=$limitSearching&offset=$offsetSearching'),
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
      Uri.parse('https://api.giphy.com/v1/stickers/trending?api_key=${widget.apiKey}&limit=$limitTrending&offset=$offsetTrending'),
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

  void showStickerOptions(String stickerUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            children: [
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
    return Column(
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
            controller: _scrollController,
            children: [
              if (customStickers.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Custom Stickers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              if (customStickers.isNotEmpty)
                ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    itemCount: customStickers.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () => showStickerOptions(customStickers[index]),
                        onTap: () => widget.onStickerSelected(customStickers[index]),
                        child: Image.file(
                          File(customStickers[index]),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  const Divider(thickness: 2),
                ],
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'API Stickers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: stickerUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => widget.onStickerSelected(stickerUrls[index]),
                    onLongPress: () => showStickerOptions(stickerUrls[index]),
                    child: CachedNetworkImage(
                      imageUrl: stickerUrls[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  );
                },
              ),
              if (isLoadingMore)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: addCustomSticker,
        ),
      ],
    );
  }
}
