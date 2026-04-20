import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/complete_profile_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/resend_verification_usecase.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, CampusAuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SetTransactionPinUseCase setTransactionPinUseCase;
  final CompleteProfileUseCase completeProfileUseCase;
  final ResendVerificationUseCase resendVerificationUseCase;

  // Supabase auth state stream subscription — listens for deep-link auth events
  // like PASSWORD_RECOVERY so the router can redirect correctly.
  late final StreamSubscription<supabase.AuthState> _authStateSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.setTransactionPinUseCase,
    required this.completeProfileUseCase,
    required this.resendVerificationUseCase,
  }) : super(CampusAuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshUserEvent>(_onRefreshUser);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResendVerificationEmailEvent>(_onResendVerificationEmail);
    on<ResetPasswordEvent>(_onResetPassword);
    on<SetTransactionPinEvent>(_onSetTransactionPin);
    on<CompleteProfileEvent>(_onCompleteProfile);
    on<AuthStateChangedEvent>(_onAuthStateChanged);

    // Subscribe to Supabase's native auth state stream.
    // This is the only reliable way to detect PASSWORD_RECOVERY events
    // that arrive via deep links, since they are not triggered through our use cases.
    _authStateSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange.listen(
      (authState) {
        log(
          'Supabase auth event received: ${authState.event}',
          name: 'AuthBloc',
        );
        add(AuthStateChangedEvent(authState.event));
      },
      onError: (e) => log('Supabase auth stream error: $e', name: 'AuthBloc'),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  CampusAuthState _determineNextState(UserEntity user) {
    final isProfileIncomplete = (user.matricNumber?.isEmpty ?? true) ||
                                (user.institution?.isEmpty ?? true);
    if (isProfileIncomplete) {
      return CampusAuthProfileIncomplete(user: user);
    }
    if (!user.isPinSet) {
      return CampusAuthPinSetupRequired(user: user);
    }
    return CampusAuthAuthenticated(user: user);
  }

  Future<void> _onAuthStateChanged(
    AuthStateChangedEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    switch (event.event) {
      case supabase.AuthChangeEvent.passwordRecovery:
        // User tapped the reset-password deep link — signal the router to redirect.
        log('PASSWORD_RECOVERY event — emitting CampusAuthPasswordRecovery', name: 'AuthBloc');
        emit(CampusAuthPasswordRecovery());
        break;
      case supabase.AuthChangeEvent.signedOut:
        emit(CampusAuthUnauthenticated());
        break;
      case supabase.AuthChangeEvent.signedIn:
      case supabase.AuthChangeEvent.initialSession:
        // Deep links triggering sign-in need to be explicitly handled
        add(CheckAuthStatusEvent());
        break;
      default:
        break;
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    // Don't overwrite the PasswordRecovery state — the user is mid-reset flow.
    if (state is CampusAuthPasswordRecovery) return;

    emit(CampusAuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => emit(CampusAuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(_determineNextState(user));
        } else {
          emit(CampusAuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onRefreshUser(
    RefreshUserEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    // Only refresh quietly if they are already authenticated.
    if (state is! CampusAuthAuthenticated) return;
    
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => null, // Silently ignore failures on background refresh
      (user) {
        if (user != null) {
          emit(CampusAuthAuthenticated(user: user));
        }
      },
    );
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) {
        if (failure.message == 'email-not-verified') {
          // Automatically trigger resend and drop them into the verification required state
          add(ResendVerificationEmailEvent(event.email));
        } else {
          emit(CampusAuthError(message: failure.message));
        }
      },
      (user) => emit(_determineNextState(user)),
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    final result = await registerUseCase(RegisterParams(
      fullName: event.fullName,
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(CampusAuthError(message: failure.message)),
      (user) => emit(CampusAuthVerificationRequired(email: event.email)),
    );
  }

  Future<void> _onCompleteProfile(
    CompleteProfileEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    final result = await completeProfileUseCase(CompleteProfileParams(
      matricNumber: event.matricNumber,
      institution: event.institution,
    ));
    result.fold(
      (failure) => emit(CampusAuthError(message: failure.message)),
      (user) => emit(_determineNextState(user)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    await logoutUseCase(NoParams());
    emit(CampusAuthUnauthenticated());
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    final result = await forgotPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(CampusAuthError(message: failure.message)),
      (_) => emit(CampusAuthPasswordResetSent()),
    );
  }

  Future<void> _onResendVerificationEmail(
    ResendVerificationEmailEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    // We don't want to show a global loading screen that removes the dialog,
    // so we just execute this silently or emit a specific state if needed.
    // For now, we'll keep the current state and just fire the request.
    final result = await resendVerificationUseCase(event.email);
    result.fold(
      (failure) => emit(CampusAuthError(message: failure.message)),
      (_) => emit(CampusAuthVerificationRequired(email: event.email)),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    final result = await resetPasswordUseCase(event.newPassword);
    result.fold(
      (failure) => emit(CampusAuthError(message: failure.message)),
      (_) => emit(CampusAuthPasswordResetSuccess()),
    );
  }

  Future<void> _onSetTransactionPin(
    SetTransactionPinEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
    emit(CampusAuthLoading());
    final result = await setTransactionPinUseCase(event.pin);
    result.fold(
      (failure) => emit(CampusAuthError(message: failure.message)),
      (_) async {
        final userResult = await getCurrentUserUseCase(NoParams());
        userResult.fold(
          (failure) => emit(CampusAuthPinSetupSuccess()),
          (user) {
            if (user != null) {
              emit(CampusAuthAuthenticated(user: user));
            } else {
              emit(CampusAuthPinSetupSuccess());
            }
          },
        );
      },
    );
  }
}

