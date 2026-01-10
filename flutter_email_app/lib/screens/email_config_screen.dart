import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/email_provider.dart';
import '../providers/auth_provider.dart';
import '../models/email_config.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_text_field.dart';
import '../widgets/animated_button.dart';
import 'sheet_config_screen.dart';

class EmailConfigScreen extends StatefulWidget {
  const EmailConfigScreen({super.key});

  @override
  State<EmailConfigScreen> createState() => _EmailConfigScreenState();
}

class _EmailConfigScreenState extends State<EmailConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedProvider = 'gmail';
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _emailController.text = user.savedEmail;
      _passwordController.text = user.savedPassword;
      _selectedProvider = user.savedProvider.isNotEmpty ? user.savedProvider : 'gmail';
    }
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: AnimatedBackground(
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Custom app bar
                  _buildAppBar(context),
                  
                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Title
                            const Text(
                              'EMAIL PROTOCOL',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'CONFIGURE STATION COMMUNICATION CHANNEL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentWhite.withOpacity(0.4),
                                letterSpacing: 1.5,
                              ),
                            ).animate()
                              .fadeIn(delay: 100.ms)
                              .slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 48),
                            
                            // Provider selection
                            _buildProviderSelection(),
                            
                            const SizedBox(height: 32),
                            
                            // Email input
                            _buildEmailInput(),
                            
                            const SizedBox(height: 24),
                            
                            // Password input
                            _buildPasswordInput(),
                            
                            const SizedBox(height: 32),
                            
                            // Info card
                            _buildInfoCard(),
                            
                            const SizedBox(height: 48),
                            
                            // Continue button
                            _buildContinueButton(context),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Loading overlay
            Consumer<EmailProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return _buildLoadingOverlay();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
}

  Widget _buildAppBar(BuildContext context) {
    return Padding(
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
          Text(
            'STEP 01 / 03',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.accentWhite.withOpacity(0.3),
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProviderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT PROVIDER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.accentWhite.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildProviderOption('gmail', 'GMAIL', Icons.mail_outline_rounded),
            const SizedBox(width: 16),
            _buildProviderOption('outlook', 'OUTLOOK', Icons.alternate_email_rounded),
          ],
        ),
      ],
    );
  }
  
  Widget _buildProviderOption(String value, String label, IconData icon) {
    final isSelected = _selectedProvider == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedProvider = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.3),
            border: Border.all(
              color: isSelected 
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white24,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : Colors.white24,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmailInput() {
    return AnimatedTextField(
      controller: _emailController,
      label: 'STATION EMAIL',
      hint: _selectedProvider == 'gmail' ? 'STATION@GMAIL.COM' : 'STATION@OUTLOOK.COM',
      prefixIcon: Icons.alternate_email_rounded,
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildPasswordInput() {
    return AnimatedTextField(
      controller: _passwordController,
      label: 'APP PASSWORD',
      hint: '••••••••••••••••',
      obscureText: true,
      prefixIcon: Icons.vpn_key_rounded,
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildInfoCard() {
    return GlassmorphicCard(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Colors.white30,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedProvider == 'gmail'
                    ? 'SECURITY: USE GOOGLE APP PASSWORD FOR AUTHENTICATION'
                    : 'SECURITY: OUTLOOK APP PASSWORDS REQUIRED FOR STATION ACCESS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentWhite.withOpacity(0.3),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContinueButton(BuildContext context) {
    return Consumer<EmailProvider>(
      builder: (context, provider, _) {
        return AnimatedButton(
          onPressed: provider.isLoading ? null : () => _handleContinue(context),
          text: 'VERIFY STATION',
          icon: Icons.chevron_right_rounded,
          isLoading: provider.isLoading,
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }
  
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
            const SizedBox(height: 24),
            const Text(
              'AUTHENTICATING...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleContinue(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<EmailProvider>();
    
    final config = EmailConfig(
      provider: _selectedProvider,
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    final success = await provider.testEmailConfig(config);
    
    if (!mounted) return;
    
    if (success) {
      // Auto-save credentials to user profile
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      if (user != null) {
        await authProvider.updateProfile(
          name: user.name,
          phone: user.phone,
          dateOfBirth: user.dateOfBirth,
          savedEmail: _emailController.text.trim(),
          savedPassword: _passwordController.text,
          savedProvider: _selectedProvider,
        );
      }

      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SheetConfigScreen(),
        ),
      );
    } else {
      _showSnack(provider.error?.toUpperCase() ?? 'VERIFICATION FAILED');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 12)),
        backgroundColor: Colors.black.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }
}
