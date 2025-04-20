import 'package:flutter/material.dart';

import 'ChangeNumberScreen.dart';
import 'PasskeyScreen.dart';

class AccountSettingScreen extends StatefulWidget {

  final String title;

  const AccountSettingScreen({super.key, required this.title});

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.phone_iphone, color: Colors.teal),
            title: const Text("Change Number"),
            onTap: () {
              // Navigate to Notifications Settings
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeNumberScreen(title: 'Change Number'))
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.key_sharp, color: Colors.teal),
            title: const Text("Passkeys"),
            onTap: () {
              // Navigate to Notifications Settings
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasskeyScreen())
              );
            },
          ),
        ],
      ),
    );
  }
}