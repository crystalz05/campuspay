import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? matricNumber;
  final String? institution;
  final double walletBalance;
  final bool isPinSet;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.matricNumber,
    this.institution,
    required this.walletBalance,
    required this.isPinSet,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        matricNumber,
        institution,
        walletBalance,
        isPinSet,
        createdAt,
      ];
}
