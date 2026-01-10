import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_text_field.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isEditing = false;
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dobController = TextEditingController(text: user?.dateOfBirth ?? '');
    
    if (user?.dateOfBirth != null) {
      try {
        _selectedDate = DateTime.parse(user!.dateOfBirth);
      } catch (e) {
        _selectedDate = null;
      }
    }
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentPurple,
              onPrimary: Colors.white,
              surface: AppTheme.primaryBlack,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.primaryBlack,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Name cannot be empty');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Phone cannot be empty');
      return;
    }
    if (_dobController.text.trim().isEmpty) {
      _showError('Date of birth cannot be empty');
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
    );
    
    if (success && mounted) {
      _showSuccess('Profile updated successfully!');
      setState(() {
        _isEditing = false;
      });
    } else if (mounted && authProvider.error != null) {
      _showError(authProvider.error!);
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryBlack,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: AnimatedBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'AGENT PROFILE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _isEditing ? Colors.white : Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                              color: _isEditing ? Colors.black : Colors.white,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_isEditing) {
                                  _nameController.text = user.name;
                                  _phoneController.text = user.phone;
                                  _dobController.text = user.dateOfBirth;
                                }
                                _isEditing = !_isEditing;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Profile Avatar
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.05),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ).animate().scale(delay: 200.ms),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            user.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 4.0,
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          
                          Text(
                            user.email.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.3),
                              letterSpacing: 1.5,
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                          
                          const SizedBox(height: 48),
                          
                          // Profile Info Card
                          GlassmorphicCard(
                            borderRadius: 24,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildProfileField(
                                    label: 'AGENT DESIGNATION',
                                    icon: Icons.person_rounded,
                                    controller: _nameController,
                                    enabled: _isEditing,
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  _buildProfileField(
                                    label: 'COMMUNICATION NODE',
                                    icon: Icons.alternate_email_rounded,
                                    value: user.email.toUpperCase(),
                                    enabled: false,
                                    hint: 'PROTOCOL: IMMUTABLE',
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  _buildProfileField(
                                    label: 'SECURE LINE',
                                    icon: Icons.phone_rounded,
                                    controller: _phoneController,
                                    enabled: _isEditing,
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  _buildProfileField(
                                    label: 'ACTIVATION DATE',
                                    icon: Icons.event_rounded,
                                    controller: _dobController,
                                    enabled: _isEditing,
                                    readOnly: true,
                                    onTap: _isEditing ? _selectDate : null,
                                  ),
                                  
                                  if (_isEditing) ...[
                                    const SizedBox(height: 40),
                                    AnimatedButton(
                                      onPressed: authProvider.isLoading ? null : _saveProfile,
                                      text: 'UPDATE PROTOCOL',
                                      icon: Icons.verified_user_rounded,
                                      isLoading: authProvider.isLoading,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                          
                          const SizedBox(height: 24),
                          
                          // Logout Button
                          GlassmorphicCard(
                            borderRadius: 24,
                            opacity: 0.05,
                            child: InkWell(
                              onTap: _logout,
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      child: const Icon(
                                        Icons.power_settings_new_rounded,
                                        color: Colors.white30,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    const Text(
                                      'TERMINATE SESSION',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white12,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    String? value,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white24,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              width: enabled ? 1.0 : 0.5,
            ),
          ),
          child: value != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              : TextField(
                  controller: controller,
                  readOnly: readOnly || !enabled,
                  onTap: onTap,
                  enabled: enabled,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.1),
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
        ),
      ],
    );
  }
}
