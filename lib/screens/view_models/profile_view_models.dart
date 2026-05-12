import 'package:flutter/material.dart';
import 'package:fluidity/l10n/app_localizations.dart';

enum ProfileItemKind { action, toggle }

class ProfileItemViewModel {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback action;
  final ProfileItemKind kind;

  const ProfileItemViewModel({
    required this.label,
    required this.value,
    required this.icon,
    required this.action,
    required this.kind,
  });
}

class ProfileSectionViewModel {
  final String title;
  final IconData icon;
  final List<ProfileItemViewModel> items;

  const ProfileSectionViewModel({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class ProfileSectionsBuilder {
  static List<ProfileSectionViewModel> build({
    required AppLocalizations loc,
    required int dailyGoal,
    required bool notificationsEnabled,
    required VoidCallback onGoalTap,
    required VoidCallback onNotificationsToggle,
    required String language,
    required ValueChanged<String> onLanguageChange,
  }) {
    final languageLabel = language == 'en' ? loc.english : loc.ukrainian;
    final nextLanguage = language == 'en' ? 'uk' : 'en';

    return [
      ProfileSectionViewModel(
        title: loc.settings,
        icon: Icons.settings,
        items: [
          ProfileItemViewModel(
            label: loc.dailyGoal,
            value: '$dailyGoal мл',
            action: onGoalTap,
            icon: Icons.flag_outlined,
            kind: ProfileItemKind.action,
          ),
          ProfileItemViewModel(
            label: loc.notifications,
            value: notificationsEnabled ? 'on' : 'off',
            action: onNotificationsToggle,
            icon: Icons.notifications_none_outlined,
            kind: ProfileItemKind.toggle,
          ),
          ProfileItemViewModel(
            label: loc.language,
            value: languageLabel,
            action: () => onLanguageChange(nextLanguage),
            icon: Icons.language,
            kind: ProfileItemKind.action,
          ),
        ],
      ),
    ];
  }
}
