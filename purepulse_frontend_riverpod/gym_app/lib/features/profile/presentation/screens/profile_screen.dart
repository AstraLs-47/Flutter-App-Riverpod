// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/widgets/user_bottom_nav.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isDeletingAccount = false;

  Future<void> _handleDeleteAccount() async {
    if (_isDeletingAccount) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This will permanently remove your account and you will need to sign up again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      await ref.read(authProvider.notifier).deleteAccount();
      if (!mounted) {
        return;
      }
      context.goNamed(RouteConstants.signInName);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst('Exception: ', '')
                .replaceFirst('ApiException: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        context.goNamed(RouteConstants.signInName);
                      }
                    },
                    icon: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    label: const Icon(
                      Icons.logout,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0E6CF2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0E6CF2).withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 8,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 80),
              ),
              const SizedBox(height: 20),
              Text(
                AuthService.currentUserName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF0E6CF2),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AuthService.currentUserEmail,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isDeletingAccount ? null : _handleDeleteAccount,
                  icon: Icon(
                    _isDeletingAccount
                        ? Icons.hourglass_top
                        : Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  label: Text(
                    _isDeletingAccount ? 'Deleting...' : 'Delete Account',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNav(currentItem: BottomNavItem.profile),
    );
  }
}
