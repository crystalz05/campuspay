import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.dart' as di;
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase. Replace with actual URL and Anon Key later.
  // We use placeholder values to allow the app to compile and run the UI.
  await Supabase.initialize(
    url: 'https://placeholder.supabase.co',
    anonKey: 'placeholder_anon_key',
  );

  // Initialize Dependency Injection
  await di.init();

  runApp(const CampusPayApp());
}
