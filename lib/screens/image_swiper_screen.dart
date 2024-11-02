import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ImageSwiperScreen extends StatefulWidget {
  const ImageSwiperScreen({super.key});

  @override
  ImageSwiperScreenState createState() => ImageSwiperScreenState();
}

class ImageSwiperScreenState extends State<ImageSwiperScreen> {
  final List<String> imageUrls = [
    'https://via.placeholder.com/400x200.png?text=Image+1',
    'https://via.placeholder.com/400x200.png?text=Image+2',
    'https://via.placeholder.com/400x200.png?text=Image+3',
  ];

  int activePostIndex = -1; // Index of the post currently showing arrows

  void updateActivePost(int index) {
    // Update only if a different post needs to be active
    if (index != activePostIndex) {
      setState(() {
        activePostIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts with Image Slider'),
      ),
      body: ListView.builder(
        itemCount: 5, // Number of posts
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: PostWidget(
              imageUrls: imageUrls,
              postId: index.toString(),
              isActive: activePostIndex == index,
              onVisibilityChanged: (visibleFraction) {
                if (visibleFraction > 0.5) {
                  updateActivePost(index);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final List<String> imageUrls;
  final String postId;
  final bool isActive;
  final Function(double) onVisibilityChanged;

  PostWidget({
    super.key,
    required this.imageUrls,
    required this.postId,
    required this.isActive,
    required this.onVisibilityChanged,
  });

  @override
  PostWidgetState createState() => PostWidgetState();
}

class PostWidgetState extends State<PostWidget> {
  int currentIndex = 0;
  bool showArrows = true;

  @override
  void initState() {
    super.initState();
    _hideArrowsAfterDelay();
  }

  @override
  void didUpdateWidget(covariant PostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        showArrows = true;
      });
      _hideArrowsAfterDelay();
    }
  }

  void _hideArrowsAfterDelay() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && widget.isActive) {
        setState(() {
          showArrows = false;
        });
      }
    });
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    widget.onVisibilityChanged(info.visibleFraction);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.postId),
      onVisibilityChanged: _onVisibilityChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/50.png'),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Kamal Farooq',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '16 Jul, 2025 • 10:00 AM',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Stack(
            children: [
              CarouselSlider.builder(
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, itemIndex, pageViewIndex) {
                  return Image.network(widget.imageUrls[itemIndex],
                      fit: BoxFit.cover);
                },
                options: CarouselOptions(
                  viewportFraction: 1.0,
                  height: 200,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
              if (widget.isActive && showArrows)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        currentIndex =
                            (currentIndex - 1 + widget.imageUrls.length) %
                                widget.imageUrls.length;
                      });
                    },
                  ),
                ),
              if (widget.isActive && showArrows)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white),
                    onPressed: () {
                      setState(() {
                        currentIndex =
                            (currentIndex + 1) % widget.imageUrls.length;
                      });
                    },
                  ),
                ),
              PositionedDirectional(
                start: MediaQuery.of(context).size.width * .45,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(50)),
                  child: Text(
                      "${currentIndex + 1}/${(widget.imageUrls.length + 1).toString()}"),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_up, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('16.1K'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.comment, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('1.3K comments'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('128 Fame'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
