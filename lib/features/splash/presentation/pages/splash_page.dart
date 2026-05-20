import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/animated_health_background.dart';
import '../../../auth/data/repositories/local_auth_repository.dart';
import '../widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check if admin is logged in
    final isAdminSession =
        await LocalAuthRepository.instance.getIsAdminSession();
    if (isAdminSession) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
      return;
    }

    // Check if user is logged in
    final currentUser =
        await LocalAuthRepository.instance.getCurrentUser();
    if (currentUser != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    // No session found, go to login
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedHealthBackground(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 120),
                const SizedBox(height: 18),
                Text(
                  'AarohCare',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Doctor Booking Made Easy',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
