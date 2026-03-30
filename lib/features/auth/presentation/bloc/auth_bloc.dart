import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, CampusAuthState> {
  final SupabaseClient supabaseClient;

  AuthBloc({required this.supabaseClient}) : super(CampusAuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    try {
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        emit(CampusAuthAuthenticated());
      } else {
        emit(CampusAuthUnauthenticated());
      }
    } catch (e) {
      emit(CampusAuthError(message: e.toString()));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    try {
      await supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      emit(CampusAuthAuthenticated());
    } on AuthException catch (e) {
      emit(CampusAuthError(message: e.message));
    } catch (e) {
      emit(const CampusAuthError(message: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    try {
      await supabaseClient.auth.signOut();
      emit(CampusAuthUnauthenticated());
    } catch (e) {
      emit(CampusAuthError(message: e.toString()));
    }
  }
}
