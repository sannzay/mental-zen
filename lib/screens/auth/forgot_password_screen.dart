import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await auth.sendPasswordReset(_emailController.text.trim());
    if (auth.errorMessage == null && mounted) {
      setState(() {
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Card(
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
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            auth.errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                          ),
                        ],
                        if (_emailSent) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Password reset email sent',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondary,
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
                              : const Text('Send reset link'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


