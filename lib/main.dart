import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/water/water_bloc.dart';
import 'blocs/water/water_event.dart';
// ignore_for_file: use_build_context_synchronously
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/profile_screen.dart';
import 'models/water_intake.dart';
import 'services/firebase_service.dart';
import 'widgets/bottom_navigation.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await FirebaseService.instance.init();
  runApp(const WaterTrackerApp());
}

class WaterTrackerApp extends StatefulWidget {
  const WaterTrackerApp({super.key});

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

  // Mock data
  List<WaterIntakeEntry> entries = [
    WaterIntakeEntry(id: '1', amount: 250, time: '09:30', type: 'glass', comment: ''),
    WaterIntakeEntry(id: '2', amount: 500, time: '12:15', type: 'bottle', comment: ''),
    WaterIntakeEntry(id: '3', amount: 350, time: '15:45', type: 'cup', comment: ''),
  ];

  List reminders = [
    {'id': '1', 'time': '08:00', 'enabled': true, 'label': 'Morning hydration'},
    {'id': '2', 'time': '12:00', 'enabled': true, 'label': 'Lunch break'},
    {'id': '3', 'time': '16:00', 'enabled': false, 'label': 'Afternoon boost'},
  ];

  String language = 'en';

  final mockUser = {'uid': 'demo-user', 'phoneNumber': '+380 50 123 45 67'};

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

  void handleSignOut() {
    setState(() {
      isAuthenticated = false;
    });
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
          entries: entries,
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
          onDailyGoalChange: (g) => setState(() => dailyGoal = g),
          notificationsEnabled: notificationsEnabled,
          onNotificationsToggle: () => setState(() => notificationsEnabled = !notificationsEnabled),
          onSignOut: handleSignOut,
          user: userMap,
          language: language,
          onLanguageChange: (l) => setState(() => language = l),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WaterBloc>(create: (_) => WaterBloc()..add(LoadWaterEvent())),
      ],
      child: MaterialApp(
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
          ? Scaffold(
              body: renderScreen(),
              bottomNavigationBar: BottomNavigation(
                activeTab: activeTab,
                onTabChange: setTab,
              ),
            )
          : Builder(
              builder: (context) => LoginScreen(
                onLogin: (ctx, email, password) => handleLogin(email, password),
                onRegister: () => _navigatorKey.currentState?.pushNamed('/register'),
                error: authError != null ? _localizeAuthMessage(context, authError!) : null,
              ),
            ),
      ),
    );
  }
}
