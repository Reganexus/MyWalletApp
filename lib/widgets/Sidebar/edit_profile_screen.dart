import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mywallet/models/profile.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/utils/Design/color_utils.dart';
import 'package:mywallet/utils/Design/form_decoration.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:mywallet/utils/WidgetHelper/color_picker.dart';
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
    if (_usernameController.text.trim().isEmpty) {
      OverlayMessage.show(
        context,
        message: "Please enter a username",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ProfileProvider>();
      final profile =
          provider.profile?.copyWith(
            username: _usernameController.text.trim(),
            profileImage: _avatarBytes,
            colorPreference: _selectedColor.toARGB32().toString(),
          ) ??
          Profile(
            username: _usernameController.text.trim(),
            profileImage: _avatarBytes,
            colorPreference: _selectedColor.toARGB32().toString(),
          );

      await provider.updateProfile(profile); // async update

      if (!mounted) return;

      OverlayMessage.show(context, message: "Profile updated successfully!");

      if (!widget.hasPin) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/change-pin-starter',
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Failed to save profile: $e");

      if (!mounted) return;

      OverlayMessage.show(
        context,
        message: "Failed to save profile: $e",
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor:
          widget.hasPin
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor:
            widget.hasPin
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.white,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
        automaticallyImplyLeading: widget.hasPin,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Avatar & camera overlay
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage:
                              _avatarBytes != null
                                  ? MemoryImage(_avatarBytes!)
                                  : null,
                          backgroundColor: _selectedColor,
                          child:
                              _avatarBytes == null
                                  ? Icon(
                                    Icons.person,
                                    size: 70,
                                    color: theme.colorScheme.surface,
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
                              backgroundColor: theme.colorScheme.onSurface,
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: theme.colorScheme.surface,
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
                        color: _selectedColor,
                        isFocused: _usernameFocusNode.hasFocus,
                        prefixIcon: const Icon(Icons.person),
                        context: context,
                      ),
                      maxLength: 15,
                    ),

                    const SizedBox(height: 24),

                    // Color picker
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Theme Color",
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ColorPickerGrid(
                      colors: ColorUtils.availableColors,
                      selectedColor: _selectedColor,
                      onColorSelected:
                          (color) => setState(() => _selectedColor = color),
                    ),
                  ],
                ),
              ),
            ),

            // Save button at bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedColor,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
