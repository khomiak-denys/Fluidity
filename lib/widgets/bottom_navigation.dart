import 'package:flutter/material.dart';
import 'package:fluidity/l10n/app_localizations.dart';

// --- Custom Colors (Derived from Tailwind classes) ---
const Color sky200 = Color(0xFFBAE6FD);
const Color sky100 = Color(0xFFE0F2FE); // bg-sky-100
const Color sky600 = Color(0xFF0284C7); // text-sky-600
const Color tabInActiveColor = Color(0xFF9E9E9E); // Приблизно Colors.grey[400]

class BottomNavigation extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const BottomNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  // Дані вкладок будуть створюватись у build з використанням локалізації

  @override
  Widget build(BuildContext context) {
    // Використовуємо BottomAppBar, щоб розмістити його внизу
    return BottomAppBar(
      color: Colors.white,
      padding: EdgeInsets.zero,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: Container(
        // border-t border-sky-200
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: sky200, width: 1)),
        ),
        padding: const EdgeInsets.only(left: 8, right: 8, top: 4), // px-2 py-1
        child: SafeArea(
          top: false,
          // flex justify-around max-w-sm mx-auto
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420), // max-w-sm
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ([
                  {'id': 'home', 'icon': Icons.home_rounded, 'label': AppLocalizations.of(context)!.bottomNavHome},
                  {'id': 'statistics', 'icon': Icons.bar_chart_rounded, 'label': AppLocalizations.of(context)!.bottomNavStats},
                  {'id': 'reminders', 'icon': Icons.notifications_rounded, 'label': AppLocalizations.of(context)!.bottomNavReminders},
                  {'id': 'profile', 'icon': Icons.person_rounded, 'label': AppLocalizations.of(context)!.bottomNavProfile},
                ]).map((tab) {
                  final id = tab['id'] as String;
                  final isActive = activeTab == id;
                  final icon = tab['icon'] as IconData;
                  final label = tab['label'] as String;

                  // Використовуємо LayoutBuilder для отримання розмірів і правильної емуляції
                  // "активного фону", хоча це не ідеальна імітація motion.div
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0), // Невеликий відступ між кнопками
                      child: InkWell(
                        onTap: () => onTabChange(id),
                        borderRadius: BorderRadius.circular(8), // rounded-lg
                        child: _TabItem(
                          isActive: isActive,
                          icon: icon,
                          label: label,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Окремий віджет для анімації вкладки, імітуючи motion.div з layoutId
class _TabItem extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String label;

  const _TabItem({
    required this.isActive,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Використовуємо Material для InkWell та Stack для розміщення фону
    return Container(
      constraints: const BoxConstraints(minHeight: 44), // min-h-[44px]
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), // py-2 px-2
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Активний фон (motion.div layoutId="activeTab")
          if (isActive)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: sky100,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          // Зміст вкладки (relative z-10)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                // w-5 h-5 mb-1 transition-colors
                size: 20,
                color: isActive ? sky600 : tabInActiveColor,
              ),
              const SizedBox(height: 4), // mb-1
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  // text-xs transition-colors leading-none
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  color: isActive ? sky600 : tabInActiveColor,
                  height: 1.0, // Емуляція leading-none
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}