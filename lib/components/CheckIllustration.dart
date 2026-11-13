
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class CheckIllustration extends StatelessWidget {
  const CheckIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Purple box
          Container(
            height: 85,
            width: 85,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 60,
            ),
          ),

          // Decorative dots
          _dot(
            10,
            const Color(0xFFF28B43),
            Alignment.centerLeft,
          ),

          _dot(
            9,
            AppColors.darkText,
            Alignment.centerRight,
          ),

          _dot(
            8,
            AppColors.secondary,
            const Alignment(0.8, 0.8),
          ),

          _dot(
            6,
            const Color(0xFFE0E0E0),
            const Alignment(-0.8, -0.8),
          ),

          _dot(
            6,
            const Color(0xFFE0E0E0),
            const Alignment(0.1, -0.95),
          ),

          // Yellow sparkle
          const Align(
            alignment: Alignment(0.75, -0.65),
            child: Icon(
              Icons.auto_awesome,
              color: Color(0xFFF4B83F),
              size: 17,
            ),
          ),

          // White sparkle
          const Align(
            alignment: Alignment(-0.85, 0.6),
            child: Icon(
              Icons.auto_awesome,
              color: Color(0xFFF1F1F1),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // Dot widget
  Widget _dot(double size, Color color, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
