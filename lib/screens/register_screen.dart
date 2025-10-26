import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Визначення кольорів
const Color sky50 = Color(0xFFF0F9FF);
const Color cyan50 = Color(0xFFECFEFF);
const Color sky500 = Color(0xFF0EA5E9);
const Color cyan500 = Color(0xFF06B6D4);
const Color sky700 = Color(0xFF0369A1);
const Color sky200 = Color(0xFFBAE6FD);

class RegisterScreen extends StatefulWidget {
  final Future<bool> Function(String firstName, String lastName, String email, String password)? onRegister;
  final bool isLoading;
  final String? error;

  const RegisterScreen({Key? key, this.onRegister, this.isLoading = false, this.error}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Анімація для імітації motion.div
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // If an onRegister callback is provided, call it and handle result.
      final first = _firstNameCtrl.text.trim();
      final last = _lastNameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final pass = _passwordCtrl.text;

      if (widget.onRegister != null) {
        final ok = await widget.onRegister!(first, last, email, pass);
        if (!mounted) return;
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Реєстрація успішна (імітація)')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Реєстрація не вдалася')),
          );
        }
      } else {
        // Fallback: local mock behaviour
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Реєстрація успішна (імітація)')),
        );
        Navigator.of(context).pop(); // Повернення на екран входу
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar (Імітуємо відсутність AppBar як на екрані Login, але додаємо кнопку "Назад") ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Іконка для повернення назад, щоб не руйнувати градієнтний фон
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: sky700),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true, // Розтягуємо фон за AppBar

      // --- Body з градієнтом ---
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [sky50, Colors.white, cyan50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ScaleTransition( // Імітація motion.div
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. Logo and Title ---
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, opacityValue, child) {
                        return Opacity(
                          opacity: opacityValue,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20 * (1 - opacityValue)),
                            child: child,
                          ),
                        );
                      },
                      child: const _LogoAndTitle(sky500: sky500, cyan500: cyan500, titleText: 'Реєстрація'),
                    ),

                    const SizedBox(height: 16),

                    // --- 2. Card з формою ---
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: sky200, width: 1),
                      ),
                                   color: Colors.white.withAlpha((0.8 * 255).round()),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // CardHeader
                              const Text(
                                'Створення акаунту',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: sky700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Заповніть форму для початку відстеження води',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // --- Form Fields ---
                              _buildInputField(
                                controller: _firstNameCtrl,
                                label: 'Ім\'я',
                                icon: LucideIcons.user,
                                validatorText: 'Введіть ім\'я',
                              ),
                              const SizedBox(height: 16),
                              
                              _buildInputField(
                                controller: _lastNameCtrl,
                                label: 'Прізвище',
                                icon: LucideIcons.user,
                                validatorText: 'Введіть прізвище',
                              ),
                              const SizedBox(height: 16),

                              _buildInputField(
                                controller: _emailCtrl,
                                label: 'Email',
                                icon: LucideIcons.smartphone,
                                keyboardType: TextInputType.emailAddress,
                                validatorText: 'Введіть email',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Введіть email';
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                  if (!emailRegex.hasMatch(v.trim())) return 'Неправильний формат email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              _buildInputField(
                                controller: _passwordCtrl,
                                label: 'Пароль',
                                icon: LucideIcons.lock,
                                obscureText: true,
                                validatorText: 'Мінімум 6 символів',
                                validator: (v) => (v == null || v.length < 6) ? 'Мінімум 6 символів' : null,
                              ),
                              
                              const SizedBox(height: 24),

                              // Register Button
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(44),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  foregroundColor: Colors.white,
                                  backgroundColor: sky500,
                                ),
                                child: const Text(
                                  'Зареєструватися',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (widget.error != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  widget.error!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- Optional Features Preview (Можна прибрати, якщо він потрібен тільки на Login) ---
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, opacityValue, child) {
                        return Opacity(
                          opacity: opacityValue,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20 * (1 - opacityValue)),
                            child: child,
                          ),
                        );
                      },
                      child: const _FeaturesPreview(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Допоміжна функція для створення стилізованих полів вводу
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabelWithIcon(icon: icon, text: label),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: 'Введіть $label',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? validatorText : null,
        ),
      ],
    );
  }
}

// =========================================================================
// WIDGETS SECTION (КОПІЇ З LOGIN_SCREEN.dart)
// =========================================================================

class _LogoAndTitle extends StatelessWidget {
  final Color sky500;
  final Color cyan500;
  final String titleText;

  const _LogoAndTitle({required this.sky500, required this.cyan500, this.titleText = 'Fluidity'});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [sky500, cyan500]),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(LucideIcons.droplets, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          titleText,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [sky500.withAlpha((0.9 * 255).round()), cyan500.withAlpha((0.9 * 255).round())],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 50.0)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ваша персональна система контролю води', 
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}

class _LabelWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LabelWithIcon({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
  Icon(icon, size: 16, color: sky700.withAlpha((0.8 * 255).round())),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }
}

class _FeaturesPreview extends StatelessWidget {
  const _FeaturesPreview();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _FeatureItem(
            icon: LucideIcons.droplets,
            text: 'Відстежування',
            bgColor: Color(0xFFE0F7FF),
            iconColor: Color(0xFF0284C7),
          ),
          _FeatureItem(
            icon: Icons.check_circle_outline,
            text: 'Цілі',
            bgColor: Color(0xFFF0FFF4),
            iconColor: Color(0xFF16A34A),
          ),
          _FeatureItem(
            icon: Icons.notifications_none,
            text: 'Нагадування',
            bgColor: Color(0xFFFFF7ED),
            iconColor: Color(0xFFEA580C),
          ),
        ],
      ),
    );
  }
}

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