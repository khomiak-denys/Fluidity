import 'package:flutter/material.dart';

// Для імітації іконок Lucide (Droplets, Smartphone, Lock)
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fluidity/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final void Function(BuildContext context, String email, String password) onLogin;
  final VoidCallback onRegister;
  final bool isLoading;
  final String? error;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    this.isLoading = false,
    this.error,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleSubmit() async {
    // Validate form then call onLogin
    if ((_formKey.currentState?.validate() ?? false)) {
      widget.onLogin(context, emailController.text.trim(), passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors used across the screen
    const Color sky50 = Color(0xFFF0F9FF);
    const Color cyan50 = Color(0xFFECFEFF);
    const Color sky500 = Color(0xFF0EA5E9);
    const Color cyan500 = Color(0xFF06B6D4);
    const Color sky700 = Color(0xFF0369A1);
    const Color sky200 = Color(0xFFBAE6FD);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [sky50, Colors.white, cyan50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LogoAndTitle(sky500: sky500, cyan500: cyan500),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: sky200, width: 1),
                    ),
                    color: Colors.white.withAlpha((0.8 * 255).round()),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.loginTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: sky700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),

                          _LabelWithIcon(icon: LucideIcons.smartphone, text: AppLocalizations.of(context)!.emailLabel),
                          const SizedBox(height: 4),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.emailHint,
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.emailEmptyError;
                                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(v.trim())) return AppLocalizations.of(context)!.emailInvalidError;
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),
                          _LabelWithIcon(icon: LucideIcons.lock, text: AppLocalizations.of(context)!.passwordLabel),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.passwordHint,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return AppLocalizations.of(context)!.passwordEmptyError;
                              if (v.length < 6) return AppLocalizations.of(context)!.passwordLengthError;
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: widget.isLoading ? null : handleSubmit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              foregroundColor: Colors.white,
                              backgroundColor: sky500,
                            ),
                            child: widget.isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(AppLocalizations.of(context)!.loginButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const _FeaturesPreview(),
                  const SizedBox(height: 16),
                  TextButton(onPressed: widget.onRegister, child: Text(AppLocalizations.of(context)!.noAccountRegister)),
                  if (widget.error != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Допоміжний віджет для Logo and Title
class _LogoAndTitle extends StatelessWidget {
  final Color sky500;
  final Color cyan500;

  const _LogoAndTitle({required this.sky500, required this.cyan500});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 64,
          height: 64,
          // bg-gradient-to-r from-sky-500 to-cyan-500
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [sky500, cyan500]),
            borderRadius: BorderRadius.circular(32),
          ),
                child: const Icon(LucideIcons.droplets, color: Colors.white, size: 32), // Droplets icon
        ),
        const SizedBox(height: 16),
        // Title (h1)
        Text(
          'Fluidity',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            // bg-gradient-to-r from-sky-600 to-cyan-600 bg-clip-text text-transparent
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [sky500.withAlpha((0.9 * 255).round()), cyan500.withAlpha((0.9 * 255).round())],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 50.0)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.appSubtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}

// Допоміжний віджет для Label
class _LabelWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LabelWithIcon({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// Допоміжний віджет для Features Preview
class _FeaturesPreview extends StatelessWidget {
  const _FeaturesPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FeatureItem(
                icon: LucideIcons.droplets,
                text: AppLocalizations.of(context)!.featureTracking,
                bgColor: const Color(0xFFE0F7FF), // bg-sky-100
                iconColor: const Color(0xFF0284C7), // text-sky-600
              ),
              _FeatureItem(
                icon: Icons.check_circle_outline,
                text: AppLocalizations.of(context)!.featureGoals,
                bgColor: const Color(0xFFF0FFF4), // bg-green-100 (імітація)
                iconColor: const Color(0xFF16A34A), // text-green-600 (імітація)
              ),
              _FeatureItem(
                icon: Icons.notifications_none,
                text: AppLocalizations.of(context)!.featureReminders,
                bgColor: const Color(0xFFFFF7ED), // bg-orange-100 (імітація)
                iconColor: const Color(0xFFEA580C), // text-orange-600 (імітація)
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Допоміжний віджет для окремого елемента Features Preview
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color iconColor;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}