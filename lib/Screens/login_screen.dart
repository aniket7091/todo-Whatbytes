import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo/components/custom_text_field.dart';
import 'package:todo/core/constants/app_colors.dart';
import '../components/CheckIllustration.dart';
import '../components/social_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final error = authProvider.errorMessage ?? 'Login failed. Please check your credentials.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: emailController.text.trim());
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text(
                'Reset Password',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your registered email address to receive password reset instructions.',
                    style: TextStyle(fontSize: 13, color: AppColors.lightText),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hint: 'Enter your email',
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.lightText)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(100, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSending
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty) return;

                          setDialogState(() => isSending = true);
                          final auth = context.read<AuthProvider>();
                          final success = await auth.sendPasswordResetEmail(email);

                          if (!mounted) return;
                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Password reset email sent! Please check your inbox.'
                                    : (auth.errorMessage ?? 'Failed to send reset email.'),
                              ),
                              backgroundColor: success ? AppColors.success : AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                  child: isSending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send Link', style: TextStyle(fontSize: 13, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final scale = (screenWidth / 390).clamp(0.9, 1.15);
          final horizontalPadding = screenWidth * 0.09;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.08),

                      // Illustration
                      Transform.scale(
                        scale: scale,
                        child: const CheckIllustration(),
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // Heading
                      Text(
                        "Welcome back !",
                        style: TextStyle(
                          fontSize: 26 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.06),

                      // Email label
                      _buildLabel("EMAIL ADDRESS"),
                      const SizedBox(height: 8),

                      // Email field
                      CustomTextField(
                        hint: "Enter your email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        textInputAction: TextInputAction.next,
                      ),

                      SizedBox(height: 24 * scale),

                      // Password label + Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel("PASSWORD"),
                          GestureDetector(
                            onTap: _showForgotPasswordDialog,
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8 * scale),

                      // Password field
                      CustomTextField(
                        hint: "Enter your password",
                        controller: passwordController,
                        obscureText: obscurePassword,
                        validator: _validatePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.lightText,
                            size: 19 * scale,
                          ),
                        ),
                      ),

                      SizedBox(height: 40 * scale),

                      // Login button
                      SizedBox(
                        width: 140 * scale,
                        height: 48 * scale,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Log in",
                                  style: TextStyle(
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 25 * scale),

                      // Social text
                      Text(
                        "or sign in with",
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: AppColors.lightText,
                        ),
                      ),

                      SizedBox(height: 18 * scale),

                      // Social buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialButton(
                            color: const Color(0xFF365899),
                            onTap: () {},
                            child: Text(
                              "f",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 18 * scale),
                          SocialButton(
                            color: const Color(0xFFDB4437),
                            onTap: () {},
                            child: Text(
                              "G",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 18 * scale),
                          SocialButton(
                            color: Colors.black,
                            onTap: () {},
                            child: Icon(
                              Icons.apple,
                              color: Colors.white,
                              size: 27 * scale,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 35 * scale),

                      // Signup navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 13 * scale,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/signup');
                            },
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30 * scale),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.lightText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
