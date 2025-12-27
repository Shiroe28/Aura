import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;
  String? _username;
  String? _email;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final supabase = SupabaseService();
      final profile = await supabase.getProfile();
      
      print('🔍 Profile loaded: username=${profile?.username}, avatarUrl=${profile?.avatarUrl}');
      
      setState(() {
        _username = profile?.username ?? 'User';
        _email = supabase.currentUser?.email ?? '';
        _avatarUrl = profile?.avatarUrl;
        _usernameController.text = _username ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image == null) return;

      setState(() => _isLoading = true);

      // Upload to Supabase Storage
      final supabase = SupabaseService();
      final userId = supabase.currentUserId!;
      final fileExt = image.name.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Read file bytes (cross-platform)
      final bytes = await image.readAsBytes();

      // Upload to storage
      await supabase.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
          );

      // Get public URL
      final imageUrl = supabase.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      print('📸 Image uploaded: $imageUrl');

      // Update profile
      await supabase.updateProfile(_username ?? 'User', imageUrl);
      
      print('✅ Profile updated in database');

      setState(() {
        _avatarUrl = imageUrl;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}\n\nPlease create "avatars" bucket in Supabase Storage first!'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = SupabaseService();
      await supabase.updateProfile(_usernameController.text.trim(), null);
      
      setState(() {
        _username = _usernameController.text.trim();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.calmSand,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Picture
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppTheme.sage.withOpacity(0.3),
                              backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? NetworkImage('$_avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}')
                                  : null,
                              child: _avatarUrl == null || _avatarUrl!.isEmpty
                                  ? Text(
                                      (_username ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.forestGreen,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.forestGreen,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Username Field
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: AppTheme.calmSand.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Email (Read-only)
                        TextField(
                          controller: TextEditingController(text: _email),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: AppTheme.sage.withOpacity(0.1),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 24),
                        
                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Update Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Info Section
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info_outline, color: AppTheme.forestGreen),
                          title: const Text('Version'),
                          subtitle: const Text('1.0.0'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.palette_outlined, color: AppTheme.softBlue),
                          title: const Text('Theme'),
                          subtitle: const Text('Calm Growth'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await authProvider.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
