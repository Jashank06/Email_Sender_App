import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_button.dart';
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
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlack,
              AppTheme.secondaryBlack,
              AppTheme.primaryBlack,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background orbs
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentPurple.withOpacity(0.3 * _glowController.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isEditing) {
                                // Cancel editing - reset values
                                _nameController.text = user.name;
                                _phoneController.text = user.phone;
                                _dobController.text = user.dateOfBirth;
                              }
                              _isEditing = !_isEditing;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Profile Avatar
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentPurple,
                                      AppTheme.accentBlue,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentPurple.withOpacity(0.5 * _glowController.value),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryBlack,
                                  ),
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Profile Info Card
                          GlassmorphicCard(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildProfileField(
                                    label: 'Full Name',
                                    icon: Icons.person_outline,
                                    controller: _nameController,
                                    enabled: _isEditing,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  _buildProfileField(
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    value: user.email,
                                    enabled: false,
                                    hint: 'Email cannot be changed',
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  _buildProfileField(
                                    label: 'Phone Number',
                                    icon: Icons.phone_outlined,
                                    controller: _phoneController,
                                    enabled: _isEditing,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  _buildProfileField(
                                    label: 'Date of Birth',
                                    icon: Icons.cake_outlined,
                                    controller: _dobController,
                                    enabled: _isEditing,
                                    readOnly: true,
                                    onTap: _isEditing ? _selectDate : null,
                                  ),
                                  
                                  if (_isEditing) ...[
                                    const SizedBox(height: 30),
                                    
                                    AnimatedButton(
                                      onPressed: authProvider.isLoading ? null : _saveProfile,
                                      text: 'Save Changes',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Logout Button
                          GlassmorphicCard(
                            child: InkWell(
                              onTap: _logout,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Loading overlay
            if (authProvider.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
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
              size: 20,
              color: AppTheme.accentPurple,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: value != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                )
              : TextField(
                  controller: controller,
                  readOnly: readOnly || !enabled,
                  onTap: onTap,
                  enabled: enabled,
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
