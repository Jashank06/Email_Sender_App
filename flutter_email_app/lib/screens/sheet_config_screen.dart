import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/email_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import 'template_config_screen.dart';

class SheetConfigScreen extends StatefulWidget {
  const SheetConfigScreen({super.key});

  @override
  State<SheetConfigScreen> createState() => _SheetConfigScreenState();
}

class _SheetConfigScreenState extends State<SheetConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sheetIdController = TextEditingController();
  
  @override
  void dispose() {
    _sheetIdController.dispose();
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
            _buildBackgroundOrb(top: -100, right: -100, color: AppTheme.glowBlue),
            _buildBackgroundOrb(bottom: -150, left: -150, color: AppTheme.glowPurple),
            
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Google Sheets Setup',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Connect your Google Sheet with contacts',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 32),
                            
                            _buildSheetIdInput(),
                            
                            const SizedBox(height: 24),
                            
                            _buildInstructionsCard(),
                            
                            const SizedBox(height: 32),
                            
                            _buildContinueButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
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
  
  Widget _buildBackgroundOrb({double? top, double? bottom, double? left, double? right, required Color color}) {
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
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.accentWhite),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Step 2 of 3',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.accentWhite.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSheetIdInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Google Sheet ID',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sheetIdController,
          style: const TextStyle(color: AppTheme.accentWhite),
          decoration: const InputDecoration(
            hintText: 'Paste your Google Sheet ID here',
            prefixIcon: Icon(Icons.table_chart_outlined, color: AppTheme.glowBlue),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Google Sheet ID';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildInstructionsCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.glowBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: AppTheme.glowBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Setup Instructions',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstruction('1', 'Create a Google Sheet with columns: Name, Email'),
          const SizedBox(height: 12),
          _buildInstruction('2', 'Share sheet with service account email'),
          const SizedBox(height: 12),
          _buildInstruction('3', 'Copy the Sheet ID from URL'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildInstruction(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [AppTheme.glowBlue, AppTheme.glowPurple]),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.primaryBlack,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
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
            gradient: LinearGradient(colors: [AppTheme.glowBlue, AppTheme.glowPurple]),
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
                        child: CircularProgressIndicator(color: AppTheme.primaryBlack, strokeWidth: 2),
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
                          const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryBlack),
                        ],
                      ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
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
                const CircularProgressIndicator(color: AppTheme.glowBlue),
                const SizedBox(height: 16),
                Text('Testing connection...', style: Theme.of(context).textTheme.bodyLarge),
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
    final result = await provider.testSheetConnection(_sheetIdController.text.trim());
    
    if (!mounted) return;
    
    if (result != null && result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TemplateConfigScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to connect to Google Sheets'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
