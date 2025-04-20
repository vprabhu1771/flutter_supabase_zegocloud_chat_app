import 'package:flutter/material.dart';
import 'package:flutter_supabase_zegocloud_chat_app/screens/HomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'StatusScreen.dart';
import 'call/CallHistoryScreen.dart';

final SupabaseClient _supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final String userName = user?.userMetadata?['name'] ?? 'User';

    final List<Widget> _screens = [
      // RecentChatScreen(title: 'Chat $userName'),
      HomeScreen(title: 'Recent Chats'),
      StatusScreen(title: 'Status'),
      // CallScreen(userID: '', userName: '', callID: '', ),
      CallHistoryScreen()
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Call',
          ),
        ],
      ),
    );
  }
}