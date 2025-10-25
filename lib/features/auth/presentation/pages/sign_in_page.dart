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

class SignInPage extends StatefulWidget {
  final String redirectUrl;
  final bool newSignUp;
  const SignInPage({
    super.key,
    required this.redirectUrl,
    required this.newSignUp,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
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
          } else if (state is AuthPasswordResetEmailSentFailure) {
            _handleAuthFailure(state.message);
          } else if (state is AuthSuccess) {
            _handleAuthSuccess();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthSuccess) {
            return const Loader();
          } else if (state is PasswordReset) {
            return AuthResponsiveLayout(
              fadeAnimation: fadeAnimation,
              slideAnimation: slideAnimation,
              scaleAnimation: scaleAnimation,
              formContent: ForgetPasswordView(
                onBack: () {
                  context.read<AuthBloc>().add(ResetAuthState());
                },
                state: state,
              ),
            );
          }

          return AuthResponsiveLayout(
            fadeAnimation: fadeAnimation,
            slideAnimation: slideAnimation,
            scaleAnimation: scaleAnimation,
            formContent: SignInFormContent(newSignUp: widget.newSignUp),
          );
        },
      ),
    );
  }
}

class SignInFormContent extends StatefulWidget {
  final bool newSignUp;
  const SignInFormContent({super.key, required this.newSignUp});

  @override
  State<SignInFormContent> createState() => _SignInFormContentState();
}

class _SignInFormContentState extends State<SignInFormContent>
    with TickerProviderStateMixin, AuthStaggerAnimationMixin {
  @override
  void initState() {
    super.initState();
    initializeStaggerAnimations(6); // Number of animated elements
  }

  @override
  void dispose() {
    disposeStaggerAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallHeight = screenHeight < 700;

    final spacing = isSmallHeight
        ? AuthConstants.defaultPadding / 2
        : AuthConstants.largePadding;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.newSignUp) ...[
              const NewSignUpMessage(),
              SizedBox(height: isSmallHeight ? 8 : 16),
            ],
            SizedBox(height: spacing),
            buildAnimatedWidget(0, _buildTitle(context)),
            const SizedBox(height: 8),
            buildAnimatedWidget(1, _buildSubtitle(context)),
            SizedBox(height: isSmallHeight ? 8 : 16),
            buildAnimatedWidget(2, _buildDescription(context)),
            SizedBox(height: spacing),
            buildAnimatedWidget(
              3,
              SignInForm(
                onForgotPassword: () {
                  context.read<AuthBloc>().add(PasswordResetEvent());
                },
              ),
            ),
            SizedBox(height: spacing),
            buildAnimatedWidget(4, _buildDividerAndSocialButtons(context)),
            SizedBox(height: isSmallHeight ? 12 : AuthConstants.defaultPadding),
            buildAnimatedWidget(5, _buildNavigationText(context)),
            SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text("Sign In", style: AuthTextStyles.title(context));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text("Welcome Back", style: AuthTextStyles.subtitle(context));
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      "Sign in with your email and password\nor continue with social media",
      textAlign: TextAlign.center,
      style: AuthTextStyles.description(context),
    );
  }

  Widget _buildDividerAndSocialButtons(BuildContext context) {
    return Column(
      children: [
        const AuthDivider(text: "Or continue with"),
        const SizedBox(height: 16),
        AuthSocialButtonRow(
          onGooglePressed: () =>
              context.read<AuthBloc>().add(AuthSignInWithGoogle()),
        ),
      ],
    );
  }

  Widget _buildNavigationText(BuildContext context) {
    return AuthNavigationText(
      text: "Don't have an account? ",
      linkText: "Sign Up",
      onLinkPressed: () => context.go("/sign-up"),
    );
  }
}

class SignInForm extends StatefulWidget {
  final VoidCallback onForgotPassword;
  const SignInForm({super.key, required this.onForgotPassword});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
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

  void _handleSignIn() {
    if (!_formKey.currentState!.validate()) return;

    final formData = _controllers.formData;
    if (formData.email.isEmpty || formData.password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AuthConstants.emptyFieldsMessage)),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignIn(email: formData.email, password: formData.password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallHeight = screenHeight < 700;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthInputField(
            controller: _controllers.emailController,
            hintText: "Enter your email",
            labelText: "Email",
            iconSvg: AuthIcons.email,
            textInputAction: TextInputAction.next,
            validator: AuthFormValidator.validateEmail,
          ),
          SizedBox(height: isSmallHeight ? 12 : AuthConstants.defaultPadding),
          AuthInputField(
            controller: _controllers.passwordController,
            hintText: "Enter your password",
            labelText: "Password",
            iconSvg: AuthIcons.lock,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: AuthFormValidator.validatePassword,
          ),
          SizedBox(height: isSmallHeight ? 12 : 16),
          _buildForgotPasswordLink(context),
          SizedBox(height: isSmallHeight ? 12 : AuthConstants.defaultPadding),
          AuthPrimaryButton(text: "Continue", onPressed: _handleSignIn),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: widget.onForgotPassword,
          child: Text("Forgot Password?", style: AuthTextStyles.link(context)),
        ),
      ],
    );
  }
}

class NewSignUpMessage extends StatelessWidget {
  const NewSignUpMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Account created successfully! Please sign in to verify your account.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgetPasswordView extends StatefulWidget {
  final PasswordReset state;
  final VoidCallback onBack;
  const ForgetPasswordView({
    super.key,
    required this.onBack,
    required this.state,
  });

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetLink() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthSendPasswordResetEmail(_emailController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallHeight = screenHeight < 700;
    final spacing = isSmallHeight
        ? AuthConstants.defaultPadding / 2
        : AuthConstants.largePadding;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: spacing),
            AuthBackHeader(title: "Forgot Password?", onBack: widget.onBack),
            SizedBox(height: spacing),
            (widget.state is AuthPasswordResetEmailSentSuccess)
                ? const SizedBox()
                : _buildDescription(context),
            SizedBox(height: spacing),
            (widget.state is AuthPasswordResetEmailSentSuccess)
                ? _buildPasswordResetSentMessage(context)
                : _buildForm(),
            SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      "Please enter your email address. You will receive a link to create a new password via email.",
      style: AuthTextStyles.description(context),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildForm() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallHeight = screenHeight < 700;
    final spacing = isSmallHeight
        ? AuthConstants.defaultPadding / 2
        : AuthConstants.largePadding;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthInputField(
            controller: _emailController,
            hintText: "Enter your email",
            labelText: "Email",
            iconSvg: AuthIcons.email,
            textInputAction: TextInputAction.done,
            validator: AuthFormValidator.validateEmail,
          ),
          SizedBox(height: spacing),
          AuthPrimaryButton(
            text: "Send Reset Link",
            onPressed: _handleSendResetLink,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetSentMessage(BuildContext context) {
    return Column(
      children: [
        Text(
          "${AuthConstants.emailSentMessage} ${widget.state.email}.",
          style: AuthTextStyles.description(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AuthConstants.verificationInstructions,
          style: AuthTextStyles.description(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(
              AuthSendPasswordResetEmail(widget.state.email),
            );
          },
          child: Text(
            AuthConstants.resendEmailText,
            style: AuthTextStyles.link(context),
          ),
        ),
      ],
    );
  }
}
