import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matricController = TextEditingController();
  final _institutionController = TextEditingController();

  @override
  void dispose() {
    _matricController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  void _onComplete() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            CompleteProfileEvent(
              matricNumber: _matricController.text.trim(),
              institution: _institutionController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, CampusAuthState>(
        listener: (context, state) {
          if (state is CampusAuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is CampusAuthPinSetupRequired) {
            context.go('/set-pin');
          } else if (state is CampusAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: cs.error),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                        Text(
                          'Final Step',
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please provide your academic details to continue.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _matricController,
                          decoration: const InputDecoration(
                            hintText: 'Matric Number',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your matric number'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _institutionController,
                          decoration: const InputDecoration(
                            hintText: 'Institution',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please enter your school' : null,
                        ),
                        const SizedBox(height: 48),
                        BlocBuilder<AuthBloc, CampusAuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is CampusAuthLoading ? null : _onComplete,
                              child: state is CampusAuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Complete & Next'),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
                            child: Text(
                              'Logout',
                              style: TextStyle(color: cs.error),
                            ),
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
        ),
      ),
    );
  }
}
