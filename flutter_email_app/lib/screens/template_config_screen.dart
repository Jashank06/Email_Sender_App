import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../providers/email_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_button.dart';
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
      backgroundColor: AppTheme.primaryBlack,
      body: AnimatedBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  
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
                            const Text(
                              'PAYLOAD ARCHITECT',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'CUSTOMIZE DISPATCH CONTENT PROTOCOL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentWhite.withOpacity(0.4),
                                letterSpacing: 1.5,
                              ),
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 40),
                            
                            _buildSenderNameInput(),
                            
                            const SizedBox(height: 24),
                            
                            _buildSubjectInput(),
                            
                            const SizedBox(height: 24),
                            
                            _buildTemplateInput(),
                            
                            const SizedBox(height: 32),
                            
                            _buildAttachmentsSection(),
                            
                            const SizedBox(height: 32),
                            
                            _buildVariablesCard(),
                            
                            const SizedBox(height: 48),
                            
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
            'STEP 03 / 03',
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
  
  Widget _buildSenderNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SENDER IDENTITY (OPTIONAL)',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.accentWhite.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _senderNameController,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          decoration: InputDecoration(
            hintText: 'STATION_COMMANDER_NAME',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1), letterSpacing: 1.0),
            prefixIcon: const Icon(Icons.badge_rounded, color: Colors.white24),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
            ),
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
          'DISPATCH TITLE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.accentWhite.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _subjectController,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          decoration: InputDecoration(
            hintText: 'HELLO {{NAME}}!',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1), letterSpacing: 1.0),
            prefixIcon: const Icon(Icons.title_rounded, color: Colors.white24),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'PROTOCOL ERROR: TITLE REQUIRED';
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
          'PAYLOAD ARCHITECT (HTML)',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.accentWhite.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _templateController,
          maxLines: 12,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: 'ENTER SOURCE CODE...',
            hintStyle: TextStyle(color: Colors.white10, letterSpacing: 1.0),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'PROTOCOL ERROR: PAYLOAD EMPTY';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildAttachmentsSection() {
    return Consumer<EmailProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PAYLOAD ATTACHMENTS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentWhite.withOpacity(0.4),
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '${provider.attachments.length} / 10 OBJECTS',
                  style: TextStyle(
                    color: AppTheme.accentWhite.withOpacity(0.2),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassmorphicCard(
              borderRadius: 24,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Add attachment button
                    AnimatedButton(
                      onPressed: () => _pickFiles(provider),
                      text: 'ATTACH OBJECTS',
                      icon: Icons.add_circle_outline_rounded,
                    ),
                    
                    // Show attached files
                    if (provider.attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...provider.attachments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return _buildAttachmentItem(file, index, provider);
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'LIMIT: 25MB PER OBJECT • ALL ARCHIVE TYPES SUPPORTED',
              style: TextStyle(
                color: AppTheme.accentWhite.withOpacity(0.15),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        );
      },
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildAttachmentItem(File file, int index, EmailProvider provider) {
    final fileName = file.path.split('/').last;
    final fileSize = _formatFileSize(file.lengthSync());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.file_present_rounded, color: Colors.white30, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fileSize.toUpperCase(),
                  style: TextStyle(color: Colors.white12, fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white24, size: 18),
            onPressed: () => provider.removeAttachment(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  Future<void> _pickFiles(EmailProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            final fileSize = File(file.path!).lengthSync();
            
            if (fileSize > 25 * 1024 * 1024) {
              _showSnack('${file.name} EXCEEDS 25MB LIMIT');
              continue;
            }
            
            if (provider.attachments.length >= 10) {
              _showSnack('PROTOCOL LIMIT: 10 OBJECTS');
              break;
            }
            
            provider.addAttachment(File(file.path!));
          }
        }
      }
    } catch (e) {
      _showSnack('PROTOCOL ERROR: FILE ACCESS DENIED');
    }
  }
  
  Widget _buildVariablesCard() {
    return GlassmorphicCard(
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Colors.white24, size: 18),
                ),
                const SizedBox(width: 16),
                const Text(
                  'COMPUTED VARIABLES',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildVariableChip('{{NAME}}', 'DYNAMIC RECIPIENT IDENTITY'),
            const SizedBox(height: 8),
            _buildVariableChip('{{EMAIL}}', 'DYNAMIC RECIPIENT NODE'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVariableChip(String variable, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              variable,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            description,
            style: TextStyle(color: AppTheme.accentWhite.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContinueButton(BuildContext context) {
    return AnimatedButton(
      onPressed: () => _handleContinue(context),
      text: 'FINALIZE DEPLOYMENT',
      icon: Icons.rocket_launch_rounded,
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
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
