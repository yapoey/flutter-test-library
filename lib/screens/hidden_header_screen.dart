import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/custom_calendar.dart';

class HideHeaderScreen extends StatefulWidget {
  const HideHeaderScreen({super.key});

  @override
  State<HideHeaderScreen> createState() => _HideHeaderScreenState();
}

class _HideHeaderScreenState extends State<HideHeaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool areHeadersVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_toggleHeaderVisibility);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_toggleHeaderVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleHeaderVisibility() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      // Scrolling up - show headers
      if (!areHeadersVisible) {
        setState(() {
          areHeadersVisible = true;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      // Scrolling down - hide headers
      if (areHeadersVisible) {
        setState(() {
          areHeadersVisible = false;
        });
      }
    }
  }
  void _showFullScreenDatePicker() async {
    DateTime? selectedDate =  await showCustomCalendar(context: context);

    if (selectedDate != null) {
      _scrollController.jumpTo(0);
    }
  }

  void _goToTop() {
    _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverAppBar(
            backgroundColor: Colors.orange,
            expandedHeight: 100.0,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Timeline"),
            ),
          ),
          SliverAppBar(
            elevation: 0,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            expandedHeight: 100.0,
            floating: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 30),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.add, size: 24)),
                        const Text("New post"),
                        const SizedBox(width: 10),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey,
                        ),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.add, size: 24)),
                        const Text("New event"),
                      ],
                    ),
                    PopupMenuButton<String>(
                      position: PopupMenuPosition.under,
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'goToTop') {
                          _goToTop();
                        } else if (value == 'selectDate') {
                          _showFullScreenDatePicker();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'goToTop',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_upward),
                              Text("Go to Top"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'selectDate',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today),
                              Text("Select Date"),
                            ],
                          ),
                        ),
                      ],
                      child: OutlinedButton.icon(
                        onPressed: null, // Expandable menu opens on button tap
                        icon: const Text(
                          "Latest",
                          style: TextStyle(color: Colors.black),
                        ),
                        label: const Icon(Icons.arrow_drop_down, color: Colors.black),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                title: Text("Post #$index"),
              ),
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
