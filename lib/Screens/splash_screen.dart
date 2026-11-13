import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/constants/app_colors.dart';
import '../components/CheckIllustration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.go('/home');
    }
  }

  void _onNext() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Bottom purple circle
          Positioned(
            bottom: -130,
            right: -110,
            child: Container(
              height: 260,
              width: 260,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),

                const Center(
                  child: CheckIllustration(),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Get things done.",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Just a click away from\nplanning your tasks.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.lightText,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    _buildDot(false),
                    const SizedBox(width: 8),
                    _buildDot(false),
                    const SizedBox(width: 8),
                    _buildDot(true),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),

          // Next button
          Positioned(
            bottom: 25,
            right: 22,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onNext,
                borderRadius: BorderRadius.circular(50),
                child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page indicator
  Widget _buildDot(bool active) {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xFFDADCE5),
        shape: BoxShape.circle,
      ),
    );
  }
}
