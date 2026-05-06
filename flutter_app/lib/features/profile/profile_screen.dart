import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/firebase_auth_service.dart';
import '../../core/utils/responsive.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  bool _saving = false;
  String _email = '';
  String _role = 'user';
  String _photoUrl = '';
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _authService.getCurrentUserProfile();

    if (data != null) {
      _nameController.text = (data['name'] ?? '').toString();
      _email = (data['email'] ?? '').toString();
      _role = (data['role'] ?? 'user').toString();
      _photoUrl = (data['photoUrl'] ?? '').toString();
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 75);
    if (image == null) return;

    setState(() {
      _pickedImage = image;
      _photoUrl = image.path;
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    final error = await _authService.updateCurrentUserProfile(
      name: _nameController.text.trim(),
      photoUrl: _photoUrl,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Profile updated successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildAvatar(bool compact) {
    final radius = compact ? 40.0 : 46.0;

    if (_pickedImage != null) {
      if (kIsWeb) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(_pickedImage!.path),
        );
      }
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(_pickedImage!.path)),
      );
    }

    if (_photoUrl.isNotEmpty && !kIsWeb) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(_photoUrl)),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF554640),
      child: Icon(
        Icons.person_rounded,
        color: const Color(0xFFFFCEB6),
        size: compact ? 36 : 42,
      ),
    );
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF342E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded, color: Colors.white),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final isTablet = Responsive.isTablet(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF221E1D),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF221E1D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF302A28),
              Color(0xFF221E1D),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = isTablet ? 680.0 : constraints.maxWidth;

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      compact ? 12 : 14,
                      horizontalPadding,
                      18,
                    ),
                    children: [
                      Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.titleSize(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      _ProfilePanel(
                        compact: compact,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(compact ? 5 : 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xAAF2A47F),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF2A47F).withOpacity(0.14),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: _buildAvatar(compact),
                            ),
                            SizedBox(height: compact ? 12 : 14),
                            TextButton(
                              onPressed: _showPickOptions,
                              child: Text(
                                'Change Photo',
                                style: TextStyle(
                                  color: const Color(0xFFFFCEB6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact ? 13.5 : 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 10 : 12,
                                vertical: compact ? 5 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2A47F).withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0x66F2A47F),
                                ),
                              ),
                              child: Text(
                                _role.toUpperCase(),
                                style: TextStyle(
                                  color: const Color(0xFFFFE6D9),
                                  fontSize: compact ? 11.5 : 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 18),
                      _SectionLabel(compact: compact, text: 'Full Name'),
                      const SizedBox(height: 8),
                      _ValueContainer(
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 14 : 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: TextStyle(
                              color: const Color(0xFFC7B9B2),
                              fontSize: compact ? 13.5 : 14.5,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: compact ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 14 : 16),
                      _SectionLabel(compact: compact, text: 'Email'),
                      const SizedBox(height: 8),
                      _ValueContainer(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: compact ? 14 : 16,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _email,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 14 : 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 18 : 20),
                      GestureDetector(
                        onTap: _saving ? null : _saveProfile,
                        child: Container(
                          height: compact ? 50 : 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE68F66), Color(0xFFF6B493)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF2A47F).withOpacity(0.28),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: Text(
                            _saving ? 'Saving...' : 'Save Changes',
                            style: TextStyle(
                              color: const Color(0xFF2B2524),
                              fontSize: compact ? 15 : 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 12),
                      OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF7C6F6A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: Size.fromHeight(compact ? 48 : 52),
                        ),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 14 : 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.child,
    required this.compact,
  });

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 20,
        compact ? 18 : 22,
        compact ? 16 : 20,
        compact ? 16 : 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3431),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xAAF2A47F), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF2A47F).withOpacity(0.10),
            blurRadius: 18,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.text,
    required this.compact,
  });

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: compact ? 14 : 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ValueContainer extends StatelessWidget {
  const _ValueContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A3431),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xAAF2A47F), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF2A47F).withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}
