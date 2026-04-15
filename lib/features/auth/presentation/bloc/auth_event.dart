import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class RefreshUserEvent extends AuthEvent {} // NEW EVENT: Quietly refreshes user data without loading overlay

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;

  const RegisterEvent({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, password];
}

class CompleteProfileEvent extends AuthEvent {
  final String matricNumber;
  final String institution;

  const CompleteProfileEvent({
    required this.matricNumber,
    required this.institution,
  });

  @override
  List<Object?> get props => [matricNumber, institution];
}

class LogoutEvent extends AuthEvent {}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String newPassword;

  const ResetPasswordEvent(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

class SetTransactionPinEvent extends AuthEvent {
  final String pin;

  const SetTransactionPinEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

class AuthStateChangedEvent extends AuthEvent {
  final supabase.AuthChangeEvent event;

  const AuthStateChangedEvent(this.event);

  @override
  List<Object?> get props => [event];
}