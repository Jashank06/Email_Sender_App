import 'package:flutter/material.dart';

enum PageTransitionType {
  fade,
  slide,
  scale,
  rotation,
  slideUp,
}

class PageTransition extends PageRouteBuilder {
  final Widget child;
  final PageTransitionType type;
  final Duration duration;
  final Curve curve;

  PageTransition({
    required this.child,
    this.type = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (type) {
              case PageTransitionType.fade:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              
              case PageTransitionType.slide:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: child,
                );
              
              case PageTransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: child,
                );
              
              case PageTransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              
              case PageTransitionType.rotation:
                return RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
            }
          },
        );
}

// Custom Combined Transition
class CustomPageTransition extends PageRouteBuilder {
  final Widget child;

  CustomPageTransition({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.1);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: child,
                ),
              ),
            );
          },
        );
}
