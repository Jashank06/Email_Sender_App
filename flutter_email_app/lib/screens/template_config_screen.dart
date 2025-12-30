import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/email_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import 'send_email_screen.dart';

class TemplateConfigScreen extends StatefulWidget {
  const TemplateConfigScreen({super.key});

  @override
  State<TemplateConfigScreen> createState() => _TemplateConfigScreenState();
}

class _TemplateConfigScreenState extends State<TemplateConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _templateController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Set default template
    _templateController.text = '''<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
  <h2>Hello {{name}},</h2>
  <p>I hope this email finds you well.</p>
  <p>This is a personalized email sent to {{email}}.</p>
  <p>Best regards,<br>Your Team</p>
</div>''';
  }
  
  @override
  void dispose() {
    _senderNameController.dispose();
    _subjectController.dispose();
    _templateController.dispose();
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
                              'Email Template',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Customize your email content',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 32),
                            
                            _buildSenderNameInput(),
                            
                            const SizedBox(height: 20),
                            
                            _buildSubjectInput(),
                            
                            const SizedBox(height: 20),
                            
                            _buildTemplateInput(),
                            
                            const SizedBox(height: 24),
                            
                            _buildVariablesCard(),
                            
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
            'Step 3 of 3',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.accentWhite.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSenderNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sender Name (Optional)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _senderNameController,
          style: const TextStyle(color: AppTheme.accentWhite),
          decoration: const InputDecoration(
            hintText: 'Your Name or Company Name',
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.glowBlue),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildSubjectInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Subject',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectController,
          style: const TextStyle(color: AppTheme.accentWhite),
          decoration: const InputDecoration(
            hintText: 'Hello {{name}}!',
            prefixIcon: Icon(Icons.subject_outlined, color: AppTheme.glowBlue),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email subject';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildTemplateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Template (HTML)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _templateController,
          maxLines: 10,
          style: const TextStyle(color: AppTheme.accentWhite, fontSize: 12),
          decoration: const InputDecoration(
            hintText: 'Enter your HTML email template',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 150),
              child: Icon(Icons.code_outlined, color: AppTheme.glowBlue),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email template';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildVariablesCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.glowPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code, color: AppTheme.glowPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Available Variables',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVariableChip('{{name}}', 'Contact name'),
          const SizedBox(height: 8),
          _buildVariableChip('{{email}}', 'Contact email'),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildVariableChip(String variable, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.glowBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              variable,
              style: const TextStyle(
                color: AppTheme.glowBlue,
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContinueButton(BuildContext context) {
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
          onTap: () => _handleContinue(context),
          child: Center(
            child: Row(
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
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
  
  void _handleContinue(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<EmailProvider>();
    provider.setSenderName(_senderNameController.text.trim());
    provider.setSubject(_subjectController.text.trim());
    provider.setTemplate(_templateController.text.trim());
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SendEmailScreen()),
    );
  }
}
