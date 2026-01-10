import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/theme.dart';

class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final VoidCallback? onTap;
  final bool enableTapAnimation;
  
  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 20,
    this.blur = 10,
    this.opacity = 0.1,
    this.onTap,
    this.enableTapAnimation = true,
  });

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _elevationAnimation = Tween<double>(begin: 0.1, end: 0.3).animate(
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
        onTapDown: widget.enableTapAnimation ? (_) => _controller.forward() : null,
        onTapUp: (_) {
          if (widget.enableTapAnimation) _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: widget.enableTapAnimation ? () => _controller.reverse() : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enableTapAnimation ? _scaleAnimation.value : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: _isHovered 
                        ? Colors.white.withOpacity(0.4)
                        : Colors.white.withOpacity(0.15),
                    width: _isHovered ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    // Outer Glow
                    BoxShadow(
                      color: Colors.white.withOpacity(_isHovered ? 0.05 : 0.02),
                      blurRadius: _isHovered ? 40 : 20,
                      offset: Offset(0, _isHovered ? 20 : 10),
                      spreadRadius: _isHovered ? 5 : 0,
                    ),
                    // 3D depth effect (Bottom shadow)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 15),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blur + 5, 
                      sigmaY: widget.blur + 5,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(widget.opacity + 0.05),
                            Colors.white.withOpacity(widget.opacity),
                            Colors.white.withOpacity(widget.opacity * 0.2),
                          ],
                        ),
                      ),
                      padding: widget.padding ?? const EdgeInsets.all(20),
                      child: widget.child,
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
