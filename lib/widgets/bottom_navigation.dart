import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BottomNavigation extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const BottomNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'home', 'icon': Icons.home_rounded, 'label': 'Головна'},
      {'id': 'statistics', 'icon': Icons.bar_chart_rounded, 'label': 'Статистика'},
      {'id': 'reminders', 'icon': Icons.notifications_rounded, 'label': 'Нагадування'},
      {'id': 'profile', 'icon': Icons.person_rounded, 'label': 'Профіль'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFBAE6FD), width: 1)), // border-sky-200
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tabs.map((tab) {
            final id = tab['id'] as String;
            final isActive = activeTab == id;
            final icon = tab['icon'] as IconData;
            final label = tab['label'] as String;

            return GestureDetector(
              onTap: () => onTabChange(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFE0F2FE) : Colors.transparent, // bg-sky-100
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isActive ? const Color(0xFF0284C7) : Colors.grey[400], // text-sky-600
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                        color: isActive ? const Color(0xFF0284C7) : Colors.grey[400],
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ).animate(
                target: isActive ? 1 : 0,
              ).scale(
                duration: const Duration(milliseconds: 200),
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
