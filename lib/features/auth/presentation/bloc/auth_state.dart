import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class CampusAuthState extends Equatable {
  const CampusAuthState();

  @override
  List<Object?> get props => [];
}

class CampusAuthInitial extends CampusAuthState {}

class CampusAuthLoading extends CampusAuthState {}

class CampusAuthAuthenticated extends CampusAuthState {
  final UserEntity user;

  const CampusAuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class CampusAuthUnauthenticated extends CampusAuthState {}

class CampusAuthVerificationRequired extends CampusAuthState {
  final String email;

  const CampusAuthVerificationRequired({required this.email});

  @override
  List<Object?> get props => [email];
}

class CampusAuthProfileIncomplete extends CampusAuthState {
  final UserEntity user;

  const CampusAuthProfileIncomplete({required this.user});

  @override
  List<Object?> get props => [user];
}

class CampusAuthPinSetupRequired extends CampusAuthState {
  final UserEntity user;

  const CampusAuthPinSetupRequired({required this.user});

  @override
  List<Object?> get props => [user];
}

class CampusAuthError extends CampusAuthState {
  final String message;

  const CampusAuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CampusAuthPasswordResetSent extends CampusAuthState {}

class CampusAuthPasswordResetSuccess extends CampusAuthState {}

class CampusAuthPinSetupSuccess extends CampusAuthState {}

/// Emitted when Supabase fires a PASSWORD_RECOVERY auth event via deep link.
/// The router uses this state to redirect the user to /reset-password.
class CampusAuthPasswordRecovery extends CampusAuthState {}
