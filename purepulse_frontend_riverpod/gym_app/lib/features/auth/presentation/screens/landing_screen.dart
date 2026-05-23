// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/custom_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/runner_background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Darker Overlay for high contrast
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Keep content grouped and centered
                  children: [
                    // Title
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: 'Pure',
                        style: TextStyle(
                          color: Colors.white, // Pure white
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                        children: [
                          TextSpan(
                            text: 'Pulse',
                            style: TextStyle(
                              color: Color(
                                0xFF1B75F9,
                              ), // Vibrant blue matching the reference
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    const Text(
                      'Every step counts. Every pulse matters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Action Button
                    CustomButton(
                      text: 'Get Started',
                      width: 220,
                      onPressed: () =>
                          context.pushNamed(RouteConstants.signInName),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
