import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';

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
  String activeTab = 'home';
  int dailyGoal = 2000;
  bool notificationsEnabled = true;

  // Mock data
  List<WaterIntakeEntry> entries = [
    WaterIntakeEntry(id: '1', amount: 250, time: '09:30', type: 'glass'),
    WaterIntakeEntry(id: '2', amount: 500, time: '12:15', type: 'bottle'),
    WaterIntakeEntry(id: '3', amount: 350, time: '15:45', type: 'cup'),
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

  void handleRegister() {
    // TODO: implement registration flow (navigate to register screen or show dialog)
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
      home: isAuthenticated
          ? Scaffold(
              body: renderScreen(),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: ['home', 'statistics', 'reminders', 'profile'].indexOf(activeTab),
                onTap: (index) {
                  setTab(['home', 'statistics', 'reminders', 'profile'][index]);
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistics'),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Reminders'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            )
          : LoginScreen(
              onLogin: handleLogin,
              onRegister: handleRegister,
            ),
    );
  }
}
