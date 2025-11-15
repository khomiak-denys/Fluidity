import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'blocs/water/water_bloc.dart';
import 'blocs/water/water_event.dart';
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
import 'models/user_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await FirebaseService.instance.init();

  // Load saved language from SharedPreferences (default 'en')
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'en';

  runApp(WaterTrackerApp(initialLanguage: savedLang));
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
          notificationsEnabled: notificationsEnabled,
          onNotificationsToggle: () => setState(() => notificationsEnabled = !notificationsEnabled),
          onSignOut: handleSignOut,
          user: userMap,
          language: language,
          onLanguageChange: (l) async {
            // update state and persist selection
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
          ? BlocProvider<WaterBloc>(
              create: (_) => WaterBloc(repo: waterRepo, userId: uid)..add(LoadWaterEvent()),
              child: Scaffold(
                body: renderScreen(),
                bottomNavigationBar: BottomNavigation(
                  activeTab: activeTab,
                  onTabChange: setTab,
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
