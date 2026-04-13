import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.dart' as di;
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase. Replace with actual URL and Anon Key later.
  // We use placeholder values to allow the app to compile and run the UI.
  await Supabase.initialize(
    url: 'https://zibhxlzfwbeznmkaablw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InppYmh4bHpmd2Jlem5ta2FhYmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4NjA5NTAsImV4cCI6MjA5MDQzNjk1MH0.6Fui2MPLzTf5lk-uo8aVUg7_4B8kbFL6cQltmOL7YhM',
  );

  // Initialize Dependency Injection
  await di.init();

  runApp(const CampusPayApp());
}
