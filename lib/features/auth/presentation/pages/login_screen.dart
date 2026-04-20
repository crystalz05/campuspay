import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  void _handleNavigation(BuildContext context, CampusAuthState state) {
    if (state is CampusAuthAuthenticated) {
      context.go('/dashboard');
    } else if (state is CampusAuthProfileIncomplete) {
      context.go('/complete-profile');
    } else if (state is CampusAuthPinSetupRequired) {
      context.go('/set-pin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<AuthBloc, CampusAuthState>(
            listener: (context, state) {
              if (state is CampusAuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: cs.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              } else if (state is CampusAuthVerificationRequired) {
                _showSuccessDialog(state.email);
              } else {
                _handleNavigation(context, state);
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 48),
                              
                              // ── Minimalist Logo/Icon ──────────────────────
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: cs.primary.withValues(alpha: 0.1), width: 1.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.account_balance_rounded, 
                                    size: 40, 
                                    color: cs.primary
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              
                              // ── Elegant Header ────────────────────
                              Text(
                                'Welcome Back', 
                                style: theme.textTheme.displayMedium, 
                                textAlign: TextAlign.center
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue to CampusPay.', 
                                style: theme.textTheme.bodyMedium, 
                                textAlign: TextAlign.center
                              ),
                              const SizedBox(height: 48),
                              
                              // ── Form Inputs ───────────────
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'Email Address', 
                                  prefixIcon: Icon(Icons.email_outlined, size: 22)
                                ),
                                validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                              ),
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline, size: 22),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 22),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
                              ),
                              const SizedBox(height: 8),
                              
                              // ── Forgot Password ────────────────────
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push('/forgot-password'), 
                                  child: const Text('Forgot Password?')
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // ── Solid Button ────────────────────
                              ElevatedButton(
                                onPressed: state is CampusAuthLoading ? null : _onLoginPressed,
                                child: state is CampusAuthLoading
                                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.onPrimary))
                                    : const Text('Sign In'),
                              ),
                              const SizedBox(height: 32),
                              
                              // ── Register Link ──────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Don't have an account?", style: theme.textTheme.bodyMedium),
                                  TextButton(onPressed: () => context.push('/register'), child: const Text('Create Account')),
                                ],
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verification Pending'),
        content: Text(
          'Your email ($email) is not verified. A new verification link has been sent to your inbox. Please check your inbox to activate your account.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
