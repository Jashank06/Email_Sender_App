import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_text_field.dart';
import '../widgets/page_transition.dart';
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
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: AppTheme.secondaryBlack,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.primaryBlack,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
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
        _showError('PLEASE ENTER YOUR NAME');
        return;
      }
      if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
        debugPrint('Signup validation failed: Email invalid');
        _showError('PLEASE ENTER A VALID EMAIL');
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        debugPrint('Signup validation failed: Phone empty');
        _showError('PLEASE ENTER YOUR PHONE NUMBER');
        return;
      }
      if (_dobController.text.trim().isEmpty) {
        debugPrint('Signup validation failed: DOB empty');
        _showError('PLEASE SELECT YOUR DATE OF BIRTH');
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
          CustomPageTransition(
            child: OtpScreen(
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
        _showError('PLEASE ENTER A VALID EMAIL');
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
          CustomPageTransition(
            child: OtpScreen(
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
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Animated Logo (Monochrome)
                Hero(
                  tag: 'app_logo',
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.15),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.email_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Animated Title
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Column(
                          children: [
                            const Text(
                              'EMAIL SENDER PRO',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'PREMIUM DISPATCH STATION',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentWhite.withOpacity(0.4),
                                letterSpacing: 4.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 50),
                
                // Auth Form Card with 3D Flip Animation
                AnimatedBuilder(
                  animation: _flipController,
                  builder: (context, child) {
                    final angle = _flipController.value * math.pi;
                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
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
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAuthForm(AuthProvider authProvider) {
    return GlassmorphicCard(
      blur: 30,
      opacity: 0.04,
      borderRadius: 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle buttons with improved design
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton('LOGIN', !_isSignup),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildToggleButton('SIGNUP', _isSignup),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Form fields with AnimatedTextField
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  if (_isSignup) ...[
                    AnimatedTextField(
                      controller: _nameController,
                      label: 'FULL NAME',
                      hint: 'John Doe',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  AnimatedTextField(
                    controller: _emailController,
                    label: 'EMAIL ADDRESS',
                    hint: 'john@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  if (_isSignup) ...[
                    const SizedBox(height: 24),
                    AnimatedTextField(
                      controller: _phoneController,
                      label: 'PHONE NUMBER',
                      hint: '+1 234 567 8900',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    AnimatedTextField(
                      controller: _dobController,
                      label: 'DATE OF BIRTH',
                      hint: 'Select your birth date',
                      prefixIcon: Icons.calendar_today_outlined,
                      suffixIcon: Icons.expand_more_rounded,
                      onSuffixTap: _selectDate,
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Submit button with loading state
            AnimatedButton(
              onPressed: authProvider.isLoading ? null : _handleAuth,
              text: _isSignup ? 'CREATE ACCOUNT' : 'SECURE LOGIN',
              icon: _isSignup ? Icons.add_moderator_outlined : Icons.lock_open_rounded,
              isLoading: authProvider.isLoading,
            ),
            
            const SizedBox(height: 32),
            
            // Toggle text with better design
            Center(
              child: GestureDetector(
                onTap: _toggleMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: _isSignup ? 'EXISTING USER? ' : "NEW USER? ",
                      style: TextStyle(
                        color: AppTheme.accentWhite.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: _isSignup ? 'LOG IN' : 'SIGN UP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
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
  
  Widget _buildToggleButton(String text, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isActive) _toggleMode();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.primaryGradient : null,
              color: isActive ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryBlack : Colors.white60,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}
