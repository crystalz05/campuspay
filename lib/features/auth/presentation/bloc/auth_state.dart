import 'package:equatable/equatable.dart';

abstract class CampusAuthState extends Equatable {
  const CampusAuthState();

  @override
  List<Object?> get props => [];
}

class CampusAuthInitial extends CampusAuthState {}

class CampusAuthLoading extends CampusAuthState {}

class CampusAuthAuthenticated extends CampusAuthState {}

class CampusAuthUnauthenticated extends CampusAuthState {}

class CampusAuthError extends CampusAuthState {
  final String message;

  const CampusAuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
