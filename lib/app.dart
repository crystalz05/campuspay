import 'package:campuspay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class CampusPayApp extends StatelessWidget {
  const CampusPayApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()))
        ],
        child: Builder(
          builder: (context) {
            final router = AppRouter.createRouter(context.read<AuthBloc>());
            
            return MaterialApp.router(
              title: 'CampusPay',
              theme: CampusPayTheme.lightTheme,
              darkTheme: CampusPayTheme.darkTheme,
              themeMode: ThemeMode.system, // follows device appearance setting
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
          }
        )
    );
  }
}
