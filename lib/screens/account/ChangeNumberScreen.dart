import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangeNumberScreen extends StatefulWidget {

  final String title;

  const ChangeNumberScreen({super.key, required this.title});

  @override
  _ChangeNumberScreenState createState() => _ChangeNumberScreenState();
}

class _ChangeNumberScreenState extends State<ChangeNumberScreen> {
  final supabase = Supabase.instance.client;
  final user = Supabase.instance.client.auth.currentUser;
  final _formKey = GlobalKey<FormState>();

  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneController.text = user?.userMetadata?['phone'] ?? '';
  }

  Future<void> updateUser() async {
    if (_formKey.currentState!.validate()) {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'phone': phoneController.text
          },
        ),
      );

      Navigator.pop(context, true); // Return true on success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Enter your phone number" : null,
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: updateUser,
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}