import 'package:flutter/material.dart';

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

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleSubmit() async {
    if (phoneController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      await widget.onLogin(phoneController.text, passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FF), Colors.white, Color(0xFF06C6D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)]),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.opacity, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Fluidity',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, foreground: Paint()..shader = LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.white.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Номер телефону',
                          prefixIcon: Icon(Icons.smartphone),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          backgroundColor: const Color(0xFF0EA5E9),
                        ),
                        child: const Text('Увійти'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
