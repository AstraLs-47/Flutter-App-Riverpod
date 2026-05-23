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
import '../../domain/user_role.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final role = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          if (role == UserRole.admin) {
            context.goNamed(RouteConstants.adminName);
          } else if (role == UserRole.user) {
            context.goNamed(RouteConstants.dashboardName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid email or password')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
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
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 24),
                          Text(
                            'Welcome Back',
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue your journey',
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
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
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 32),
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            CustomButton(
                              text: 'Sign In',
                              onPressed: _handleSignIn,
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () =>
                                context.pushNamed(RouteConstants.signUpName),
                            child: RichText(
                              textAlign: TextAlign.center,
                              softWrap: true,
                              text: const TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
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
