import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:dopamine_menu/database/databaseHelper.dart';
import 'package:dopamine_menu/models/user.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onUserCreated;
  final UserProfile? userToEdit;

  const RegistrationScreen({super.key, required this.onUserCreated, this.userToEdit});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _dobController;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userToEdit?.name ?? '');
    _usernameController = TextEditingController(text: widget.userToEdit?.username ?? '');
    _dobController = TextEditingController(text: widget.userToEdit?.dob ?? '');
    _avatarPath = widget.userToEdit?.avatar;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedFile.path)}';
      final savedPath = p.join(directory.path, fileName);

      await File(pickedFile.path).copy(savedPath);
      setState(() => _avatarPath = savedPath);
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _saveUser() async {
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    final user = UserProfile(
      id: widget.userToEdit?.id, // Keep the ID for updates
      name: _nameController.text,
      username: _usernameController.text,
      dob: _dobController.text,
      avatar: _avatarPath ?? '',
      totalPoints: widget.userToEdit?.totalPoints ?? 0, // Preserve points
      favoriteIds: widget.userToEdit?.favoriteIds ?? [], // Preserve favorites
      lastResetDate: DateTime.now().toString().split(' ')[0],
    );

    if (widget.userToEdit == null) {
      await DatabaseHelper.instance.createUser(user);
    } else {
      await DatabaseHelper.instance.updateUser(user); // Call the update method
    }
    
    widget.onUserCreated();
    if (widget.userToEdit != null) Navigator.pop(context); // Close if editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "CREATE PROFILE",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[900],
                backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                child: _avatarPath == null 
                  ? const Icon(Icons.add_a_photo, color: Colors.white54, size: 40) 
                  : null,
              ),
            ),
            const SizedBox(height: 40),
            _buildTextField(_nameController, "Full Name"),
            const SizedBox(height: 20),
            _buildTextField(_usernameController, "Username"),
            const SizedBox(height: 20),
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: _selectDate,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Date of Birth"),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _saveUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("START MY JOURNEY", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(12)),
    );
  }
}