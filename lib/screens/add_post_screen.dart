import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  AddPostScreenState createState() => AddPostScreenState();
}

class AddPostScreenState extends State<AddPostScreen> {
  final List<String> taggedPeople = ['Samy', 'Alice', 'Abdelrahman', 'Bob', 'Ella'];
  final List<String> media = [];
  List<String> audioFiles = [];
  final List<String> selectedAudioFiles = [];
  final TextEditingController thoughtsController = TextEditingController(
      text: "In the next days I’ll be doing something great with you all guys...");

  bool isExpandedTags = false;
  bool isExpandedLocation = false;
  bool isExpandedMedia = false;
  bool isExpandedAudio = false;
  bool isMultipleSelectEnabled = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImagesAndVideos() async {
    final pickedFiles = await _picker.pickMultiImage();
      setState(() {
        media.addAll(pickedFiles.map((pickedFile) => pickedFile.path));
      });
  }

  void _showAudioFilePicker() async {
    List<Map<String, String>> audioFileList = List.generate(
      10,
          (index) => {
        "name": "File name $index.mp3",
        "size": "32 MB",
        "duration": "3 min",
        "date": "23 Oct, 2025"
      },
    );
    List<String> localSelectedAudioFiles = List.from(selectedAudioFiles);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Audio files | All", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isMultipleSelectEnabled = !isMultipleSelectEnabled;
                            if (!isMultipleSelectEnabled) {
                              localSelectedAudioFiles.clear();
                            }
                          });
                        },
                        child: Text(isMultipleSelectEnabled ? "Single file" : "Multiple files"),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: audioFileList.length,
                      itemBuilder: (context, index) {
                        final file = audioFileList[index];
                        final isSelected = localSelectedAudioFiles.contains(file["name"]);

                        return ListTile(
                          leading: Icon(Icons.audiotrack, color: Colors.grey[600]),
                          title: Text(file["name"]!),
                          subtitle: Text("${file["size"]} | ${file["duration"]} | ${file["date"]}"),
                          trailing: isMultipleSelectEnabled
                              ? Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  localSelectedAudioFiles.add(file["name"]!);
                                } else {
                                  localSelectedAudioFiles.remove(file["name"]!);
                                }
                              });
                            },
                          )
                              : null,
                          onTap: () {
                            if (isMultipleSelectEnabled) {
                              setState(() {
                                if (isSelected) {
                                  localSelectedAudioFiles.remove(file["name"]!);
                                } else {
                                  localSelectedAudioFiles.add(file["name"]!);
                                }
                              });
                            } else {
                              setState(() {
                                audioFiles.add(file["name"]!);
                              });
                              Navigator.pop(context);
                              this.setState(() {});
                            }
                          },
                        );
                      },
                    ),
                  ),
                  if (isMultipleSelectEnabled)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        this.setState(() {
                          audioFiles.addAll(localSelectedAudioFiles);
                          audioFiles = audioFiles.toSet().toList();
                        });
                      },
                      child: const Text("Confirm"),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              // Share post logic
            },
            child: Text('Share', style: TextStyle(color: Colors.yellow[700])),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    leading: CircleAvatar(radius: 30,),
                    title: Text("first name"),
                    subtitle: Text("last name") ,
                  ),
                  _buildTagsSection(),
                  const SizedBox(height: 16),
                  _buildMediaSection(),
                  const SizedBox(height: 16),
                  _buildAudioSection(),
                  const SizedBox(height: 16),
                  _buildThoughtsInput(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child:  Row(children: [
              _buildAddMediaButton(),
              const SizedBox(width: 10,),
              _buildAddAudioButton(),
            ],),
          )
        ],
      ),
    );
  }
  Widget _buildTagsSection() {
    return ExpansionTile(
      title: Text('Tagged: ${taggedPeople.length}'),
      initiallyExpanded: isExpandedTags,
      onExpansionChanged: (expanded) => setState(() => isExpandedTags = expanded),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: taggedPeople.asMap().entries.map((entry) {
              int index = entry.key;
              String person = entry.value;
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                        ),
                        const SizedBox(height: 4),
                        Text(person, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          taggedPeople.removeAt(index);
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return ExpansionTile(
      title: Text('Images & Videos: ${media.length}'),
      initiallyExpanded: isExpandedMedia,
      onExpansionChanged: (expanded) => setState(() => isExpandedMedia = expanded),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: media.asMap().entries.map((entry) {
              int index = entry.key;
              String item = entry.value;
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(item)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          media.removeAt(index);
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
    return ExpansionTile(
      title: Text('Audio files: ${audioFiles.length}'),
      initiallyExpanded: isExpandedAudio,
      onExpansionChanged: (expanded) => setState(() => isExpandedAudio = expanded),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: audioFiles.asMap().entries.map((entry) {
              int index = entry.key;
              String file = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.brown[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Center(child: Icon(Icons.audiotrack, color: Colors.white)),
                        const SizedBox(height: 5),
                        Text(file.split("/").last),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          audioFiles.removeAt(index);
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildThoughtsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your thoughts :",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
        const SizedBox(height: 5,),
        TextField(
          controller: thoughtsController,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: "What's on your mind?",
            border: InputBorder.none
          ),
        ),
      ],
    );
  }

  Widget _buildAddMediaButton() {
    return IconButton(
      icon: const Icon(Icons.add_photo_alternate),
      onPressed: _pickImagesAndVideos,
    );
  }

  Widget _buildAddAudioButton() {
    return IconButton(
      icon: const Icon(Icons.audiotrack),
      onPressed: _showAudioFilePicker,
    );
  }
}
