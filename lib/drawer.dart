import 'package:components_test/screens/calendar_screen.dart';
import 'package:components_test/screens/emoji_selection_screen.dart';
import 'package:components_test/screens/gif_screen.dart';
import 'package:components_test/screens/gif_screen_two.dart';
import 'package:components_test/screens/hidden_header_screen.dart';
import 'package:components_test/screens/image_editing.dart';
import 'package:components_test/screens/image_editor_screen.dart';
import 'package:components_test/screens/image_swiper_screen.dart';
import 'package:components_test/screens/sticker_screen.dart';
import 'package:components_test/screens/timeline_chat_screen.dart';
import 'package:components_test/screens/voice_recorder.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Components',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Image Editor'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImageEditorScreen()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Voice recorder'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VoiceRecorderScreen()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Hide header'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HideHeaderExample()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Calendar'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DatePickerScreen()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Timeline and chat screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimelineChatScreen()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Emoji selection screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmojiSelectionScreen()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Image swiper screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const ImageSwiperScreen()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Image editing screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const ImageEditingScreen()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Gif screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const GifScreen()),
              );
            },
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: const Text('Sticker screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const StickerScreen()),
              );
            },
          ),
          // const SizedBox(height: 10,),
          // ListTile(
          //   title: const Text('Gif screen two'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) =>  const GifScreenTwo()),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}