import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_supabase_zegocloud_chat_app/screens/NewChatScreen.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/CustomDrawer.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'SettingScreen.dart';

final supabase = Supabase.instance.client;

class HomeScreen extends StatefulWidget {

  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Optional: Check Supabase login and auto-login to ZIMKit
  var user = supabase.auth.currentUser;

  Future<void> refreshUserData() async {
    await supabase.auth.refreshSession();
    setState(() {
      user = supabase.auth.currentUser; // Update user state
    });
  }

  @override
  void initState() {
    super.initState();

    _initZIMUser(); // async method called without await
  }

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  /// Fetch image from gallery.
  Future<void> getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Fetch image from camera.
  Future<void> getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _initZIMUser() async {
    if (user != null) {
      final zimUserID = user?.userMetadata?['email']?.split('@')[0];
      await ZIMKit().connectUser(
        id: zimUserID ?? 'guest',
        name: user?.userMetadata?['name'] ?? 'NoName',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: getImageFromCamera,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingScreen(title: 'Settings'),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'New Group', child: Text('New Group')),
              const PopupMenuItem(value: 'New Broadcast', child: Text('New Broadcast')),
              const PopupMenuItem(value: 'Linked Devices', child: Text('Linked Devices')),
              const PopupMenuItem(value: 'Payments', child: Text('Payments')),
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      drawer: CustomDrawer(parentContext: context),
      body: ZIMKitConversationListView(
        // onPressed: () {},
        itemBuilder: (context, conversation, defaultWidget) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(conversation.id[0].toUpperCase()),
            ),
            title: Text(conversation.id),
            subtitle: Text(conversation.lastMessage?.textContent?.text ?? "No message yet"),
            // trailing: Text(
            //   conversation.lastMessage != null
            //       ? TimeOfDay.fromDateTime(
            //       DateTime.fromMillisecondsSinceEpoch(conversation.updatedAt!))
            //       .format(context)
            //       : '',
            //   style: TextStyle(fontSize: 12),
            // ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ZIMKitMessageListPage(
                    conversationID: conversation.id,
                    conversationType: conversation.type,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewChatScreen(title: 'New Chat')),
          );
        },
        child: const Icon(Icons.add_circle),
        tooltip: 'View Users',
      ),
    );
  }
}