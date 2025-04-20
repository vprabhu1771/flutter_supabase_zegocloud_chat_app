import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class NewChatScreen extends StatefulWidget {
  final String title;

  const NewChatScreen({super.key, required this.title});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final supabase = Supabase.instance.client;

  // Stream to get real-time updates
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return supabase
        .from('users')
        .stream(primaryKey: ['id']) // Real-time updates
        .map((data) {
      print("Real-time user data: $data");
      return data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUsersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              // Skip current user
              if (user['id'] == currentUser?.id) return SizedBox.shrink();

              return ListTile(
                title: Text(user['email']),
                subtitle: Text(user['phone'] ?? 'No phone'),
                leading: CircleAvatar(child: Icon(Icons.person)),
                onTap: () async {
                  final currentUserEmail = currentUser?.email ?? '';
                  final currentUserName = currentUser?.userMetadata?['name'] ?? 'Me';
                  final currentUserId = currentUserEmail.split('@')[0];

                  // Connect the current logged-in user
                  await ZIMKit().connectUser(id: currentUserId, name: currentUserName);

                  // The conversation ID is the other user's ID (peer-to-peer)
                  final peerUserId = user['email'].toString().split('@')[0];

                  // Navigate to the message list page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZIMKitMessageListPage(
                        conversationID: peerUserId,
                        conversationType: ZIMConversationType.peer,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
