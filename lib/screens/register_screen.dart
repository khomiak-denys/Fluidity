import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluidity/l10n/app_localizations.dart';

const Color _regSky50 = Color(0xFFF0F9FF);
const Color _regCyan50 = Color(0xFFECFEFF);
const Color _regSky500 = Color(0xFF0EA5E9);
const Color _regCyan500 = Color(0xFF06B6D4);
const Color _regSky700 = Color(0xFF0369A1);
const Color _regSky200 = Color(0xFFBAE6FD);

class RegisterScreen extends StatefulWidget {
  final void Function(BuildContext context, String firstName, String lastName, String email, String password)? onRegister;
  final bool isLoading;
  final String? error;

  const RegisterScreen({Key? key, this.onRegister, this.isLoading = false, this.error}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if ((_formKey.currentState?.validate() ?? false)) {
      widget.onRegister?.call(context, _firstNameCtrl.text.trim(), _lastNameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // use the module-level constants for colors so they are referenced
          gradient: LinearGradient(colors: [_regSky50, Colors.white, _regCyan50], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RegisterLogoAndTitle(sky500: _regSky500, cyan500: _regCyan500, titleText: AppLocalizations.of(context)!.registerTitle),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: _regSky200, width: 1)),
                    color: Colors.white.withAlpha((0.92 * 255).round()),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(AppLocalizations.of(context)!.createAccountTitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _regSky700)),
                            const SizedBox(height: 6),
                            Text(AppLocalizations.of(context)!.createAccountSubtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            const SizedBox(height: 18),
                            _buildInputField(controller: _firstNameCtrl, label: AppLocalizations.of(context)!.firstNameLabel, hint: AppLocalizations.of(context)!.firstNameHint, icon: LucideIcons.user, validatorText: AppLocalizations.of(context)!.firstNameEmptyError),
                            const SizedBox(height: 12),
                            _buildInputField(controller: _lastNameCtrl, label: AppLocalizations.of(context)!.lastNameLabel, hint: AppLocalizations.of(context)!.lastNameHint, icon: LucideIcons.user, validatorText: AppLocalizations.of(context)!.lastNameEmptyError),
                            const SizedBox(height: 12),
                            _buildInputField(controller: _emailCtrl, label: AppLocalizations.of(context)!.emailLabel, hint: AppLocalizations.of(context)!.emailHint, icon: LucideIcons.smartphone, keyboardType: TextInputType.emailAddress, validatorText: AppLocalizations.of(context)!.emailEmptyError, validator: (v) { if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.emailEmptyError; final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+'); if (!emailRegex.hasMatch(v.trim())) return AppLocalizations.of(context)!.emailInvalidError; return null; }),
                            const SizedBox(height: 12),
                            _buildInputField(controller: _passwordCtrl, label: AppLocalizations.of(context)!.passwordLabel, hint: AppLocalizations.of(context)!.passwordHint, icon: LucideIcons.lock, obscureText: true, validatorText: AppLocalizations.of(context)!.passwordEmptyError, validator: (v) => (v == null || v.length < 6) ? AppLocalizations.of(context)!.passwordLengthError : null),
                            const SizedBox(height: 18),
                            ElevatedButton(onPressed: widget.isLoading ? null : _submit, style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(46), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), foregroundColor: Colors.white, backgroundColor: _regSky500), child: Text(AppLocalizations.of(context)!.registerButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                            if (widget.error != null) ...[const SizedBox(height: 10), Text(widget.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const _RegisterFeaturesPreview(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required String hint, required IconData icon, required String validatorText, TextInputType keyboardType = TextInputType.text, bool obscureText = false, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _RegisterLabelWithIcon(icon: icon, text: label),
      const SizedBox(height: 6),
      TextFormField(controller: controller, keyboardType: keyboardType, obscureText: obscureText, decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12)), validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? validatorText : null),
    ]);
  }
}

class _RegisterLogoAndTitle extends StatelessWidget {
  final Color sky500;
  final Color cyan500;
  final String titleText;

  const _RegisterLogoAndTitle({required this.sky500, required this.cyan500, this.titleText = 'Fluidity'});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(gradient: LinearGradient(colors: [sky500, cyan500]), borderRadius: BorderRadius.circular(32)), child: const Icon(LucideIcons.droplets, color: Colors.white, size: 32)),
      const SizedBox(height: 12),
      Text(titleText, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, foreground: Paint()..shader = LinearGradient(colors: [sky500.withAlpha((0.9 * 255).round()), cyan500.withAlpha((0.9 * 255).round())]).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 50.0)))),
      const SizedBox(height: 6),
      Text(AppLocalizations.of(context)!.appSubtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ]);
  }
}

class _RegisterLabelWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RegisterLabelWithIcon({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 16, color: _regSky700.withAlpha((0.85 * 255).round())), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87))]);
  }
}

class _RegisterFeaturesPreview extends StatelessWidget {
  const _RegisterFeaturesPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _RegisterFeatureItem(icon: LucideIcons.droplets, text: AppLocalizations.of(context)!.featureTracking, bgColor: const Color(0xFFE0F7FF), iconColor: const Color(0xFF0284C7)),
          _RegisterFeatureItem(icon: Icons.check_circle_outline, text: AppLocalizations.of(context)!.featureGoals, bgColor: const Color(0xFFF0FFF4), iconColor: const Color(0xFF16A34A)),
          _RegisterFeatureItem(icon: Icons.notifications_none, text: AppLocalizations.of(context)!.featureReminders, bgColor: const Color(0xFFFFF7ED), iconColor: const Color(0xFFEA580C)),
        ],
      ),
    );
  }
}

class _RegisterFeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color iconColor;

  const _RegisterFeatureItem({required this.icon, required this.text, required this.bgColor, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: iconColor, size: 20)), const SizedBox(height: 4), Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey))]);
  }
}
