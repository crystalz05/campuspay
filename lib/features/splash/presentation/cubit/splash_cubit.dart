import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SplashState {}
class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashNavigateToLogin extends SplashState {}
class SplashNavigateToHome extends SplashState {}

class SplashCubit extends Cubit<SplashState> {
  final SupabaseClient supabaseClient;

  SplashCubit({required this.supabaseClient}) : super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());
    // Simulate some initialization time for effect
    await Future.delayed(const Duration(seconds: 2));

    final session = supabaseClient.auth.currentSession;
    if (session != null) {
      emit(SplashNavigateToHome());
    } else {
      emit(SplashNavigateToLogin());
    }
  }
}
