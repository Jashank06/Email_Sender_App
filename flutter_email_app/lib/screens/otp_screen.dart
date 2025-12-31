import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_button.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final bool isSignup;
  
  const OtpScreen({
    super.key,
    required this.email,
    required this.isSignup,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  late AnimationController _glowController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  String _getOtp() {
    return _otpControllers.map((c) => c.text).join();
  }
  
  Future<void> _verifyOtp() async {
    final otp = _getOtp();
    
    if (otp.length != 6) {
      _showError('Please enter all 6 digits');
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    bool success;
    if (widget.isSignup) {
      success = await authProvider.verifySignupOtp(
        email: widget.email,
        otp: otp,
      );
    } else {
      success = await authProvider.verifyLoginOtp(
        email: widget.email,
        otp: otp,
      );
    }
    
    if (success && mounted) {
      // Navigate to home screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
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
  
  Future<void> _resendOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    bool success;
    if (widget.isSignup) {
      _showError('Please go back and signup again');
      return;
    } else {
      success = await authProvider.login(email: widget.email);
    }
    
    if (success && mounted) {
      _showSuccess('OTP sent successfully!');
      // Clear all fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } else if (mounted && authProvider.error != null) {
      _showError(authProvider.error!);
    }
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
            // 3D Rotating background effect
            ...List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  final angle = (_rotateController.value * 2 * math.pi) + (index * 2 * math.pi / 5);
                  final radius = 200.0;
                  final x = MediaQuery.of(context).size.width / 2 + radius * math.cos(angle);
                  final y = MediaQuery.of(context).size.height / 2 + radius * math.sin(angle);
                  
                  return Positioned(
                    left: x - 50,
                    top: y - 50,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            index % 2 == 0
                                ? AppTheme.accentPurple.withOpacity(0.15)
                                : AppTheme.accentBlue.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Pulsing center glow
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.5);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.accentPurple.withOpacity(0.2 * (1 - _pulseController.value)),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // 3D Lock icon with glow
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.accentPurple.withOpacity(0.4 * _glowController.value),
                                      AppTheme.accentBlue.withOpacity(0.4 * (1 - _glowController.value)),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentPurple.withOpacity(0.5 * _glowController.value),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                    BoxShadow(
                                      color: AppTheme.accentBlue.withOpacity(0.5 * (1 - _glowController.value)),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(_rotateController.value * 2 * math.pi),
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.accentPurple,
                                          AppTheme.accentBlue,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.lock_rounded,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Title
                          Text(
                            'Verify Your Email',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: [AppTheme.accentPurple, AppTheme.accentBlue],
                                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Subtitle
                          Text(
                            'We sent a 6-digit code to',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            widget.email,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                          
                          const SizedBox(height: 50),
                          
                          // OTP Input fields
                          GlassmorphicCard(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(6, (index) {
                                      return _buildOtpField(index);
                                    }),
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Verify button
                                  AnimatedButton(
                                    onPressed: authProvider.isLoading ? null : _verifyOtp,
                                    text: 'Verify & Continue',
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Resend OTP
                                  TextButton(
                                    onPressed: authProvider.isLoading ? null : _resendOtp,
                                    child: Text(
                                      'Didn\'t receive code? Resend',
                                      style: TextStyle(
                                        color: AppTheme.accentPurple,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
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
                  ),
                ],
              ),
            ),
            
            // Loading overlay
            if (authProvider.isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Verifying...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOtpField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? AppTheme.accentPurple
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: _focusNodes[index].hasFocus
            ? [
                BoxShadow(
                  color: AppTheme.accentPurple.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Last field, hide keyboard
              _focusNodes[index].unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            // Move to previous field on backspace
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
