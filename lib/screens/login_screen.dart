import 'package:flutter/material.dart';

// Для імітації іконок Lucide (Droplets, Smartphone, Lock)
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  final Future<bool> Function(String phoneNumber, String password) onLogin;
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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Імітація анімації motion.div за допомогою контролера
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Контролер для анімації входу (duration: 0.5)
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
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleSubmit() async {
    // Ваша логіка перевірки та виклику onLogin
    if (phoneController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      await widget.onLogin(phoneController.text, passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Визначення кольорів
    const Color sky50 = Color(0xFFF0F9FF);
    const Color cyan50 = Color(0xFFECFEFF);
    const Color sky500 = Color(0xFF0EA5E9);
    const Color cyan500 = Color(0xFF06B6D4);
    const Color sky700 = Color(0xFF0369A1); // Приблизно для CardTitle
    const Color sky200 = Color(0xFFBAE6FD); // Приблизно для border-sky-200

    return Scaffold(
      // 1. Градієнт фону (bg-gradient-to-br from-sky-50 via-white to-cyan-50)
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
            constraints: const BoxConstraints(maxWidth: 400), // max-w-sm mx-auto
            child: ScaleTransition( // Імітація motion.div (initial={{ opacity: 0, scale: 0.9 }})
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 2. Logo and Title ---
                    // Використовуємо AnimatedOpacity для імітації затримки (delay: 0.2)
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
                      child: const _LogoAndTitle(sky500: sky500, cyan500: cyan500),
                    ),

                    const SizedBox(height: 16),

                    // --- 3. Card ---
                    // bg-white/80 backdrop-blur-sm border-sky-200 shadow-xl
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: sky200, width: 1),
                      ),
                      color: Colors.white.withOpacity(0.8), // bg-white/80
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // CardHeader
                            Text(
                              'Вхід',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: sky700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Для демонстрації введіть будь-які дані',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey, // text-muted-foreground
                              ),
                            ),
                            const SizedBox(height: 24),

                            // CardContent - Phone Input
                            _LabelWithIcon(icon: LucideIcons.smartphone, text: 'Номер телефону'),
                            const SizedBox(height: 4),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: '+380 XX XXX XX XX',
                                border: OutlineInputBorder(), // Імітація <Input />
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // CardContent - Password Input
                            _LabelWithIcon(icon: LucideIcons.lock, text: 'Пароль'),
                            const SizedBox(height: 4),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Введіть пароль',
                                border: OutlineInputBorder(), // Імітація <Input />
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            ElevatedButton(
                              onPressed: widget.isLoading ? null : handleSubmit,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                // bg-gradient-to-r from-sky-500 to-cyan-500
                                foregroundColor: Colors.white,
                                backgroundColor: sky500, // Базовий колір для градієнта
                              ),
                              child: widget.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Увійти',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- 4. Features Preview (Імітація motion.div з delay: 0.6) ---
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
                    
                    // --- 5. Register Button (Залишаємо внизу для зручності) ---
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: widget.onRegister, // Використовуємо prop onRegister
                      child: const Text('Немає аккаунта? Зареєструватися'),
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
                colors: [sky500.withOpacity(0.9), cyan500.withOpacity(0.9)],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 50.0)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          // t('') - імітація підзаголовка
          'Ваша персональна система контролю води', 
          style: TextStyle(fontSize: 14, color: Colors.grey),
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
            children: const [
              _FeatureItem(
                icon: LucideIcons.droplets,
                text: 'Відстежування',
                bgColor: Color(0xFFE0F7FF), // bg-sky-100
                iconColor: Color(0xFF0284C7), // text-sky-600
              ),
              _FeatureItem(
                icon: Icons.check_circle_outline,
                text: 'Цілі',
                bgColor: Color(0xFFF0FFF4), // bg-green-100 (імітація)
                iconColor: Color(0xFF16A34A), // text-green-600 (імітація)
              ),
              _FeatureItem(
                icon: Icons.notifications_none,
                text: 'Нагадування',
                bgColor: Color(0xFFFFF7ED), // bg-orange-100 (імітація)
                iconColor: Color(0xFFEA580C), // text-orange-600 (імітація)
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