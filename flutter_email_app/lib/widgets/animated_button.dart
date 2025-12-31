import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isGradient;
  final double height;
  final double? width;
  
  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isGradient = true,
    this.height = 56,
    this.width,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _shadowAnimation = Tween<double>(begin: 20.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.onPressed != null && !widget.isLoading
            ? (_) {
                setState(() => _isPressed = true);
                _controller.forward();
              }
            : null,
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width ?? double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: widget.isGradient
                      ? LinearGradient(
                          colors: widget.onPressed == null || widget.isLoading
                              ? [
                                  AppTheme.glowBlue.withOpacity(0.5),
                                  AppTheme.glowPurple.withOpacity(0.5),
                                ]
                              : _isPressed
                                  ? [
                                      AppTheme.glowBlue.withOpacity(0.8),
                                      AppTheme.glowPurple.withOpacity(0.8),
                                    ]
                                  : [
                                      AppTheme.glowBlue,
                                      AppTheme.glowPurple,
                                    ],
                        )
                      : null,
                  color: !widget.isGradient
                      ? AppTheme.glassWhite
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: widget.isGradient
                          ? AppTheme.glowBlue.withOpacity(_isPressed ? 0.3 : 0.5)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: _shadowAnimation.value,
                      offset: Offset(0, _shadowAnimation.value / 2),
                      spreadRadius: _isHovered ? 2 : 0,
                    ),
                    // 3D depth effect
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: !widget.isGradient
                      ? Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: widget.onPressed != null && !widget.isLoading
                        ? () {
                            setState(() => _isPressed = false);
                            _controller.reverse();
                            widget.onPressed!();
                          }
                        : null,
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isGradient
                                      ? AppTheme.primaryBlack
                                      : AppTheme.accentWhite,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: widget.isGradient
                                        ? AppTheme.primaryBlack
                                        : AppTheme.accentWhite,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isGradient
                                        ? AppTheme.primaryBlack
                                        : AppTheme.accentWhite,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
