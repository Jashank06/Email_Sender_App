import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_background.dart';
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
      body: AnimatedBackground(
        child: Stack(
          children: [
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
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
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // 3D Lock icon with Monochrome Glow
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1 * _glowController.value),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(_rotateController.value * 2 * math.pi),
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.all(25),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black,
                                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.black,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.lock_rounded,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Title
                          const Text(
                            'VERIFICATION',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 4.0,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Subtitle
                          Text(
                            'SECURE CODE DISPATCHED TO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentWhite.withOpacity(0.4),
                              letterSpacing: 2.0,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            widget.email.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          
                          const SizedBox(height: 50),
                          
                          // OTP Input fields
                          GlassmorphicCard(
                            blur: 30,
                            opacity: 0.04,
                            borderRadius: 32,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (index) {
                                      return _buildOtpField(index);
                                    }),
                                  ),
                                  
                                  const SizedBox(height: 50),
                                  
                                  // Verify button
                                  AnimatedButton(
                                    onPressed: authProvider.isLoading ? null : _verifyOtp,
                                    text: 'VERIFY STATION',
                                    icon: Icons.verified_user_rounded,
                                    isLoading: authProvider.isLoading,
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Resend OTP
                                  GestureDetector(
                                    onTap: authProvider.isLoading ? null : _resendOtp,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'NO CODE? ',
                                          style: TextStyle(
                                            color: AppTheme.accentWhite.withOpacity(0.4),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.5,
                                          ),
                                          children: const [
                                            TextSpan(
                                              text: 'RESEND',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
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
                          ),
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
  
  Widget _buildOtpField(int index) {
    return Container(
      width: 45,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? Colors.white.withOpacity(0.8)
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          if (_focusNodes[index].hasFocus)
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          showCursor: false,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (value.length == 1) {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
                _verifyOtp();
              }
            } else if (value.isEmpty) {
              if (index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            }
            setState(() {}); // Update border color
          },
        ),
      ),
    );
  }
}
