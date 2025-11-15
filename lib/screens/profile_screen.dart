import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluidity/l10n/app_localizations.dart';

// --- Custom Colors (Derived from Tailwind classes) ---
const Color sky50 = Color(0xFFF0F9FF);
const Color cyan50 = Color(0xFFECFEFF);
const Color sky200 = Color(0xFFBAE6FD);
const Color sky600 = Color(0xFF0284C7);
const Color sky700 = Color(0xFF0369A1);
const Color green100 = Color(0xFFDCFCE7);
const Color green700 = Color(0xFF047857);
const Color red600 = Color(0xFFDC2626); // text-red-600
const Color red200 = Color(0xFFFECACA); // border-red-200
const Color red50 = Color(0xFFFEF2F2); // hover:bg-red-50
const Color mutedForeground = Color(0xFF6B7280); // text-muted-foreground (сірий)
const Color settingBgColor = Color(0xFFF8FAFC); // hover:bg-sky-100/50

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
  _goalController.text = widget.dailyGoal.toString();
    showDialog(
      context: context,
      builder: (ctx) => _GoalSettingDialog(
        initialGoal: widget.dailyGoal,
        onSave: (newGoal) {
          widget.onDailyGoalChange(newGoal);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.dailyGoal}: $newGoal мл'), behavior: SnackBarBehavior.floating),
          );
        },
      ),
    );
  }

  // --- Налаштування секцій (як у React-коді) ---
  List<Map<String, dynamic>> get _profileSections => [
        {
          'title': AppLocalizations.of(context)!.settings,
          'icon': Icons.settings,
          'items': [
            {
              'label': AppLocalizations.of(context)!.dailyGoal,
              'value': "${widget.dailyGoal} мл",
              'action': _showGoalDialog,
              'icon': Icons.flag_outlined,
            },
            {
              'label': AppLocalizations.of(context)!.notifications,
              'value': widget.notificationsEnabled,
              'action': widget.onNotificationsToggle,
              'icon': Icons.notifications_none_outlined,
              'isSwitch': true,
            },
            {
              'label': AppLocalizations.of(context)!.language,
              'value': widget.language == "en" ? AppLocalizations.of(context)!.english : AppLocalizations.of(context)!.ukrainian,
              'action': () => widget.onLanguageChange(
                    widget.language == "en" ? "uk" : "en",
                  ),
              'icon': Icons.language,
            },
          ],
        },
      ];

  @override
  Widget build(BuildContext context) {
    final userPhone = widget.user["phoneNumber"] ?? "";
    final displayName = widget.user['displayName']?.isNotEmpty == true ? widget.user['displayName'] : null;
    final email = widget.user['email'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white, // Фон білий, а не світло-блакитний, як у попередньому Flutter-коді
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // p-3 pb-20 space-y-4
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header ---
              _buildHeader(context)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),

              const SizedBox(height: 16),

        // --- User Info Card (motion.div) ---
        _buildUserInfoCard(userPhone, displayName, email)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),

              const SizedBox(height: 20),

              // --- Settings Sections ---
              ..._profileSections.map((section) {
                int sectionIndex = _profileSections.indexOf(section);
                return _buildSettingsSection(context, section)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: (200 + sectionIndex * 100).ms)
                    .slideY(begin: 0.1, end: 0);
              }).toList(),

              const SizedBox(height: 24),

              // --- Sign Out Button (motion.div) ---
              _buildSignOutButton()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.profileTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: sky700, // text-sky-700
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.profileSubtitle,
          style: const TextStyle(color: mutedForeground, fontSize: 13), // text-muted-foreground
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(String userPhone, String? displayName, String email) {
    // Card className="bg-gradient-to-r from-sky-50 to-cyan-50 border-sky-200"
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: sky200, width: 1),
      ),
      color: sky50, // Емуляція градієнта
      child: Padding(
        padding: const EdgeInsets.all(16.0), // p-4 sm:p-6
        child: Row(
          children: [
            // Avatar (bg-gradient-to-r from-sky-500 to-cyan-500)
            Container(
              width: 56, // w-16 sm:w-16
              height: 56, // h-16 sm:h-16
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [sky600, cyan50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 32), // w-8 h-8 text-white
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName ?? AppLocalizations.of(context)!.greeting, style: const TextStyle(fontWeight: FontWeight.w600, color: sky700)), // font-semibold text-sky-700
                if (email.isNotEmpty) Text(email, style: const TextStyle(color: mutedForeground, fontSize: 13)),
                if (email.isEmpty) Text(userPhone, style: const TextStyle(color: mutedForeground, fontSize: 13)), // text-sm text-muted-foreground
                const SizedBox(height: 4),
                // Removed demo user badge per request
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, Map<String, dynamic> section) {
  final sectionIcon = section['icon'] as IconData;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CardHeader
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), // pb-3
            child: Row(
              children: [
                Icon(sectionIcon, color: sky700, size: 20), // w-5 h-5 text-sky-700
                const SizedBox(width: 8),
                Text(
                  section['title'] as String,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sky700), // CardTitle text-sky-700
                ),
              ],
            ),
          ),
          // CardContent
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // pt-0, space-y-3
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: (section['items'] as List<Map<String, dynamic>>).map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: item['isSwitch'] == true
                      ? _buildSwitchItem(item: item)
                      : _buildSettingItem(item: item),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({required Map<String, dynamic> item}) {
  final itemIcon = item['icon'] as IconData;
    final String label = item['label'] as String;
    final String value = item['value'] as String;
    final VoidCallback onTap = item['action'] as VoidCallback;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      // bg-sky-50 rounded-lg hover:bg-sky-100 transition-colors
      child: Container(
        padding: const EdgeInsets.all(12), // p-3
        decoration: BoxDecoration(
          color: sky50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon wrapper (w-8 h-8 bg-white rounded-full)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(itemIcon, size: 16, color: sky600), // w-4 h-4 text-sky-600
                ),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: sky700, fontSize: 15)), // font-medium text-sky-700 text-sm sm:text-base
              ],
            ),
            Text(
              value,
              style: const TextStyle(color: mutedForeground, fontSize: 13), // text-muted-foreground text-xs sm:text-sm
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({required Map<String, dynamic> item}) {
  final itemIcon = item['icon'] as IconData;
    final String label = item['label'] as String;
    final VoidCallback onToggle = item['action'] as VoidCallback;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sky50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon wrapper
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(itemIcon, size: 16, color: sky600),
                ),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: sky700, fontSize: 15)),
              ],
            ),
              Switch(
                value: widget.notificationsEnabled,
                onChanged: (_) => onToggle(),
                activeThumbColor: sky600,
                activeTrackColor: sky600.withAlpha((0.24 * 255).round()), // Колір акценту
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: widget.onSignOut,
          style: OutlinedButton.styleFrom(
            foregroundColor: red600, // text-red-600
            backgroundColor: Colors.white,
            side: const BorderSide(color: red200, width: 1), // border-red-200
            minimumSize: const Size(double.infinity, 56), // w-full h-12 sm:h-14
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 20), // w-4 h-4 mr-2
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.signOut,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
        ),
      ],
    );
  }
}

// =========================================================================
// DIALOG
// =========================================================================

class _GoalSettingDialog extends StatefulWidget {
  final int initialGoal;
  final ValueChanged<int> onSave;

  const _GoalSettingDialog({required this.initialGoal, required this.onSave});

  @override
  _GoalSettingDialogState createState() => _GoalSettingDialogState();
}

class _GoalSettingDialogState extends State<_GoalSettingDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialGoal.toString());
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    final goal = int.tryParse(_controller.text.trim()) ?? 0;
    if (goal > 0 && goal <= 5000) {
      widget.onSave(goal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = int.tryParse(_controller.text.trim()) ?? 0;
    final isDisabled = goal <= 0 || goal > 5000;

    return AlertDialog(
      // Імітація w-[90vw] max-w-sm
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      
  // DialogHeader
  title: Text(AppLocalizations.of(context)!.setGoal, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
      
      // DialogContent
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input
            Text(AppLocalizations.of(context)!.dailyGoalMl, style: const TextStyle(fontSize: 14, color: mutedForeground)), // Label text-sm
            const SizedBox(height: 4),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: null,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.recommendedGoal,
              style: const TextStyle(fontSize: 11, color: mutedForeground), // text-xs text-muted-foreground
            ),
            const SizedBox(height: 24),

            // Buttons (flex gap-2)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(minimumSize: const Size(0, 44)), // min-h-[44px]
                    child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8), 
                Expanded(
                  child: ElevatedButton(
                    onPressed: isDisabled ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44), 
                      backgroundColor: sky600,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}