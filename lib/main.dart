import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // додано для SystemUiOverlayStyle
import 'bloc/water/water_bloc.dart';
import 'bloc/water/water_event.dart';
import 'bloc/reminder/reminder_bloc.dart';
import 'bloc/reminder/reminder_event.dart';
// ignore_for_file: use_build_context_synchronously
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/profile_screen.dart';
import 'services/firebase_service.dart';
import 'widgets/bottom_navigation.dart';
import 'screens/register_screen.dart';
import 'repositories/water_entry_repository.dart';
import 'repositories/user_profile_repository.dart';
import 'repositories/reminder_setting_repository.dart';
import 'models/user_profile.dart';
import 'services/notification_service.dart';
import 'bloc/reminder/reminder_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase (blocking before UI)
  await FirebaseService.instance.init();

  // Load saved language from SharedPreferences (default 'en')
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'en';

  runApp(WaterTrackerApp(initialLanguage: savedLang));

  // Defer notifications init to avoid jank on first frame
  Future.microtask(() async {
    try {
      await NotificationService.instance.init();
      await NotificationService.instance.requestPermissions();
    } catch (_) {}
  });
}

class WaterTrackerApp extends StatefulWidget {
  final String initialLanguage;

  const WaterTrackerApp({super.key, this.initialLanguage = 'en'});

  @override
  State<WaterTrackerApp> createState() => _WaterTrackerAppState();
}

class _WaterTrackerAppState extends State<WaterTrackerApp> {
  bool isAuthenticated = false;
  String? authError;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String activeTab = 'home';
  int dailyGoal = 2000;
  bool notificationsEnabled = true;
  bool notificationsSystemAllowed = false; // новий прапорець
  StreamSubscription<UserProfile?>? _profileSub;

  // Removed hardcoded mock entries and reminders

  late String language = widget.initialLanguage;

  final mockUser = {'uid': 'demo-user', 'phoneNumber': '+380 50 123 45 67'};

  @override
  void initState() {
    super.initState();
    // Restore authentication state from FirebaseAuth if a user is already signed in.
    // FirebaseAuth persists the session across app restarts by default, so we
    // can rely on FirebaseService.instance.auth.currentUser to determine logged-in state.
    try {
      final fbUser = FirebaseService.instance.auth.currentUser;
      if (fbUser != null) {
        isAuthenticated = true;
        _attachProfileStream();
      }
    } catch (_) {
      // If anything goes wrong, leave isAuthenticated as false.
      isAuthenticated = false;
    }

    // Ініціалізація дозволів для сповіщень
    Future.microtask(() async {
      try {
        await NotificationService.instance.init();
        await NotificationService.instance.requestPermissions();
        // requestPermissions() повертає void, тому не присвоюємо його в змінну
        if (mounted) {
          // Вважаємо, що дозвіл надано після успішного виклику (за відсутності явного API перевірки)
          setState(() => notificationsSystemAllowed = true);
        }
      } catch (_) {
        // Якщо трапилась помилка — вважаємо, що системний дозвіл не надано
        if (mounted) {
          setState(() {
            notificationsSystemAllowed = false;
            notificationsEnabled = false;
          });
        }
        try { await NotificationService.instance.cancelAll(); } catch (_) {}
      }
    });
  }

  void _attachProfileStream() {
    final fbUser = FirebaseService.instance.auth.currentUser;
    final uid = fbUser?.uid;
    _profileSub?.cancel();
    if (uid == null || uid.isEmpty) return;
    final repo = UserProfileRepository();
    _profileSub = repo.watchById(uid).listen((profile) {
      if (!mounted) return;
      if (profile != null) {
        setState(() {
          dailyGoal = profile.targetWaterAmount;
        });
      }
    });
  }

  Future<void> handleLogin(String email, String password) async {
    final error = await FirebaseService.instance.signInWithEmail(email.trim(), password);
    if (!mounted) return;

    final messengerCtx = _navigatorKey.currentContext;

    if (error == null) {
      setState(() {
        isAuthenticated = true;
        authError = null;
      });
      FirebaseService.instance.logEvent('login', {'method': 'email'});
      // Ensure user profile exists in Firestore
      try {
        final fbUser = FirebaseService.instance.auth.currentUser;
        if (fbUser != null) {
          final repo = UserProfileRepository();
          final existing = await repo.getById(fbUser.uid);
          if (existing == null) {
            final display = fbUser.displayName ?? '';
            final parts = display.trim().split(' ');
            final first = parts.isNotEmpty ? parts.first : '';
            final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
            final profile = UserProfile(
              id: fbUser.uid,
              firstName: first,
              lastName: last,
              email: fbUser.email ?? '',
              targetWaterAmount: dailyGoal,
              registrationDate: DateTime.now(),
            );
            await repo.upsert(profile);
          }
        }
      } catch (_) {}
      _attachProfileStream();
    } else {
      setState(() {
        authError = error;
      });
      if (messengerCtx != null) {
          final msg = _localizeAuthMessage(messengerCtx, error);
        ScaffoldMessenger.of(messengerCtx).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> handleRegister(String firstName, String lastName, String email, String password) async {
    final error = await FirebaseService.instance.registerWithEmail(firstName.trim(), lastName.trim(), email.trim(), password);
    if (!mounted) return;

    final messengerCtx = _navigatorKey.currentContext;

    if (error == null) {
      // Show a message to the user to check their email
      if (messengerCtx != null) {
        final msg = AppLocalizations.of(messengerCtx)!.auth_verification_email_sent;
        ScaffoldMessenger.of(messengerCtx).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.green),
        );
      }
      _navigatorKey.currentState?.pop(); // Go back to login screen
    } else {
      setState(() {
        authError = error;
      });
      if (messengerCtx != null) {
          final msg = _localizeAuthMessage(messengerCtx, error);
        ScaffoldMessenger.of(messengerCtx).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> handleSignOut() async {
    // Sign out from Firebase to clear persisted session
    try {
      await FirebaseService.instance.signOut();
    } catch (_) {
      // ignore errors from sign out -- still attempt to clear local data
    }

    // Remove any stored user-related keys (if any were saved previously)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_uid');
      await prefs.remove('user_email');
      // keep language preference
    } catch (_) {
      // ignore prefs errors
    }

    if (!mounted) return;
    setState(() {
      isAuthenticated = false;
      authError = null;
      dailyGoal = 2000;
    });
    await _profileSub?.cancel();
    // Cancel scheduled notifications on sign out
    try { await NotificationService.instance.cancelAll(); } catch (_) {}
  }

  String _localizeAuthMessage(BuildContext ctx, String code) {
    // Use generated AppLocalizations getters to localize auth error codes.
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

  void setTab(String tab) {
    setState(() {
      activeTab = tab;
    });
  }

  Widget renderScreen() {
    switch (activeTab) {
      case 'home':
        return HomeScreen(
          dailyGoal: dailyGoal,
        );
      case 'statistics':
        return StatisticsScreen(
          dailyGoal: dailyGoal,
        );
      case 'reminders':
        // Блокування екрану нагадувань, якщо сповіщення вимкнено або системний дозвіл відсутній
        if (!notificationsEnabled || !notificationsSystemAllowed) {
          final loc = AppLocalizations.of(context);
          final title = !notificationsSystemAllowed
              ? (loc?.errorPermissionDenied ?? 'Permission denied. Please enable notifications in Settings.')
              : (loc?.notifications ?? 'Notifications');
          final subtitle = !notificationsSystemAllowed
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
                    if (!notificationsSystemAllowed)
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Повторна перевірка/запит дозволу
                          try {
                            await NotificationService.instance.requestPermissions();
                            if (mounted) {
                              setState(() {
                                notificationsSystemAllowed = true;
                                notificationsEnabled = true; // авто-вмикання майстер‑перемикача
                              });
                            }
                            // Синхронізація нагадувань, якщо вони завантажені
                            final rbState = (_navigatorKey.currentContext ?? context).read<ReminderBloc>().state;
                            if (rbState is ReminderLoaded) {
                              await NotificationService.instance.sync(rbState.data);
                            }
                          } catch (_) {
                            // Дозвіл все ще не надано
                            if (mounted) {
                              setState(() {
                                notificationsSystemAllowed = false;
                                notificationsEnabled = false;
                              });
                            }
                          }
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
        final fbUser = FirebaseService.instance.auth.currentUser;
        final userMap = <String, String>{
          'uid': fbUser?.uid ?? mockUser['uid'].toString(),
          'phoneNumber': fbUser?.phoneNumber ?? mockUser['phoneNumber'].toString(),
          'displayName': fbUser?.displayName ?? '',
          'email': fbUser?.email ?? '',
        };
        return ProfileScreen(
          dailyGoal: dailyGoal,
          onDailyGoalChange: (g) async {
            setState(() => dailyGoal = g);
            final uid = fbUser?.uid;
            if (uid != null && uid.isNotEmpty) {
              try {
                await UserProfileRepository().updateGoal(uid, g);
              } catch (_) {}
            }
          },
          notificationsEnabled: notificationsEnabled && notificationsSystemAllowed,
          onNotificationsToggle: () async {
            if (!notificationsSystemAllowed) {
              // Покажемо діалог із інструкцією та Retry (без openSystemSettings)
              final loc = AppLocalizations.of(_navigatorKey.currentContext ?? context);
              await showDialog<void>(
                context: _navigatorKey.currentContext ?? context,
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
                          try {
                            await NotificationService.instance.requestPermissions();
                            if (mounted) {
                              setState(() {
                                notificationsSystemAllowed = true;
                                notificationsEnabled = true;
                              });
                            }
                            final rbState = (_navigatorKey.currentContext ?? context).read<ReminderBloc>().state;
                            if (rbState is ReminderLoaded) {
                              await NotificationService.instance.sync(rbState.data);
                            }
                          } catch (_) {
                            if (mounted) {
                              setState(() {
                                notificationsSystemAllowed = false;
                                notificationsEnabled = false;
                              });
                            }
                          }
                        },
                        child: Text(loc?.retry ?? 'Retry'),
                      ),
                    ],
                  );
                },
              );
              return;
            }

            final newVal = !notificationsEnabled;
            setState(() => notificationsEnabled = newVal);
            try {
              if (!newVal) {
                await NotificationService.instance.cancelAll();
              } else {
                final ctx = _navigatorKey.currentContext ?? context;
                final rbState = ctx.read<ReminderBloc>().state;
                if (rbState is ReminderLoaded) {
                  await NotificationService.instance.sync(rbState.data);
                }
              }
            } catch (_) {}
          },
          onSignOut: handleSignOut,
          user: userMap,
          language: language,
          onLanguageChange: (l) async {
            setState(() => language = l);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('language', l);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fbUser = FirebaseService.instance.auth.currentUser;
    final uid = (isAuthenticated && fbUser != null) ? fbUser.uid : '';
    final waterRepo = WaterEntryRepository();

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(language),
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      routes: {
        '/register': (context) => RegisterScreen(
              onRegister: (ctx, firstName, lastName, email, password) {
                handleRegister(firstName, lastName, email, password);
              },
              error: authError != null ? _localizeAuthMessage(context, authError!) : null,
            ),
      },
      home: isAuthenticated
          ? MultiBlocProvider(
              providers: [
                BlocProvider<WaterBloc>(
                  create: (_) => WaterBloc(repo: waterRepo, userId: uid)..add(LoadWaterEvent()),
                ),
                BlocProvider<ReminderBloc>(
                  create: (_) => ReminderBloc(repo: ReminderSettingRepository(), userId: uid)..add(LoadRemindersEvent()),
                ),
              ],
              child: BlocListener<ReminderBloc, ReminderState>(
                listenWhen: (prev, next) => next is ReminderLoaded,
                listener: (context, state) async {
                  if (state is ReminderLoaded) {
                    try {
                      final loc = AppLocalizations.of(context);
                      if (loc != null) {
                        NotificationService.instance.updateLocalizedStrings(loc);
                      }
                      final hasActive = state.data.any((r) => r.isActive);
                      // Якщо з'явилось хоч одне активне нагадування — увімкнути майстер‑перемикач (тільки якщо системний дозвіл є)
                      if (hasActive && !notificationsEnabled && notificationsSystemAllowed) {
                        setState(() => notificationsEnabled = true);
                      }
                      // Синхронізувати або скасувати залежно від майстер‑перемикача та системного дозволу
                      if (notificationsEnabled && notificationsSystemAllowed && hasActive) {
                        await NotificationService.instance.sync(state.data);
                      } else {
                        await NotificationService.instance.cancelAll();
                      }
                    } catch (_) {}
                  }
                },
                child: Scaffold(
                  body: renderScreen(),
                  bottomNavigationBar: BottomNavigation(
                    activeTab: activeTab,
                    onTabChange: setTab,
                  ),
                ),
              ),
            )
          : Builder(
              builder: (context) => LoginScreen(
                onLogin: (ctx, email, password) => handleLogin(email, password),
                onRegister: () => _navigatorKey.currentState?.pushNamed('/register'),
                error: authError != null ? _localizeAuthMessage(context, authError!) : null,
              ),
            ),
    );
  }
}
