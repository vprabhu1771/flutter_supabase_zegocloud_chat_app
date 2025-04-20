import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../SettingScreen.dart';
import 'NewCallScreen.dart';

class CallHistoryScreen extends StatefulWidget {
  @override
  _CallHistoryScreenState createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  List<Map<String, dynamic>> callLogs = [
    {'name': 'John Doe', 'type': 'incoming', 'time': 'Yesterday, 10:30 AM'},
    {'name': 'Alice Smith', 'type': 'missed', 'time': 'Yesterday, 8:15 PM'},
    {'name': 'David Miller', 'type': 'outgoing', 'time': 'Today, 2:00 PM'},
  ];

  List<Map<String, dynamic>> filteredCallLogs = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false; // Track search state

  @override
  void initState() {
    super.initState();
    filteredCallLogs = List.from(callLogs);
  }

  void filterSearchResults(String query) {
    List<Map<String, dynamic>> tempSearchList = [];
    if (query.isNotEmpty) {
      tempSearchList = callLogs
          .where((call) =>
          call['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      tempSearchList = List.from(callLogs);
    }
    setState(() {
      filteredCallLogs = tempSearchList;
    });
  }

  void onMoreOptionsSelected(String value) {
    switch (value) {
      case 'clear_history':
        setState(() {
          callLogs.clear();
          filteredCallLogs.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Call history cleared!")),
        );
        break;
      case 'settings':
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Open Settings")),
      // );
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingScreen(title: 'Settings'))
        );
        break;
    }
  }

  IconData getCallIcon(String type) {
    switch (type) {
      case 'incoming':
        return LucideIcons.phoneIncoming;
      case 'outgoing':
        return LucideIcons.phoneOutgoing;
      case 'missed':
        return LucideIcons.phoneMissed;
      default:
        return Icons.phone;
    }
  }

  Color getCallIconColor(String type) {
    switch (type) {
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return Colors.blue;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSearching ? buildSearchAppBar() : buildDefaultAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredCallLogs.length,
              itemBuilder: (context, index) {
                final call = filteredCallLogs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text(call['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(call['time']),
                  trailing: Icon(getCallIcon(call['type']), color: getCallIconColor(call['type'])),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_ic_call, color: Colors.white),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewCallScreen(title: 'New Call'),
            ),
          );
        },
      ),
    );
  }

  // Default App Bar (Shows Title & Actions)
  AppBar buildDefaultAppBar() {
    return AppBar(
      title: Text('Calls', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              isSearching = true; // Activate search mode
            });
          },
        ),
        PopupMenuButton<String>(
          onSelected: onMoreOptionsSelected,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'clear_history', child: Text('Clear Call History')),
            PopupMenuItem(value: 'settings', child: Text('Settings')),
          ],
        ),
      ],
    );
  }

  // Search App Bar (Shows Search Field)
  AppBar buildSearchAppBar() {
    return AppBar(
      title: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Search calls...",
          border: InputBorder.none,
        ),
        onChanged: filterSearchResults,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            isSearching = false;
            searchController.clear();
            filterSearchResults("");
          });
        },
      ),
    );
  }
}