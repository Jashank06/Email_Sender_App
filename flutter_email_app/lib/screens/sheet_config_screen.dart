import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/email_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_text_field.dart';
import 'template_config_screen.dart';

class SheetConfigScreen extends StatefulWidget {
  const SheetConfigScreen({super.key});

  @override
  State<SheetConfigScreen> createState() => _SheetConfigScreenState();
}

class _SheetConfigScreenState extends State<SheetConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sheetIdController = TextEditingController();
  final _pasteController = TextEditingController();
  bool _useManual = false;
  List<Map<String, String>> _parsedContacts = [];
  
  @override
  void dispose() {
    _sheetIdController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  void _parsePastedText(String text) {
    if (text.trim().isEmpty) {
      setState(() => _parsedContacts = []);
      return;
    }

    final lines = text.split('\n');
    final List<Map<String, String>> contacts = [];
    
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      
      // Try to split by tab, comma, or space
      // Logic: If there's a tab, use it. If not, if there's a comma, use it. 
      // Else try to find the last space which might separate name and email.
      String name = '';
      String email = '';
      
      if (line.contains('\t')) {
        final parts = line.split('\t');
        name = parts[0].trim();
        email = parts.length > 1 ? parts[1].trim() : '';
      } else if (line.contains(',')) {
        final parts = line.split(',');
        name = parts[0].trim();
        email = parts.length > 1 ? parts[1].trim() : '';
      } else {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          email = parts.last;
          name = parts.sublist(0, parts.length - 1).join(' ');
        } else if (parts.length == 1) {
          email = parts[0];
          name = 'Recipient';
        }
      }

      // Basic email validation
      if (email.contains('@')) {
        contacts.add({'name': name, 'email': email});
      }
      
      if (contacts.length >= 100) break;
    }
    
    setState(() => _parsedContacts = contacts);
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
                              'TARGET ACQUISITION',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'ESTABLISH RECIPIENT DATA SOURCE PROTOCOL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentWhite.withOpacity(0.4),
                                letterSpacing: 1.5,
                              ),
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                            
                            const SizedBox(height: 40),
                            
                            _buildToggleButtons(),
                            
                            const SizedBox(height: 48),
                            
                            if (!_useManual) ...[
                              _buildSheetIdInput(),
                              const SizedBox(height: 32),
                              _buildInstructionsCard(),
                            ] else ...[
                              _buildManualPasteInput(),
                              const SizedBox(height: 32),
                              if (_parsedContacts.isNotEmpty) _buildPreviewCard(),
                            ],
                            
                            const SizedBox(height: 56),
                            
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

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              icon: Icons.storage_rounded,
              label: 'DATABASE',
              isSelected: !_useManual,
              onTap: () => setState(() => _useManual = false),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.data_array_rounded,
              label: 'MANUAL',
              isSelected: _useManual,
              onTap: () => setState(() => _useManual = true),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.white : Colors.transparent,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.black : Colors.white24,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.black : Colors.white24,
                fontSize: 11,
                letterSpacing: 1.5,
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
            'STEP 02 / 03',
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
  
  Widget _buildSheetIdInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATABASE IDENTIFIER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.accentWhite.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sheetIdController,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          decoration: InputDecoration(
            hintText: 'GOOGLE_SHEET_UID_HERE',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1), letterSpacing: 1.0),
            prefixIcon: const Icon(Icons.terminal_rounded, color: Colors.white24),
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
            if (!_useManual && (value == null || value.isEmpty)) {
              return 'PROTOCOL ERROR: UID REQUIRED';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildManualPasteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECIPIENT ARRAY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.accentWhite.withOpacity(0.4),
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${_parsedContacts.length} / 100 NODES',
              style: TextStyle(
                color: _parsedContacts.length > 100 ? Colors.white : AppTheme.accentWhite.withOpacity(0.2),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pasteController,
          maxLines: 8,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          onChanged: _parsePastedText,
          decoration: InputDecoration(
            hintText: 'NAME   EMAIL\nAGENT_01   CORE@TERMINAL.IO',
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
            if (_useManual && _parsedContacts.isEmpty) {
              return 'PROTOCOL ERROR: DATA ARRAY EMPTY';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildPreviewCard() {
    return GlassmorphicCard(
      borderRadius: 24,
      blur: 20,
      opacity: 0.05,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DATA PREVIEW',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _parsedContacts.length > 3 ? 3 : _parsedContacts.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 24),
              itemBuilder: (context, index) {
                final contact = _parsedContacts[index];
                return Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Center(
                        child: Text(
                          contact['name']![0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact['name']!.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            contact['email']!.toUpperCase(),
                            style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_parsedContacts.length > 3) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '+ ${_parsedContacts.length - 3} ADDITIONAL NODES',
                  style: TextStyle(color: Colors.white10, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildInstructionsCard() {
    return GlassmorphicCard(
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                  child: const Icon(Icons.info_outline_rounded, color: Colors.white24, size: 18),
                ),
                const SizedBox(width: 16),
                const Text(
                  'PROTOCOL SETUP',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInstruction('01', 'INITIALIZE SHEET WITH NAME/EMAIL HEADERS'),
            const SizedBox(height: 16),
            _buildInstruction('02', 'AUTHORIZE SERVICE AGENT NODE PERMISSIONS'),
            const SizedBox(height: 16),
            _buildInstruction('03', 'EXTRACT UNIQUE DATABASE UID FROM URL'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInstruction(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number,
          style: TextStyle(
            color: Colors.white.withOpacity(0.1),
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentWhite.withOpacity(0.4),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildContinueButton(BuildContext context) {
    return Consumer<EmailProvider>(
      builder: (context, provider, _) {
        return AnimatedButton(
          onPressed: provider.isLoading ? null : () => _handleContinue(context),
          text: 'INITIALIZE SYNC',
          icon: Icons.sync_rounded,
          isLoading: provider.isLoading,
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
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
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            const SizedBox(height: 24),
            Text(
              _useManual ? 'IMPORTING DATA...' : 'VERIFYING CONNECTION...',
              style: const TextStyle(
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
    provider.setUseManualRecipients(_useManual);
 
    if (_useManual) {
      provider.setRecipients(_parsedContacts);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TemplateConfigScreen()),
      );
      return;
    }
    
    final result = await provider.testSheetConnection(_sheetIdController.text.trim());
    
    if (!mounted) return;
    
    if (result != null && result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TemplateConfigScreen()),
      );
    } else {
      _showSnack(provider.error?.toUpperCase() ?? 'CONNECTION REFUSED');
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
