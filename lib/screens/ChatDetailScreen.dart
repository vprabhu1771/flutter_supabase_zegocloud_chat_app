import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zego_zimkit/zego_zimkit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zim/zego_zim.dart';

class ChatDetailScreen extends StatefulWidget {
  final String peerUserId;
  final String peerUserName;

  const ChatDetailScreen({
    super.key,
    required this.peerUserId,
    required this.peerUserName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  String currentUserId = '';
  String currentUserName = '';
  final TextEditingController _messageController = TextEditingController();

  // Define your AI bot ID and name
  final String aiBotUserId = 'ai_bot';
  final String aiBotUserName = 'AI Bot';

  @override
  void initState() {
    super.initState();
    final currentUser = ZIMKit().currentUser();
    currentUserId = currentUser?.baseInfo.userID ?? 'unknown';
    currentUserName = currentUser?.baseInfo.userName ?? 'User';
  }

  void startVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoUIKitPrebuiltCall(
          appID: int.parse(dotenv.env['ZEGOCLOUD_APP_ID'] ?? '0'),
          appSign: dotenv.env['ZEGOCLOUD_APP_SIGN'] ?? '',
          userID: currentUserId,
          userName: currentUserName,
          callID: widget.peerUserId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
        ),
      ),
    );
  }

  void startVoiceCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoUIKitPrebuiltCall(
          appID: int.parse(dotenv.env['ZEGOCLOUD_APP_ID'] ?? '0'),
          appSign: dotenv.env['ZEGOCLOUD_APP_SIGN'] ?? '',
          userID: currentUserId,
          userName: currentUserName,
          callID: widget.peerUserId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
        ),
      ),
    );
  }

  Future<void> sendUserMessage() async {
    final userText = _messageController.text.trim();
    if (userText.isEmpty) return;


    // Send user's message to peer (or AI bot)
    await ZIMKit().sendTextMessage(
      widget.peerUserId,
      ZIMConversationType.peer,
      userText,
    );

    _messageController.clear();

    // Show "AI is typing..." snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("AI is typing...")),
    );

    print("${dotenv.env['FLASK_API_URL']}/chatbot");

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['FLASK_API_URL']}/chatbot'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'message': userText}),
      );

      print(response);

      print("peer user id ${widget.peerUserId}");
      print("current user id ${currentUserId}");

      if (response.statusCode == 200) {
        final aiReply = jsonDecode(response.body)['reply'];

        await ZIMKit().sendTextMessage(
          widget.peerUserId,
          ZIMConversationType.peer,
          aiReply
          // type: ZIMMessageType.text,

        );
      } else {
        throw Exception("Failed to get response");
      }
    } catch (e) {
      await ZIMKit().sendTextMessage(
        widget.peerUserId,
        ZIMConversationType.peer,
        'AI Error: Could not respond.',
        // type: ZIMMessageType.text,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUserName),
        actions: [
          IconButton(icon: Icon(Icons.videocam), onPressed: startVideoCall),
          IconButton(icon: Icon(Icons.call), onPressed: startVoiceCall),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ZIMKitMessageListPage(
              conversationID: widget.peerUserId,
              conversationType: ZIMConversationType.peer,
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => sendUserMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendUserMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
