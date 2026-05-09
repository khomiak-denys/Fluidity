// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/reminder/reminder_bloc.dart';
import '../bloc/reminder/reminder_state.dart';
import '../cubit/app_settings/app_settings_cubit.dart';
import '../cubit/notifications/notifications_cubit.dart';
import '../cubit/session/session_cubit.dart';
import '../cubit/ui_effects/ui_effects_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/reminder_setting.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/reminder_screen.dart';
import '../screens/statistics_screen.dart';
import '../widgets/bottom_navigation.dart';

class AppShell extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AppShell({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppSettingsCubit>().state;
    final notifState = context.watch<NotificationsCubit>().state;
    final sessionState = context.watch<SessionCubit>().state;

    List<ReminderSetting> remindersFromState() {
      final rbState = context.read<ReminderBloc>().state;
      return rbState is ReminderLoaded ? rbState.data : const <ReminderSetting>[];
    }

    Future<void> showPermissionDialog(BuildContext ctx) async {
      final loc = AppLocalizations.of(ctx);
      await showDialog<void>(
        context: navigatorKey.currentContext ?? ctx,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(loc?.errorPermissionDenied ?? 'Permission denied'),
            content: Text(loc?.remindersSubtitle ?? 'Set reminders to drink water'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(loc?.cancel ?? 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await ctx.read<NotificationsCubit>().retryAndSync(remindersFromState());
                },
                child: Text(loc?.retry ?? 'Retry'),
              ),
            ],
          );
        },
      );
    }

    Widget renderScreen() {
      switch (appState.activeTab) {
        case 'home':
          return HomeScreen(dailyGoal: appState.dailyGoal);
        case 'statistics':
          return StatisticsScreen(dailyGoal: appState.dailyGoal);
        case 'reminders':
          if (!notifState.enabled || !notifState.systemAllowed) {
            final loc = AppLocalizations.of(context);
            final title = !notifState.systemAllowed
                ? (loc?.errorPermissionDenied ?? 'Permission denied.')
                : (loc?.notifications ?? 'Notifications');
            final subtitle = !notifState.systemAllowed
                ? (loc?.remindersPermissionEnableInSettings ?? 'Enable system notification permission in Settings.')
                : (loc?.remindersEnableInProfile ?? 'Enable notifications in Profile to manage reminders.');
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                toolbarHeight: 0,
                backgroundColor: Colors.white,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_off_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 16),
                      if (!notifState.systemAllowed)
                        ElevatedButton.icon(
                          onPressed: () async {
                            await context.read<NotificationsCubit>().retryAndSync(remindersFromState());
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(loc?.retry ?? 'Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const RemindersScreen();
        case 'profile':
          final userMap = <String, String>{
            'uid': sessionState.uid ?? 'demo-user',
            'phoneNumber': '',
            'displayName': sessionState.displayName ?? '',
            'email': sessionState.email ?? '',
          };

          return ProfileScreen(
            dailyGoal: appState.dailyGoal,
            onDailyGoalChange: (g) async {
              await context.read<AppSettingsCubit>().setDailyGoal(g, sessionState.uid);
            },
            notificationsEnabled: notifState.enabled && notifState.systemAllowed,
            onNotificationsToggle: () async {
              if (!notifState.systemAllowed) {
                context.read<UiEffectsCubit>().emitPermissionDialog();
                return;
              }

              await context.read<NotificationsCubit>().setEnabled(!notifState.enabled, remindersFromState());
            },
            onSignOut: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_uid');
              await prefs.remove('user_email');

              await context.read<NotificationsCubit>().handleSignOut();
              context.read<AppSettingsCubit>().resetForSignOut();
              await context.read<SessionCubit>().signOut();
            },
            user: userMap,
            language: appState.language,
            onLanguageChange: (l) async {
              await context.read<AppSettingsCubit>().setLanguage(l);
            },
          );
        default:
          return const SizedBox.shrink();
      }
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ReminderBloc, ReminderState>(
          listenWhen: (_, next) => next is ReminderLoaded,
          listener: (context, state) async {
            if (state is ReminderLoaded) {
              final n = context.read<NotificationsCubit>();
              n.updateLocalizedStrings(AppLocalizations.of(context));
              await n.syncFromReminders(state.data);
            }
          },
        ),
        BlocListener<UiEffectsCubit, UiEffectsState>(
          listenWhen: (prev, next) => prev.pending?.id != next.pending?.id,
          listener: (context, state) async {
            final effect = state.pending;
            if (effect is PermissionDeniedPromptEffect) {
              await showPermissionDialog(context);
              context.read<UiEffectsCubit>().consume(effect.id);
            }
          },
        ),
      ],
      child: Scaffold(
        body: renderScreen(),
        bottomNavigationBar: BottomNavigation(
          activeTab: appState.activeTab,
          onTabChange: (tab) => context.read<AppSettingsCubit>().setTab(tab),
        ),
      ),
    );
  }
}
