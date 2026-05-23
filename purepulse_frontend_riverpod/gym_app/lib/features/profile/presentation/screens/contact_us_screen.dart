// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: RichText(
                text: const TextSpan(
                  text: 'Contact ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Us',
                      style: TextStyle(color: Color(0xFF0E6CF2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'re here to support your fitness journey—reach out anytime and let\'s keep you moving forward.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildContactItem(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: '+251 965 582 123 / +251 895 21 365',
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'purepulse@gmail.com',
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: 'PurePulse Fitness Zone\nBole Atlas Area, Cameroon Street',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0E6CF2), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
