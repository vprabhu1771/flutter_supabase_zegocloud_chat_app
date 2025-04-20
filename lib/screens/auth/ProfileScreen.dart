import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String about;
  final String profileImage;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.about,
    required this.profileImage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  var user = Supabase.instance.client.auth.currentUser;

  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  final _formKey = GlobalKey<FormState>(); // Form validation
  // final TextEditingController phoneController = TextEditingController();

  File? _image;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: user?.userMetadata?['name'] ?? widget.name);
    _aboutController = TextEditingController(text: user?.userMetadata?['about'] ?? widget.about);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    // phoneController.dispose();
    super.dispose();
  }

  Future<void> refreshUserData() async {
    await supabase.auth.refreshSession();
    setState(() {
      user = supabase.auth.currentUser; // Update user state
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final fileName = '${user.id}.jpg';
      final filePath = 'profile_pictures/$fileName';

      // Fetch current user metadata to get previous image path
      final userMetadata = user.userMetadata;
      final previousImageUrl = userMetadata?['image_path'];

      // Delete the previous image if it exists
      if (previousImageUrl != null) {
        final oldFilePath = previousImageUrl.split('/profile_pictures/').last;
        await supabase.storage.from('assets').remove(['profile_pictures/$oldFilePath']);
      }

      // Upload new image
      await supabase.storage.from('assets').upload(
        filePath,
        _image!,
        fileOptions: const FileOptions(upsert: true), // Enables overwrite
      );

      // Generate a new public URL with a timestamp to avoid caching issues
      final imageUrl = '${supabase.storage.from('assets').getPublicUrl(filePath)}?t=${DateTime.now().millisecondsSinceEpoch}';

      print("New Profile Image URL: $imageUrl");

      // Update user metadata with new image path
      await supabase.auth.updateUser(
        UserAttributes(data: {'image_path': imageUrl}),
      );

      // Refresh user data
      await refreshUserData();

      // Update UI
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  Future<void> updateUser() async {
    if (_formKey.currentState!.validate()) {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': _nameController.text,
            'about': _aboutController.text,
            // 'phone': phoneController.text,
          },
        ),
      );

      Navigator.pop(context, true); // Return true on success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: updateUser, // Save changes
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider
                        : (user?.userMetadata?['image_path'] != null
                        ? NetworkImage(user!.userMetadata!['image_path'])
                        : NetworkImage('https://gravatar.com/avatar/${user?.email ?? 'default'}')),
                    child: _isUploading
                        ? const CircularProgressIndicator()
                        : (_image == null && widget.profileImage.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? "Name cannot be empty" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(labelText: "About"),
                validator: (value) => value!.isEmpty ? "About cannot be empty" : null,
              ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   controller: phoneController,
              //   decoration: const InputDecoration(labelText: "Phone"),
              //   keyboardType: TextInputType.phone,
              //   validator: (value) => value!.isEmpty ? "Phone number cannot be empty" : null,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}