import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mywallet/models/profile.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/utils/color_utils.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  Uint8List? _avatarBytes;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _avatarBytes = profile?.profileImage;

    if (profile?.colorPreference != null) {
      _selectedColor = Color(int.parse(profile!.colorPreference!));
    } else {
      _selectedColor = ColorUtils.availableColors.first;
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'], // restrict to image types
        withData: true, // ensures we get bytes directly
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _avatarBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      debugPrint("File pick error: $e");
    }
  }

  void _saveProfile() {
    final provider = context.read<ProfileProvider>();
    final profile =
        provider.profile?.copyWith(
          username: _usernameController.text,
          profileImage: _avatarBytes,
          colorPreference: _selectedColor.toARGB32().toString(),
        ) ??
        Profile(
          username: _usernameController.text,
          profileImage: _avatarBytes,
          colorPreference: _selectedColor.toARGB32().toString(),
        );

    provider.updateProfile(profile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(onPressed: _saveProfile, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage:
                    _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                child:
                    _avatarBytes == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Color",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  ColorUtils.availableColors.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 20,
                        child:
                            _selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
