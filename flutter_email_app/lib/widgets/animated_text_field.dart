import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/theme.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentWhite.withOpacity(0.6),
                  letterSpacing: 2.0,
                ),
              ),
            ),
            
            // Text Field Container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (_isFocused)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isFocused
                            ? Colors.white.withOpacity(0.8)
                            : Colors.white.withOpacity(0.1),
                        width: _isFocused ? 1.5 : 1.0,
                      ),
                    ),
                    child: TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      maxLines: widget.maxLines,
                      validator: widget.validator,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      onTap: widget.onTap,
                      style: const TextStyle(
                        color: AppTheme.accentWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          color: AppTheme.accentWhite.withOpacity(0.35),
                          fontSize: 14,
                        ),
                        prefixIcon: widget.prefixIcon != null
                            ? Icon(
                                widget.prefixIcon,
                                color: _isFocused
                                    ? AppTheme.accentWhite
                                    : AppTheme.accentWhite.withOpacity(0.4),
                                size: 20,
                              )
                            : null,
                        suffixIcon: widget.suffixIcon != null
                            ? IconButton(
                                icon: Icon(
                                  widget.suffixIcon,
                                  color: AppTheme.accentWhite.withOpacity(0.5),
                                  size: 20,
                                ),
                                onPressed: widget.onSuffixTap,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: widget.prefixIcon != null ? 12 : 24,
                          vertical: widget.maxLines > 1 ? 16 : 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
