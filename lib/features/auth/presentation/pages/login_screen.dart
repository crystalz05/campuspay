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

class _LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _headerSlide;
  late final Animation<Offset> _emailSlide;
  late final Animation<Offset> _passwordSlide;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    ));
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );
    _emailSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    ));
    _passwordSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    ));
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
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
        resizeToAvoidBottomInset: false, // Better for vertical centering when keyboard is not visible
        body: SafeArea(
          child: BlocConsumer<AuthBloc, CampusAuthState>(
            listener: (context, state) {
              if (state is CampusAuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: cs.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              } else {
                _handleNavigation(context, state);
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                              const SizedBox(height: 24),
                              // ── Animated Logo ──────────────────────
                              FadeTransition(
                                opacity: _logoFade,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: Center(
                                    child: Container(
                                      width: 80, height: 80,
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: [
                                          BoxShadow(
                                            color: cs.secondary.withValues(alpha: 0.3),
                                            blurRadius: 24, offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.account_balance_wallet_rounded, size: 44, color: cs.secondary),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              // ── Animated Header ────────────────────
                              FadeTransition(
                                opacity: _contentFade,
                                child: SlideTransition(
                                  position: _headerSlide,
                                  child: Column(
                                    children: [
                                      Text('Welcome Back', style: theme.textTheme.displayMedium, textAlign: TextAlign.center),
                                      const SizedBox(height: 6),
                                      Text('Login to your CampusPay account', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 44),
                              // ── Animated Email Field ───────────────
                              FadeTransition(
                                opacity: _contentFade,
                                child: SlideTransition(
                                  position: _emailSlide,
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(hintText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                                    validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // ── Animated Password Field ────────────
                              FadeTransition(
                                opacity: _contentFade,
                                child: SlideTransition(
                                  position: _passwordSlide,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // ── Forgot Password ────────────────────
                              FadeTransition(
                                opacity: _contentFade,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Forgot Password?')),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // ── Animated Button ────────────────────
                              FadeTransition(
                                opacity: _contentFade,
                                child: SlideTransition(
                                  position: _buttonSlide,
                                  child: ElevatedButton(
                                    onPressed: state is CampusAuthLoading ? null : _onLoginPressed,
                                    child: state is CampusAuthLoading
                                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                        : const Text('Login'),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // ── Register Link ──────────────────────
                              FadeTransition(
                                opacity: _contentFade,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Don't have an account?", style: theme.textTheme.bodyMedium),
                                    TextButton(onPressed: () => context.push('/register'), child: const Text('Register')),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
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
}
