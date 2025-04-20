import 'package:flutter/material.dart';

class StatusScreen extends StatefulWidget {
  final String title;

  const StatusScreen({super.key, required this.title});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final List<Map<String, dynamic>> statuses = [
    {'name': 'My Status', 'time': 'Just now', 'isViewed': false},
    {'name': 'Alice', 'time': '10 mins ago', 'isViewed': false},
    {'name': 'John', 'time': 'Today, 8:30 AM', 'isViewed': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Text("Recent Updates", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          SizedBox(height: 10),
          ...statuses.map((status) => _buildStatusTile(status)).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusTile(Map<String, dynamic> status) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: status['isViewed'] ? Colors.grey[400] : Colors.green,
        child: CircleAvatar(
          radius: 23,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.black),
        ),
      ),
      title: Text(status['name'], style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(status['time']),
      onTap: () {
        // Open status view screen
      },
    );
  }
}