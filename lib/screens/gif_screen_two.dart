import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

class GifScreenTwo extends StatefulWidget {
  const GifScreenTwo({super.key});

  @override
  GifScreenTwoState createState() => GifScreenTwoState();
}

class GifScreenTwoState extends State<GifScreenTwo> {
  List<String> gifMessages = [];
  bool isGifSelectorVisible = false;
  List<String> gifUrls = [];
  final String apiKey = 'AIzaSyArH9pKWffbCeJOa7zzAe0tqy68PRyB_IE'; // Replace with your Tenor API Key
  final TextEditingController _searchController = TextEditingController();
  int offsetTrending = 0;
  final int limitTrending = 10;
  int offsetSearching = 0;
  final int limitSearching = 10;
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  bool hasMoreData = true; // Track if there’s more data to load

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !isLoadingMore && hasMoreData) {
      // Fetch more data if close to the bottom and not already loading
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
        offsetSearching = 0;
        hasMoreData = true; // Reset this when starting a new search
      });
    }

    if (!hasMoreData) return; // Exit if no more data is available

    setState(() => isLoadingMore = true); // Start loading

    final response = await http.get(
      Uri.parse("https://tenor.googleapis.com/v2/search?q=excited&key=$apiKey&client_key=my_test_app&limit=$limitSearching&pos=$offsetSearching"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newGifs = List<String>.from(data['results'].map((gif) => gif['media_formats']['gif']['url']));

      setState(() {
        gifUrls.addAll(newGifs.where((gifUrl) => !gifUrls.contains(gifUrl)));
        offsetSearching += limitSearching;

        // Update hasMoreData based on the response
        hasMoreData = newGifs.length == limitSearching; // If less than limit, assume no more data
      });
    } else {
      print('Error fetching GIFs: ${response.statusCode}');
    }

    setState(() => isLoadingMore = false); // Stop loading
  }

  Future<void> fetchTrendingGifs() async {
    if (!hasMoreData) return; // Exit if no more data is available

    setState(() => isLoadingMore = true); // Start loading

    final response = await http.get(
      Uri.parse("https://tenor.googleapis.com/v2/featured?key=$apiKey&client_key=my_test_app"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newGifs = List<String>.from(data['results'].map((gif) => gif['media_formats']['gif']['url']));

      setState(() {
        gifUrls.addAll(newGifs.where((gifUrl) => !gifUrls.contains(gifUrl)));
        offsetTrending += limitTrending;

        // Update hasMoreData based on the response
        hasMoreData = newGifs.length == limitTrending; // If less than limit, assume no more data
      });
    } else {
      print('Error fetching trending GIFs: ${response.statusCode}');
    }

    setState(() => isLoadingMore = false); // Stop loading
  }

  void addGifMessage(String gifUrl) {
    setState(() {
      gifMessages.add(gifUrl);
      isGifSelectorVisible = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('GIF Chat'), backgroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gifMessages.length,
              itemBuilder: (context, index) {
                return ChatBubble(gifUrl: gifMessages[index]);
              },
            ),
          ),
          if (isGifSelectorVisible)
            SizedBox(
              height: 400,
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
                              onTap: () => addGifMessage(gifUrls[index]),
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
                          Positioned(
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
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.gif),
                onPressed: () {
                  setState(() {
                    isGifSelectorVisible = !isGifSelectorVisible;
                    _searchController.clear();
                    fetchTrendingGifs();
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
