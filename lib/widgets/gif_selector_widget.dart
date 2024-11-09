import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

class GifSelector extends StatefulWidget {
  final String apiKey;
  final Function(String) onGifSelected;
  final double height;

  const GifSelector({
    super.key,
    required this.apiKey,
    required this.onGifSelected,
    this.height = 400.0,
  });

  @override
  GifSelectorState createState() => GifSelectorState();
}

class GifSelectorState extends State<GifSelector> {
  List<String> gifUrls = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int offset = 0;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchTrendingGifs();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !isLoadingMore && hasMoreData) {
      if (_searchController.text.isEmpty) {
        fetchTrendingGifs();
      } else {
        fetchGifs(_searchController.text);
      }
    }
  }

  Future<void> fetchGifs(String query, {bool isFirst = false}) async {
    if (isFirst) {
      setState(() {
        gifUrls.clear();
        offset = 0;
        hasMoreData = true;
      });
    }
    if (!hasMoreData) return;

    setState(() => isLoadingMore = true);

    final response = await http.get(
      Uri.parse('https://api.giphy.com/v1/gifs/search?api_key=${widget.apiKey}&q=$query&limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newGifs = List<String>.from(data['data'].map((gif) => gif['images']['fixed_height']['url']));
      setState(() {
        gifUrls.addAll(newGifs.where((gifUrl) => !gifUrls.contains(gifUrl)));
        offset += limit;
        hasMoreData = newGifs.length == limit;
      });
    } else {
      print('Error fetching GIFs: ${response.statusCode}');
    }

    setState(() => isLoadingMore = false);
  }

  Future<void> fetchTrendingGifs() async {
    if (!hasMoreData) return;

    setState(() => isLoadingMore = true);

    final response = await http.get(
      Uri.parse('https://api.giphy.com/v1/gifs/trending?api_key=${widget.apiKey}&limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newGifs = List<String>.from(data['data'].map((gif) => gif['images']['fixed_height']['url']));

      setState(() {
        gifUrls.addAll(newGifs.where((gifUrl) => !gifUrls.contains(gifUrl)));
        offset += limit;
        hasMoreData = newGifs.length == limit;
      });
    } else {
      print('Error fetching trending GIFs: ${response.statusCode}');
    }

    setState(() => isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search GIFs',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => fetchGifs(_searchController.text, isFirst: true),
                ),
              ),
              onSubmitted: (query) => fetchGifs(query, isFirst: true),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: gifUrls.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => widget.onGifSelected(gifUrls[index]),
                      child: CachedNetworkImage(
                        imageUrl: gifUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    );
                  },
                ),
                if (isLoadingMore)
                  const Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
