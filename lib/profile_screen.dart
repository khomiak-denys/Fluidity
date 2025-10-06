import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatefulWidget {
  final int dailyGoal;
  final ValueChanged<int> onDailyGoalChange;
  final bool notificationsEnabled;
  final VoidCallback onNotificationsToggle;
  final VoidCallback onSignOut;
  final Map<String, String> user;
  final String language;
  final ValueChanged<String> onLanguageChange;

  const ProfileScreen({
    super.key,
    required this.dailyGoal,
    required this.onDailyGoalChange,
    required this.notificationsEnabled,
    required this.onNotificationsToggle,
    required this.onSignOut,
    required this.user,
    required this.language,
    required this.onLanguageChange,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.dailyGoal.toString());
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Daily Goal"),
        content: TextField(
          controller: _goalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Daily goal (ml)",
            hintText: "Enter value between 500–5000",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(_goalController.text) ?? 0;
              if (goal > 0 && goal <= 5000) {
                widget.onDailyGoalChange(goal);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Daily goal set to $goal ml")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPhone = widget.user["phoneNumber"] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    "Profile",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.blue[800], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Customize Fluidity for yourself",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.3, end: 0),
            ),

            const SizedBox(height: 20),

            // User Card
            Card(
              color: const Color(0xFFDFF5FF),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blue[400],
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                title: const Text("Welcome!", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userPhone, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Demo User",
                        style: TextStyle(fontSize: 11, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0)),

            const SizedBox(height: 20),

            // Settings
            _buildSettingsSection(context),

            const SizedBox(height: 24),

            // Logout button
            ElevatedButton.icon(
              onPressed: widget.onSignOut,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red[700],
                backgroundColor: Colors.red[50],
                side: BorderSide(color: Colors.red[200]!),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.flag_outlined,
            title: "Daily Goal",
            value: "${widget.dailyGoal} ml",
            onTap: _showGoalDialog,
          ),
          const Divider(height: 1),
          _buildSwitchItem(
            icon: Icons.notifications_none_outlined,
            title: "Notifications",
            value: widget.notificationsEnabled,
            onToggle: widget.onNotificationsToggle,
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.language,
            title: "Language",
            value: widget.language == "en" ? "English" : "Українська",
            onTap: () => widget.onLanguageChange(
              widget.language == "en" ? "uk" : "en",
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.blue[50],
        child: Icon(icon, color: Colors.blue[600], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: TextButton(
        onPressed: onTap,
        child: Text(value, style: const TextStyle(color: Colors.black54)),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.blue[50],
        child: Icon(icon, color: Colors.blue[600], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: (_) => onToggle(),
        activeColor: Colors.blue,
      ),
    );
  }
}
