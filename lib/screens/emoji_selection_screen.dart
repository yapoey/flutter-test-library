import 'package:flutter/material.dart';

class EmojiSelectionScreen extends StatefulWidget {
  const EmojiSelectionScreen({super.key});

  @override
  State<EmojiSelectionScreen> createState() => _EmojiSelectionScreenState();
}

class _EmojiSelectionScreenState extends State<EmojiSelectionScreen> {
  bool reactionClicked = false;
  String? selectedReaction;
  String? selectedEmoji;

  final List<Map<String, dynamic>> reactions = [
    {'emoji': '👍', 'reaction': 'Like'},
    {'emoji': '❤️', 'reaction': 'Love'},
    {'emoji': '😂', 'reaction': 'Haha'},
    {'emoji': '😲', 'reaction': 'Wow'},
    {'emoji': '😢', 'reaction': 'Sad'},
    {'emoji': '😡', 'reaction': 'Angry'},
    {'emoji': '👏', 'reaction': 'Clap'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/avatar.jpg'),
                  ),
                  title: const Text('Saied Hegazy'),
                  subtitle: const Text('2 days ago'),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.yellow[700],
                    ),
                    child: const Text('Follow'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Lorem ipsum dolor sit amet consectetur. Neque varius suspendisse sagittis aliquam. '
                    'Vitae nunc posuere curabitur viverra tellus tortor sed id tellus.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20,),
                reactionClicked
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("......."),
                          Text("......."),
                          Text("......."),
                          Text("......."),
                        ],
                      )
                    : selectedReaction != null && selectedEmoji != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  reactionClicked = true;
                                });
                              },
                              child: Text(
                                selectedEmoji!,
                                style: const TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    reactionClicked = true;
                                  });
                                },
                                icon: const Icon(Icons.thumb_up)),
                          ),
              ],
            ),
            if (reactionClicked)
              PositionedDirectional(
                  bottom: 20,
                  end: 20,
                  start: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    height: 60, // Adjust height as needed
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: reactions.length,
                      itemBuilder: (context, index) {
                        final reaction = reactions[index];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedReaction = reaction['reaction'];
                              selectedEmoji = reaction['emoji'];
                              setState(() {
                                reactionClicked = false;
                              });
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              reaction['emoji'],
                              style: TextStyle(
                                fontSize: 30,
                                color:
                                    selectedReaction == reaction['reaction']
                                        ? Colors.blue
                                        : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
