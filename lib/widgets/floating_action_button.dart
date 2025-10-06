import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingActionButtonCustom({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 64, // приблизно як bottom-16 у Tailwind
      right: 16,
      child: GestureDetector(
        onTapDown: (_) {},
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)], // sky-500 → cyan-500
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: onPressed,
          ),
    )
      // початкова поява з анімацією (scale + opacity)
      .animate()
            .scale(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 1.0), duration: const Duration(milliseconds: 350))
      .fadeIn(duration: 400.ms, delay: 100.ms),
      ),
    );
  }
}
