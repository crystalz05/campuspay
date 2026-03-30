import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class CampusPayApp extends StatelessWidget {
  const CampusPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CampusPay',
      theme: CampusPayTheme.lightTheme,
      darkTheme: CampusPayTheme.darkTheme,
      themeMode: ThemeMode.system, // follows device appearance setting
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
