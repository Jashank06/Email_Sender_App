import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/email_provider.dart';
import '../models/email_config.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
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
  Widget build(BuildContext context) {
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
            // Background orbs
            _buildBackgroundOrb(
              top: -100,
              right: -100,
              color: AppTheme.glowBlue,
            ),
            _buildBackgroundOrb(
              bottom: -150,
              left: -150,
              color: AppTheme.glowPurple,
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Custom app bar
                  _buildAppBar(context),
                  
                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Configure Email',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Choose your email provider and enter credentials',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ).animate()
                              .fadeIn(delay: 100.ms)
                              .slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 32),
                            
                            // Provider selection
                            _buildProviderSelection(),
                            
                            const SizedBox(height: 24),
                            
                            // Email input
                            _buildEmailInput(),
                            
                            const SizedBox(height: 20),
                            
                            // Password input
                            _buildPasswordInput(),
                            
                            const SizedBox(height: 32),
                            
                            // Info card
                            _buildInfoCard(),
                            
                            const SizedBox(height: 32),
                            
                            // Continue button
                            _buildContinueButton(context),
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
  
  Widget _buildBackgroundOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.accentWhite,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Step 1 of 3',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.accentWhite.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProviderSelection() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Provider',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProviderOption('gmail', 'Gmail', Icons.mail_rounded),
              const SizedBox(width: 16),
              _buildProviderOption('outlook', 'Outlook', Icons.email_rounded),
            ],
          ),
        ],
      ),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
                ? AppTheme.glowBlue.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.glowBlue 
                  : Colors.white.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.glowBlue : AppTheme.accentWhite,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.glowBlue : AppTheme.accentWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppTheme.accentWhite),
          decoration: InputDecoration(
            hintText: _selectedProvider == 'gmail' 
                ? 'your-email@gmail.com' 
                : 'your-email@outlook.com',
            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.glowBlue),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Password',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppTheme.accentWhite),
          decoration: InputDecoration(
            hintText: 'Enter your app password',
            prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.glowBlue),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.accentWhite.withOpacity(0.5),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your app password';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildInfoCard() {
    return GlassmorphicCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.glowBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppTheme.glowBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedProvider == 'gmail'
                  ? 'Use Gmail App Password, not your regular password'
                  : 'Use Outlook App Password for better security',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContinueButton(BuildContext context) {
    return Consumer<EmailProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppTheme.glowBlue, AppTheme.glowPurple],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.glowBlue.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: provider.isLoading ? null : () => _handleContinue(context),
              child: Center(
                child: provider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryBlack,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primaryBlack,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }
  
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: GlassmorphicCard(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppTheme.glowBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Verifying...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SheetConfigScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to verify email configuration'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
