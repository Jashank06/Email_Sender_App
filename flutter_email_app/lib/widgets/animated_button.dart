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
                  borderRadius: BorderRadius.circular(20),
                  gradient: widget.isGradient
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.onPressed == null || widget.isLoading
                              ? [
                                  Colors.white24,
                                  Colors.white10,
                                ]
                              : _isPressed
                                  ? [
                                      const Color(0xFFE0E0E0),
                                      const Color(0xFFB0B0B0),
                                    ]
                                  : [
                                      AppTheme.accentWhite,
                                      const Color(0xFFE0E0E0),
                                    ],
                        )
                      : null,
                  color: !widget.isGradient
                      ? AppTheme.glassWhite
                      : null,
                  boxShadow: [
                    if (widget.onPressed != null && !widget.isLoading) ...[
                      // Main Glow
                      BoxShadow(
                        color: Colors.white.withOpacity(_isPressed ? 0.1 : 0.25),
                        blurRadius: _shadowAnimation.value,
                        spreadRadius: _isHovered ? 2 : 0,
                      ),
                      // 3D Bottom Shadow
                      if (!_isPressed)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                          spreadRadius: -5,
                        ),
                    ],
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(widget.isGradient ? 0.5 : 0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
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
                                  const SizedBox(width: 10),
                                ],
                                Text(
                                  widget.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isGradient
                                        ? AppTheme.primaryBlack
                                        : AppTheme.accentWhite,
                                    letterSpacing: 1.5,
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
