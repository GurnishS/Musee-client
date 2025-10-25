import 'package:flutter/material.dart';
import 'package:musee/features/auth/presentation/constants/auth_constants.dart';

/// Mixin for page-level animations (fade, slide, scale)
mixin AuthPageAnimationMixin<T extends StatefulWidget>
    on TickerProviderStateMixin<T> {
  late AnimationController _mainAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;

  void initializeMainAnimations() {
    _mainAnimationController = AnimationController(
      duration: AuthConstants.mainAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: AuthConstants.fadeInCurve),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimationController,
            curve: const Interval(0.2, 1.0, curve: AuthConstants.elasticCurve),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.8, curve: AuthConstants.elasticCurve),
      ),
    );

    // Only forward animation if widget is still mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mainAnimationController.forward();
      }
    });
  }

  void disposeMainAnimations() {
    _mainAnimationController.dispose();
  }
}

/// Mixin for staggered form animations
mixin AuthStaggerAnimationMixin<T extends StatefulWidget>
    on TickerProviderStateMixin<T> {
  late AnimationController _staggerController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  List<Animation<Offset>> get slideAnimations => _slideAnimations;
  List<Animation<double>> get fadeAnimations => _fadeAnimations;

  void initializeStaggerAnimations(int elementCount) {
    _staggerController = AnimationController(
      duration: AuthConstants.staggerAnimationDuration,
      vsync: this,
    );

    _slideAnimations = List.generate(elementCount, (index) {
      double start = index * 0.08;
      double end = (0.35 + (index * 0.07)).clamp(0.0, 1.0);

      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: AuthConstants.slideInCurve),
        ),
      );
    });

    _fadeAnimations = List.generate(elementCount, (index) {
      double start = index * 0.08;
      double end = (0.3 + (index * 0.07)).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: AuthConstants.fadeInCurve),
        ),
      );
    });

    // Only forward animation if widget is still mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _staggerController.forward();
      }
    });
  }

  Widget buildAnimatedWidget(int index, Widget child) {
    if (index >= _slideAnimations.length ||
        index >= _fadeAnimations.length ||
        !mounted ||
        (!_staggerController.isCompleted && _staggerController.value == 0.0)) {
      return child;
    }

    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(opacity: _fadeAnimations[index], child: child),
    );
  }

  void disposeStaggerAnimations() {
    _staggerController.dispose();
  }
}
