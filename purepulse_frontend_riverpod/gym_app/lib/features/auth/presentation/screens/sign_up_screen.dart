// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final success = await _authService.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (success && mounted) {
          context.goNamed(RouteConstants.onboardingName);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              text: 'PURE',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'PULSE',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Create Account',
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start your fitness journey today',
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Full Name',
                            label: 'Full Name',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                            validator: Validators.validateName,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Email address',
                            label: 'Email',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            label: 'Password',
                            isPassword: true,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                            validator: Validators.validatePassword,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            CustomButton(
                              text: 'Sign Up',
                              onPressed: _handleSignUp,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: RichText(
                              text: const TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
