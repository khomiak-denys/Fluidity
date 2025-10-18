import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/profile_screen.dart';
import 'package:fluidity/widgets/water_intake.dart';
import 'package:fluidity/widgets/bottom_navigation.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const WaterTrackerApp());
}

class WaterTrackerApp extends StatefulWidget {
  const WaterTrackerApp({super.key});

  @override
  State<WaterTrackerApp> createState() => _WaterTrackerAppState();
}

class _WaterTrackerAppState extends State<WaterTrackerApp> {
  bool isAuthenticated = false;
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

  Future<bool> handleLogin(String phone, String password) async {
    // TODO: replace with real authentication logic (API call, validation, etc.)
    setState(() {
      isAuthenticated = true;
    });
    return true;
  }

  Future<bool> handleRegister(String firstName, String lastName, String phone, String password) async {
    // TODO: replace with real registration logic. For now, mock success and authenticate.
    setState(() {
      isAuthenticated = true;
    });
    return true;
  }

  void handleSignOut() {
    setState(() {
      isAuthenticated = false;
    });
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
        return ProfileScreen(
          dailyGoal: dailyGoal,
          onDailyGoalChange: (g) => setState(() => dailyGoal = g),
          notificationsEnabled: notificationsEnabled,
          onNotificationsToggle: () => setState(() => notificationsEnabled = !notificationsEnabled),
          onSignOut: handleSignOut,
          user: mockUser,
          language: language,
          onLanguageChange: (l) => setState(() => language = l),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      routes: {
        '/register': (_) => RegisterScreen(onRegister: handleRegister),
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
                onLogin: handleLogin,
                onRegister: () => _navigatorKey.currentState?.pushNamed('/register'),
              ),
            ),
    );
  }
}
