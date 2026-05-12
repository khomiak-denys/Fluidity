import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluidity/l10n/app_localizations.dart';
import 'package:fluidity/ui/theme_tokens.dart';

import 'view_models/profile_view_models.dart';

const Color sky50 = AppColors.sky50;
const Color cyan50 = AppColors.cyan50;
const Color sky200 = AppColors.sky200;
const Color sky600 = AppColors.sky600;
const Color sky700 = AppColors.sky700;
const Color red600 = Color(0xFFDC2626);
const Color red200 = Color(0xFFFECACA);
const Color mutedForeground = AppColors.mutedForeground;

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

  List<ProfileSectionViewModel> get _profileSections =>
      ProfileSectionsBuilder.build(
        loc: AppLocalizations.of(context)!,
        dailyGoal: widget.dailyGoal,
        notificationsEnabled: widget.notificationsEnabled,
        onGoalTap: _showGoalDialog,
        onNotificationsToggle: widget.onNotificationsToggle,
        language: widget.language,
        onLanguageChange: widget.onLanguageChange,
      );

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
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.dailyGoal}: $newGoal мл'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPhone = widget.user['phoneNumber'] ?? '';
    final displayName = widget.user['displayName']?.isNotEmpty == true
        ? widget.user['displayName']
        : null;
    final email = widget.user['email'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),
              const SizedBox(height: 16),
              _buildUserInfoCard(userPhone, displayName, email)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.0, 1.0)),
              const SizedBox(height: 20),
              ..._profileSections.map((section) {
                final sectionIndex = _profileSections.indexOf(section);
                return _buildSettingsSection(context, section)
                    .animate()
                    .fadeIn(
                        duration: 500.ms, delay: (200 + sectionIndex * 100).ms)
                    .slideY(begin: 0.1, end: 0);
              }),
              const SizedBox(height: 24),
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
            color: sky700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.profileSubtitle,
          style: const TextStyle(color: mutedForeground, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(
      String userPhone, String? displayName, String email) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: sky200, width: 1),
      ),
      color: sky50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [sky600, cyan50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName ?? AppLocalizations.of(context)!.greeting,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: sky700),
                ),
                if (email.isNotEmpty)
                  Text(email,
                      style: const TextStyle(
                          color: mutedForeground, fontSize: 13)),
                if (email.isEmpty)
                  Text(userPhone,
                      style: const TextStyle(
                          color: mutedForeground, fontSize: 13)),
                const SizedBox(height: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      BuildContext context, ProfileSectionViewModel section) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Icon(section.icon, color: sky700, size: 20),
                const SizedBox(width: 8),
                Text(
                  section.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: sky700),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: section.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: item.kind == ProfileItemKind.toggle
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

  Widget _buildSettingItem({required ProfileItemViewModel item}) {
    return InkWell(
      onTap: item.action,
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(item.icon, size: 16, color: sky600),
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: sky700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Text(
              item.value,
              style: const TextStyle(color: mutedForeground, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({required ProfileItemViewModel item}) {
    return InkWell(
      onTap: item.action,
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(item.icon, size: 16, color: sky600),
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: sky700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Switch(
              value: widget.notificationsEnabled,
              onChanged: (_) => item.action(),
              activeThumbColor: sky600,
              activeTrackColor: sky600.withAlpha((0.24 * 255).round()),
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
            foregroundColor: red600,
            backgroundColor: Colors.white,
            side: const BorderSide(color: red200, width: 1),
            minimumSize: const Size(double.infinity, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.signOut,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Text(
        AppLocalizations.of(context)!.setGoal,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.dailyGoalMl,
              style: const TextStyle(fontSize: 14, color: mutedForeground),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: null,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.recommendedGoal,
              style: const TextStyle(fontSize: 11, color: mutedForeground),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: const TextStyle(fontSize: 16),
                    ),
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
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
