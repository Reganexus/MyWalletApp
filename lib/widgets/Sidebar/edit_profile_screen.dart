import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mywallet/models/profile.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/utils/Design/color_utils.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final bool hasPin;
  const EditProfileScreen({super.key, this.hasPin = true});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late FocusNode _usernameFocusNode;
  Uint8List? _avatarBytes;
  late Color _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _usernameFocusNode = FocusNode();

    _usernameFocusNode.addListener(() {
      setState(() {});
    });

    _avatarBytes = profile?.profileImage;
    _selectedColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : ColorUtils.availableColors.first;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _avatarBytes = result.files.first.bytes);
      }
    } catch (e) {
      debugPrint("File pick error: $e");
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
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

      await provider.updateProfile(profile); // assuming async update
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/change-pin-starter',
        (route) => false,
      );
    } catch (e) {
      debugPrint("Failed to save profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save profile: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
        automaticallyImplyLeading: widget.hasPin,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar & camera overlay
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage:
                      _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                  backgroundColor: baseColor.withAlpha(230),
                  child:
                      _avatarBytes == null
                          ? Icon(
                            Icons.person,
                            size: 70,
                            color: Theme.of(context).colorScheme.surface,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Username input
            TextField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              decoration: buildInputDecoration(
                "Username",
                color: baseColor,
                isFocused: _usernameFocusNode.hasFocus,
                prefixIcon: const Icon(Icons.person),
                context: context,
              ),
            ),
            const SizedBox(height: 24),
            // Color picker
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Theme Color",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
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

            const SizedBox(height: 24),
            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: baseColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                        : const Text(
                          "Save Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
