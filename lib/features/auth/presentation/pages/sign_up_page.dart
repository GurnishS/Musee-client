import 'package:musee/core/common/widgets/loader.dart';
import 'package:musee/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:musee/features/auth/presentation/constants/auth_constants.dart';
import 'package:musee/features/auth/presentation/constants/auth_icons.dart';
import 'package:musee/features/auth/presentation/mixins/auth_animation_mixin.dart';
import 'package:musee/features/auth/presentation/widgets/auth_form_components.dart';
import 'package:musee/features/auth/presentation/widgets/auth_responsive_layout.dart';
import 'package:musee/features/auth/presentation/utils/auth_form_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  final String redirectUrl;
  const SignUpPage({super.key, required this.redirectUrl});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with TickerProviderStateMixin, AuthPageAnimationMixin {
  @override
  void initState() {
    super.initState();
    initializeMainAnimations();
  }

  @override
  void dispose() {
    disposeMainAnimations();
    super.dispose();
  }

  void _handleAuthSuccess() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(widget.redirectUrl);
      }
    });
  }

  void _handleAuthFailure(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            _handleAuthFailure(state.message);
          } else if (state is AuthSuccess) {
            _handleAuthSuccess();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthSuccess) {
            return const Loader();
          }

          return AuthResponsiveLayout(
            fadeAnimation: fadeAnimation,
            slideAnimation: slideAnimation,
            scaleAnimation: scaleAnimation,
            formContent: const SignUpFormContent(),
          );
        },
      ),
    );
  }
}

class SignUpFormContent extends StatefulWidget {
  const SignUpFormContent({super.key});

  @override
  State<SignUpFormContent> createState() => _SignUpFormContentState();
}

class _SignUpFormContentState extends State<SignUpFormContent>
    with TickerProviderStateMixin, AuthStaggerAnimationMixin {
  @override
  void initState() {
    super.initState();
    initializeStaggerAnimations(7); // Number of animated elements
  }

  @override
  void dispose() {
    disposeStaggerAnimations();
    super.dispose();
  }

  void _handleResendEmailVerificationFailure(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetAuthState() {
    context.read<AuthBloc>().add(ResetAuthState());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthResendEmailVerificationFailure) {
          _handleResendEmailVerificationFailure(state.message);
        }
      },
      builder: (context, state) {
        if (state is EmailVerification) {
          return EmailVerificationView(onBack: _resetAuthState, state: state);
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AuthConstants.largePadding),
                buildAnimatedWidget(0, _buildTitle(context)),
                const SizedBox(height: 8),
                buildAnimatedWidget(1, _buildSubtitle(context)),
                const SizedBox(height: 16),
                buildAnimatedWidget(2, _buildDescription(context)),
                const SizedBox(height: AuthConstants.largePadding),
                buildAnimatedWidget(3, const SignUpForm()),
                const SizedBox(height: AuthConstants.largePadding),
                buildAnimatedWidget(4, _buildDivider(context)),
                const SizedBox(height: 16),
                buildAnimatedWidget(5, _buildSocialButtons(context)),
                const SizedBox(height: AuthConstants.defaultPadding),
                buildAnimatedWidget(6, _buildNavigationText(context)),
                const SizedBox(height: AuthConstants.largePadding),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text("Sign Up", style: AuthTextStyles.title(context));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text("Create Account", style: AuthTextStyles.subtitle(context));
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      "Create your account to get started\nwith our amazing app",
      textAlign: TextAlign.center,
      style: AuthTextStyles.description(context),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return const AuthDivider(text: "Or continue with");
  }

  Widget _buildSocialButtons(BuildContext context) {
    return AuthSocialButtonRow(
      onGooglePressed: () =>
          context.read<AuthBloc>().add(AuthSignInWithGoogle()),
    );
  }

  Widget _buildNavigationText(BuildContext context) {
    return AuthNavigationText(
      text: "Already have an account? ",
      linkText: "Sign In",
      onLinkPressed: () => context.go("/sign-in"),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  late final AuthFormControllers _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = AuthFormControllers();
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    final formData = _controllers.formData;
    if (!formData.hasAllFields) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AuthConstants.emptyFieldsMessage)),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignUp(
        name: formData.name!,
        email: formData.email,
        password: formData.password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthInputField(
            controller: _controllers.nameController,
            hintText: "Enter your name",
            labelText: "Name",
            iconSvg: AuthIcons.name,
            textInputAction: TextInputAction.next,
            validator: AuthFormValidator.validateName,
          ),
          const SizedBox(height: AuthConstants.defaultPadding),
          AuthInputField(
            controller: _controllers.emailController,
            hintText: "Enter your email",
            labelText: "Email",
            iconSvg: AuthIcons.email,
            textInputAction: TextInputAction.next,
            validator: AuthFormValidator.validateEmail,
          ),
          const SizedBox(height: AuthConstants.defaultPadding),
          AuthInputField(
            controller: _controllers.passwordController,
            hintText: "Enter your password",
            labelText: "Password",
            iconSvg: AuthIcons.lock,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: AuthFormValidator.validatePassword,
          ),
          const SizedBox(height: AuthConstants.largePadding),
          AuthPrimaryButton(text: "Continue", onPressed: _handleSignUp),
        ],
      ),
    );
  }
}

class EmailVerificationView extends StatelessWidget {
  final VoidCallback onBack;
  final EmailVerification state;

  const EmailVerificationView({
    super.key,
    required this.onBack,
    required this.state,
  });

  void _handleResendEmail(BuildContext context) {
    context.read<AuthBloc>().add(AuthResendEmailVerification(state.email));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AuthConstants.largePadding),
        AuthBackHeader(title: "Verify Email", onBack: onBack),
        const SizedBox(height: AuthConstants.largePadding),
        _buildEmailIcon(context),
        const SizedBox(height: AuthConstants.defaultPadding),
        _buildTitle(context),
        const SizedBox(height: 16),
        _buildDescription(),
        const SizedBox(height: 8),
        _buildEmailText(context),
        const SizedBox(height: 16),
        _buildInstructions(),
        const SizedBox(height: 16),
        _buildResendButton(context),
        const SizedBox(height: AuthConstants.largePadding),
      ],
    );
  }

  Widget _buildEmailIcon(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(40),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Icon(
        Icons.email_outlined,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      "Check your email",
      style: AuthTextStyles.title(context).copyWith(fontSize: 20),
    );
  }

  Widget _buildDescription() {
    return const Text(
      AuthConstants.emailSentMessage,
      style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailText(BuildContext context) {
    return Text(
      state.email,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInstructions() {
    return const Text(
      AuthConstants.verificationInstructions,
      style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildResendButton(BuildContext context) {
    final isLoading = state is AuthResendEmailVerificationLoading;
    final canResend = state is! AuthResendEmailVerificationLoading;

    return AuthPrimaryButton(
      text: AuthConstants.resendEmailText,
      onPressed: canResend ? () => _handleResendEmail(context) : null,
      isLoading: isLoading,
    );
  }
}
