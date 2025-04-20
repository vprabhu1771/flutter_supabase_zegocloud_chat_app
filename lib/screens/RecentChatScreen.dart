import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

final supabase = Supabase.instance.client;

class RecentChatScreen extends StatefulWidget {
  const RecentChatScreen({super.key});

  @override
  State<RecentChatScreen> createState() => _RecentChatScreenState();
}

class _RecentChatScreenState extends State<RecentChatScreen> {

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
      appBar: AppBar(title: const Text('Recent Chats')),
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
    );
  }
}
