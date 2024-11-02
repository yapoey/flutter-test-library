import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HideHeaderExample extends StatefulWidget {

  const HideHeaderExample({super.key});

  @override
  State<HideHeaderExample> createState() => _HideHeaderExampleState();
}

class _HideHeaderExampleState extends State<HideHeaderExample> {
  final ScrollController _scrollController = ScrollController();
  bool? isHeaderVisible;
  bool? isLatestVisible;
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
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double middlePosition = maxScrollExtent / 2;
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if ((_scrollController.offset >= middlePosition - 10 && _scrollController.offset <= middlePosition + 10) && (isHeaderVisible ?? true)) {
        setState(() {
          isHeaderVisible = false;
          isLatestVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!(isHeaderVisible ?? true) && (_scrollController.offset >= middlePosition - 10 && _scrollController.offset <= middlePosition + 10)) {
        setState(() {
          isLatestVisible = true;
        });
      }
    }
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
            backgroundColor: Colors.blue,
            expandedHeight: 100.0,
            floating: false,
            pinned: isHeaderVisible ?? true,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text("Add post"),
            ),
          ),
           SliverAppBar(
             elevation: 0,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            expandedHeight: 50.0,
            floating: true,
            pinned: isLatestVisible ?? true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle:true,
              title: ElevatedButton(onPressed: (){
                _scrollController.jumpTo(0);
              }, child: const Text("Latest")),
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
