import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:musee/features/auth/presentation/constants/auth_constants.dart';
import 'package:musee/features/auth/presentation/constants/auth_icons.dart';

/// Reusable input field for authentication forms
class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String iconSvg;
  final bool obscureText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.iconSvg,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallHeight = screenHeight < 700;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: AuthTextStyles.hint(context),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AuthConstants.defaultPadding,
          vertical: isSmallHeight ? 12 : 16,
        ),
        suffix: SvgPicture.string(iconSvg),
        border: AuthInputBorders.defaultBorder,
        enabledBorder: AuthInputBorders.defaultBorder,
        focusedBorder: AuthInputBorders.focusedBorder(context),
      ),
    );
  }
}

/// Primary button for authentication actions
class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AuthButtonStyles.primaryButton(context),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}

/// Social login button (Google, Anonymous, etc.)
class AuthSocialButton extends StatelessWidget {
  final String iconSvg;
  final VoidCallback onPressed;

  const AuthSocialButton({
    super.key,
    required this.iconSvg,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(16),
          height: AuthConstants.iconContainerSize,
          width: AuthConstants.iconContainerSize,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline.withAlpha(100),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.string(iconSvg),
        ),
      ),
    );
  }
}

/// Back button with title layout
class AuthBackHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const AuthBackHeader({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Expanded(
          child: Text(
            title,
            style: AuthTextStyles.title(context),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: AuthConstants.extraLargePadding),
      ],
    );
  }
}

/// Divider with text in the middle
class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AuthTextStyles.description(context).copyWith(fontSize: 14),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Row of social login buttons
class AuthSocialButtonRow extends StatelessWidget {
  final VoidCallback onGooglePressed;

  const AuthSocialButtonRow({
    super.key,
    required this.onGooglePressed
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AuthSocialButton(iconSvg: AuthIcons.google, onPressed: onGooglePressed),
      ],
    );
  }
}

/// Navigation text at the bottom of forms
class AuthNavigationText extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onLinkPressed;

  const AuthNavigationText({
    super.key,
    required this.text,
    required this.linkText,
    required this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        TextButton(
          onPressed: onLinkPressed,
          child: Text(linkText, style: AuthTextStyles.link(context)),
        ),
      ],
    );
  }
}
