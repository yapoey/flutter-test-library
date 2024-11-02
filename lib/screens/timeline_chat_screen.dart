import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TimelineChatScreen extends StatefulWidget {
  const TimelineChatScreen({super.key});

  @override
  State<TimelineChatScreen> createState() => _TimelineChatScreenState();
}

class _TimelineChatScreenState extends State<TimelineChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isHeaderVisible = true;
  bool isMainHeaderVisible = true;

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

  List<String> chatTypes = ["Contacts", "Groups", "Communications"];
  String selectedType = "Contacts";
  String mainTitle = "Chats";

  void _toggleHeaderVisibility() {
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double middlePosition = maxScrollExtent / 2;
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse){
      setState(() {
        isMainHeaderVisible = false;
        mainTitle = selectedType;
      });
    }else if (_scrollController.offset == 0){
      setState(() {
        isMainHeaderVisible = true;
        mainTitle = "Chats";
      });
    }
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if ((_scrollController.offset >= middlePosition - 10 &&
              _scrollController.offset <= middlePosition + 10) &&
          isHeaderVisible) {
        setState(() {
          isHeaderVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!isHeaderVisible &&
          (_scrollController.offset >= middlePosition - 10 &&
              _scrollController.offset <= middlePosition + 10)) {
        setState(() {
          isHeaderVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(mainTitle),
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            leading: const SizedBox(),
            backgroundColor: Colors.white,
            expandedHeight: 100.0,
            floating: false,
            pinned: isMainHeaderVisible,
            flexibleSpace: FlexibleSpaceBar(
              background: Row(
                children: chatTypes
                    .map(
                      (e) => Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = e;
                              });
                            },
                            child: Container(
                                padding:  const EdgeInsets.symmetric(vertical: 40),
                                color: selectedType == e
                                    ? Colors.orange
                                    : Colors.white,
                                child: Center(
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ))),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          SliverAppBar(
            leading: const SizedBox(),
            backgroundColor: Colors.blue,
            expandedHeight: 100.0,
            floating: true,
            pinned: isHeaderVisible,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text("Active contacts"),
              centerTitle: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text("Chat #$index"),
              ),
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
