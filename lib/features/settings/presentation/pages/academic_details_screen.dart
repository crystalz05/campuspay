import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AcademicDetailsScreen extends StatefulWidget {
  const AcademicDetailsScreen({super.key});

  @override
  State<AcademicDetailsScreen> createState() => _AcademicDetailsScreenState();
}

class _AcademicDetailsScreenState extends State<AcademicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _matricController;
  String? _selectedInstitution;

  final List<String> _institutions = [
    'University of Lagos',
    'Obafemi Awolowo University',
    'University of Ibadan',
    'Covenant University',
    'Lagos State University',
    'Babcock University',
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is CampusAuthAuthenticated) {
      _matricController = TextEditingController(text: authState.user.matricNumber);
      _selectedInstitution = authState.user.institution;
      if (_selectedInstitution != null && !_institutions.contains(_selectedInstitution)) {
        _institutions.add(_selectedInstitution!);
      }
    } else {
      _matricController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _matricController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(UpdateProfileEvent(
        matricNumber: _matricController.text.trim(),
        institution: _selectedInstitution,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Details'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, CampusAuthState>(
        listener: (context, state) {
          if (state is CampusAuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Academic details updated successfully'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          } else if (state is CampusAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CampusAuthLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildFieldLabel('Matriculation Number'),
                TextFormField(
                  controller: _matricController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    hintText: 'e.g. CS/2020/1234',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter your matric number' : null,
                ),
                const SizedBox(height: 24),
                _buildFieldLabel('Institution'),
                DropdownButtonFormField<String>(
                  value: _selectedInstitution,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: _institutions.map((inst) {
                    return DropdownMenuItem(
                      value: inst,
                      child: Text(inst),
                    );
                  }).toList(),
                  onChanged: isLoading ? null : (v) {
                    setState(() {
                      _selectedInstitution = v;
                    });
                  },
                  validator: (v) => (v == null || v.isEmpty) ? 'Please select an institution' : null,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: isLoading ? null : _onSave,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Update Details'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
