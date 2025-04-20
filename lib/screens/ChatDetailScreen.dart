import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_zimkit/zego_zimkit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUserName),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: startVideoCall,
          ),
          IconButton(
            icon: Icon(Icons.call),
            onPressed: startVoiceCall,
          ),
        ],
      ),
      body: ZIMKitMessageListPage(
        conversationID: widget.peerUserId,
        conversationType: ZIMConversationType.peer,
      ),
    );
  }
}
