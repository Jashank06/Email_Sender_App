import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_button.dart';
import 'otp_screen.dart';
import 'package:intl/intl.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isSignup = true;
  late AnimationController _glowController;
  late AnimationController _flipController;
  bool _isToggled = false;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipController.addListener(() {
      if (_flipController.value >= 0.5 && !_isToggled) {
        setState(() {
          _isSignup = !_isSignup;
          _isToggled = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _flipController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }
  
  void _toggleMode() {
    if (_flipController.isAnimating) return;
    _isToggled = false;
    _flipController.forward(from: 0).then((_) {
      _flipController.reset();
    });
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.glowPurple,
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
  
  Future<void> _handleAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    debugPrint('Auth button tapped. IsSignup: $_isSignup');
    
    if (_isSignup) {
      debugPrint('Validating signup form...');
      // Signup validation
      if (_nameController.text.trim().isEmpty) {
        debugPrint('Signup validation failed: Name empty');
        _showError('Please enter your name');
        return;
      }
      if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
        debugPrint('Signup validation failed: Email invalid');
        _showError('Please enter a valid email');
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        debugPrint('Signup validation failed: Phone empty');
        _showError('Please enter your phone number');
        return;
      }
      if (_dobController.text.trim().isEmpty) {
        debugPrint('Signup validation failed: DOB empty');
        _showError('Please select your date of birth');
        return;
      }
      
      debugPrint('Sending signup OTP for: ${_emailController.text}');
      // Send OTP for signup
      final success = await authProvider.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
      );
      
      debugPrint('Signup OTP result: $success');
      
      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: _emailController.text.trim(),
              isSignup: true,
            ),
          ),
        );
      } else if (mounted && authProvider.error != null) {
        debugPrint('Auth error: ${authProvider.error}');
        _showError(authProvider.error!);
      }
    } else {
      debugPrint('Validating login form...');
      // Login validation
      if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
        debugPrint('Login validation failed: Email invalid');
        _showError('Please enter a valid email');
        return;
      }
      
      debugPrint('Sending login OTP for: ${_emailController.text}');
      // Send OTP for login
      final success = await authProvider.login(
        email: _emailController.text.trim(),
      );
      
      debugPrint('Login OTP result: $success');
      
      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: _emailController.text.trim(),
              isSignup: false,
            ),
          ),
        );
      } else if (mounted && authProvider.error != null) {
        debugPrint('Auth error: ${authProvider.error}');
        _showError(authProvider.error!);
      }
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
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
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
              left: -100,
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
                          AppTheme.glowPurple.withOpacity(0.3 * _glowController.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -150,
              right: -150,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.glowBlue.withOpacity(0.3 * (1 - _glowController.value)),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo and Title
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.glowPurple.withOpacity(0.3),
                            AppTheme.glowBlue.withOpacity(0.3),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.glowPurple.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.email_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Email Sender Pro',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [AppTheme.glowPurple, AppTheme.glowBlue],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    Text(
                      'Send beautiful emails effortlessly',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Auth Form Card
                    AnimatedBuilder(
                      animation: _flipController,
                      builder: (context, child) {
                        final angle = _flipController.value * math.pi;
                        final transform = Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle);
                        
                        return Transform(
                          transform: transform,
                          alignment: Alignment.center,
                          child: angle <= math.pi / 2 
                            ? _buildAuthForm(authProvider) 
                            : Transform(
                                transform: Matrix4.identity()..rotateY(math.pi),
                                alignment: Alignment.center,
                                child: _buildAuthForm(authProvider),
                              ),
                        );
                      },
                    ),
                  ],
                ),
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
  
  Widget _buildAuthForm(AuthProvider authProvider) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle buttons
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton('Login', !_isSignup),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleButton('Signup', _isSignup),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Form fields
            if (_isSignup) ...[
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                hint: 'John Doe',
              ),
              const SizedBox(height: 16),
            ],
            
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              hint: 'john@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            
            if (_isSignup) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                hint: '+1 234 567 8900',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dobController,
                label: 'Date of Birth',
                icon: Icons.cake_outlined,
                hint: 'YYYY-MM-DD',
                readOnly: true,
                onTap: _selectDate,
              ),
            ],
            
            const SizedBox(height: 30),
            
            // Submit button
            AnimatedButton(
              onPressed: authProvider.isLoading ? null : _handleAuth,
              text: _isSignup ? 'Get OTP' : 'Login with OTP',
            ),
            
            const SizedBox(height: 20),
            
            // Toggle text
            Center(
              child: TextButton(
                onPressed: _toggleMode,
                child: RichText(
                  text: TextSpan(
                    text: _isSignup ? 'Already have an account? ' : "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: _isSignup ? 'Login' : 'Signup',
                        style: TextStyle(
                          color: AppTheme.glowPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToggleButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) _toggleMode();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [AppTheme.glowPurple, AppTheme.glowBlue],
                )
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
              ),
              prefixIcon: Icon(icon, color: AppTheme.glowPurple),
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
