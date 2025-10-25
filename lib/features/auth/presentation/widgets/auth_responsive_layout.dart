import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:musee/features/auth/presentation/constants/auth_constants.dart';

/// Responsive layout builder for authentication pages
class AuthResponsiveLayout extends StatelessWidget {
  final Widget formContent;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;
  final bool showLottieAnimation;

  const AuthResponsiveLayout({
    super.key,
    required this.formContent,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
    this.showLottieAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen =
              constraints.maxWidth > AuthConstants.largeScreenBreakpoint;

          if (isLargeScreen && showLottieAnimation) {
            return _buildLargeScreenLayout(context);
          } else {
            return _buildSmallScreenLayout(constraints);
          }
        },
      ),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return Row(
      children: [
        // Left half: Lottie animation
        Expanded(
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Theme.of(context).colorScheme.secondary, // Google blue
                  child: Lottie.asset(
                    'assets/animations/auth.json',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Right half: Form
        Expanded(
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuthConstants.largePadding,
                ),
                child: SingleChildScrollView(child: formContent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout(BoxConstraints constraints) {
    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AuthConstants.defaultPadding,
              vertical: 16,
            ),
            child: formContent,
          ),
        ),
      ),
    );
  }
}

/// Base scaffold for authentication pages
class AuthPageScaffold extends StatelessWidget {
  final Widget child;
  final void Function(BuildContext, Object)? onAuthSuccess;
  final void Function(BuildContext, String)? onAuthFailure;

  const AuthPageScaffold({
    super.key,
    required this.child,
    this.onAuthSuccess,
    this.onAuthFailure,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: child));
  }
}
