import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await auth.signIn(_emailController.text.trim(), _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Mental Zen',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A private space for your thoughts',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome back',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                if (!pattern.hasMatch(value.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            if (auth.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                auth.errorMessage!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.error,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: auth.isLoading ? null : _submit,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Sign in'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('New here?'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Create an account'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


