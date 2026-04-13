import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/complete_profile_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
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

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.setTransactionPinUseCase,
    required this.completeProfileUseCase,
  }) : super(CampusAuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<SetTransactionPinEvent>(_onSetTransactionPin);
    on<CompleteProfileEvent>(_onCompleteProfile);
  }

  CampusAuthState _determineNextState(UserEntity user) {
    // Check if profile is incomplete (matric number or institution is null or empty)
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

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<CampusAuthState> emit,
  ) async {
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
      (failure) => emit(CampusAuthError(message: failure.message)),
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
      (_) => emit(CampusAuthPinSetupSuccess()),
    );
  }
}
