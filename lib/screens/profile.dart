import 'dart:io';

import 'package:tjarik/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tjarik/services/profile_service.dart';
import 'package:tjarik/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjarik/widgets/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  File? _pickedFile;
  bool _isSaving = false;
  bool _initialized = false;
  int _currentNavIndex = 4;

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;
    setState(() {
      _pickedFile = File(xfile.path);
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await ProfileService().updateProfile(
        newName: _nameController.text,
        newPhotoFile: _pickedFile,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F8FA),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
      body: Stack(
        children: [

          // Top header with title
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 28, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Manage your profile",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          // Bottom card with content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 160),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF7F8FA),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      child: StreamBuilder<UserModel>(
                        stream: ProfileService().getCurrentUserProfile(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error loading profile: ${snapshot.error}',
                              ),
                            );
                          }

                          final userProfile = snapshot.data;
                          if (userProfile == null) {
                            return const Center(
                              child: Text('Profile not found'),
                            );
                          }

                          // initialize controller once
                          if (!_initialized) {
                            _nameController.text = userProfile.name ?? '';
                            _initialized = true;
                          }

                          return Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _pickedFile != null
                                        ? FileImage(_pickedFile!)
                                              as ImageProvider
                                        : (userProfile.profileUrl != null
                                              ? NetworkImage(
                                                  userProfile.profileUrl!,
                                                )
                                              : null),
                                    child:
                                        (_pickedFile == null &&
                                            userProfile.profileUrl == null)
                                        ? const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E6FE8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: _pickImage,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: "Full Name",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1E6FE8),
                                      width: 2.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      userProfile.email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 42,
                                      child: OutlinedButton(
                                        onPressed: _isSaving
                                            ? null
                                            : () => logout(context),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFF1E6FE8),
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Color(0xFF1E6FE8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SizedBox(
                                      height: 42,
                                      child: ElevatedButton(
                                        onPressed: _isSaving
                                            ? null
                                            : _saveProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1E6FE8,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        child: _isSaving
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Text('Save'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
