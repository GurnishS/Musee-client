import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;


  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 500;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 500 && MediaQuery.of(context).size.width < 1000;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return mobile;
    } else if (Responsive.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return desktop;
    }
  }
}