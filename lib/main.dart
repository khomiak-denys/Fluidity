import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore_for_file: use_build_context_synchronously

import 'bloc/reminder/reminder_bloc.dart';
import 'bloc/reminder/reminder_event.dart';
import 'bloc/reminder/reminder_state.dart';
import 'bloc/water/water_bloc.dart';
import 'bloc/water/water_event.dart';
import 'cubit/app_settings/app_settings_cubit.dart';
import 'cubit/app_settings/app_settings_state.dart';
import 'cubit/notifications/notifications_cubit.dart';
import 'cubit/session/session_cubit.dart';
import 'cubit/session/session_state.dart';
import 'l10n/app_localizations.dart';
import 'models/reminder_setting.dart';
import 'repositories/reminder_setting_repository.dart';
import 'repositories/user_profile_repository.dart';
import 'repositories/water_entry_repository.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/statistics_screen.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'widgets/bottom_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'en';

  runApp(WaterTrackerApp(initialLanguage: savedLang));
}

class WaterTrackerApp extends StatelessWidget {
  final String initialLanguage;

  const WaterTrackerApp({super.key, this.initialLanguage = 'en'});

  @override
  Widget build(BuildContext context) {
    final profileRepo = UserProfileRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(
          create: (_) => SessionCubit(
            firebaseService: FirebaseService.instance,
            userProfileRepository: profileRepo,
          )..bootstrap(),
        ),
        BlocProvider<AppSettingsCubit>(
          create: (_) => AppSettingsCubit(
            initialLanguage: initialLanguage,
            userProfileRepository: profileRepo,
          )..bootstrap(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) => NotificationsCubit(
            notificationService: NotificationServiceGateway(NotificationService.instance),
          )..bootstrap(),
        ),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  String _localizeAuthMessage(BuildContext ctx, String code) {
    final loc = AppLocalizations.of(ctx)!;
    switch (code) {
      case 'auth.email_not_verified':
        return loc.auth_email_not_verified;
      case 'auth.invalid_credentials':
        return loc.auth_invalid_credentials;
      case 'auth.invalid_email':
        return loc.auth_invalid_email;
      case 'auth.weak_password':
        return loc.auth_weak_password;
      case 'auth.email_already_in_use':
        return loc.auth_email_already_in_use;
      case 'auth.registration_error':
        return loc.auth_registration_error;
      case 'auth.verification_email_sent':
        return loc.auth_verification_email_sent;
      case 'auth.unknown_error':
      default:
        return loc.auth_unknown_error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, next) => prev.profile?.targetWaterAmount != next.profile?.targetWaterAmount,
      listener: (context, state) {
        final goal = state.profile?.targetWaterAmount;
        if (goal != null) {
          context.read<AppSettingsCubit>().setDailyGoalLocal(goal);
        }
      },
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, appState) {
          return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(appState.language),
              debugShowCheckedModeBanner: false,
              navigatorKey: _navigatorKey,
              routes: {
                '/register': (routeContext) {
                  final sessionState = routeContext.watch<SessionCubit>().state;
                  return RegisterScreen(
                    onRegister: (_, firstName, lastName, email, password) async {
                      await routeContext.read<SessionCubit>().register(firstName, lastName, email, password);
                      if (!mounted) return;
                      final next = routeContext.read<SessionCubit>().state;
                      if (next.authError == null) {
                        final msg = AppLocalizations.of(routeContext)!.auth_verification_email_sent;
                        ScaffoldMessenger.of(routeContext).showSnackBar(
                          SnackBar(content: Text(msg), backgroundColor: Colors.green),
                        );
                        _navigatorKey.currentState?.pop();
                        return;
                      }
                      final msg = _localizeAuthMessage(routeContext, next.authError!);
                      ScaffoldMessenger.of(routeContext).showSnackBar(
                        SnackBar(content: Text(msg), backgroundColor: Colors.red),
                      );
                    },
                    error: sessionState.authError != null
                        ? _localizeAuthMessage(routeContext, sessionState.authError!)
                        : null,
                  );
                },
              },
              home: BlocBuilder<SessionCubit, SessionState>(
                builder: (context, sessionState) {
                  if (!sessionState.authenticated || (sessionState.uid?.isEmpty ?? true)) {
                    return LoginScreen(
                      onLogin: (ctx, email, password) async {
                        await context.read<SessionCubit>().login(email, password);
                        if (!mounted) return;
                        final next = context.read<SessionCubit>().state;
                        final messengerCtx = _navigatorKey.currentContext ?? ctx;
                        if (next.authError != null) {
                          final msg = _localizeAuthMessage(messengerCtx, next.authError!);
                          ScaffoldMessenger.of(messengerCtx).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: Colors.red),
                          );
                        }
                      },
                      onRegister: () => _navigatorKey.currentState?.pushNamed('/register'),
                      error: sessionState.authError != null
                          ? _localizeAuthMessage(context, sessionState.authError!)
                          : null,
                    );
                  }

                  final uid = sessionState.uid!;
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider<WaterBloc>(
                        create: (_) => WaterBloc(
                          repo: WaterEntryRepository(),
                          userId: uid,
                        )..add(LoadWaterEvent()),
                      ),
                      BlocProvider<ReminderBloc>(
                        create: (_) => ReminderBloc(
                          repo: ReminderSettingRepository(),
                          userId: uid,
                        )..add(LoadRemindersEvent()),
                      ),
                    ],
                    child: _MainShell(
                      navigatorKey: _navigatorKey,
                      localizeAuthMessage: _localizeAuthMessage,
                    ),
                  );
                },
              ),
            );
          },
        ),
    );
  }
}

class _MainShell extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String Function(BuildContext, String) localizeAuthMessage;

  const _MainShell({
    required this.navigatorKey,
    required this.localizeAuthMessage,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppSettingsCubit>().state;
    final notifState = context.watch<NotificationsCubit>().state;
    final sessionState = context.watch<SessionCubit>().state;

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
                ? (loc?.errorPermissionDenied ?? 'Permission denied. Please enable notifications in Settings.')
                : (loc?.notifications ?? 'Notifications');
            final subtitle = !notifState.systemAllowed
                ? 'Enable system notification permission in Settings.'
                : 'Enable notifications in Profile to manage reminders.';
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
                            final rbState = context.read<ReminderBloc>().state;
                            final reminders = rbState is ReminderLoaded ? rbState.data : const <ReminderSetting>[];
                            await context.read<NotificationsCubit>().retryAndSync(reminders);
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
                final loc = AppLocalizations.of(navigatorKey.currentContext ?? context);
                await showDialog<void>(
                  context: navigatorKey.currentContext ?? context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text(loc?.errorPermissionDenied ?? 'Permission denied'),
                      content: const Text('Please enable notifications in system Settings to use reminders. Return and tap Retry.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(loc?.cancel ?? 'Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            final rbState = context.read<ReminderBloc>().state;
                            final reminders = rbState is ReminderLoaded ? rbState.data : const <ReminderSetting>[];
                            await context.read<NotificationsCubit>().retryAndSync(reminders);
                          },
                          child: Text(loc?.retry ?? 'Retry'),
                        ),
                      ],
                    );
                  },
                );
                return;
              }

              final rbState = context.read<ReminderBloc>().state;
              final reminders = rbState is ReminderLoaded ? rbState.data : const <ReminderSetting>[];
              await context.read<NotificationsCubit>().setEnabled(!notifState.enabled, reminders);
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

    return BlocListener<ReminderBloc, ReminderState>(
      listenWhen: (_, next) => next is ReminderLoaded,
      listener: (context, state) async {
        if (state is ReminderLoaded) {
          final n = context.read<NotificationsCubit>();
          n.updateLocalizedStrings(AppLocalizations.of(context));
          await n.syncFromReminders(state.data);
        }
      },
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
