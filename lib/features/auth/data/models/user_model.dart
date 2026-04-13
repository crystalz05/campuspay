
import 'package:campuspay/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.matricNumber,
    super.institution,
    required super.walletBalance,
    required super.isPinSet,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      matricNumber: json['matric_number'] as String?,
      institution: json['institution'] as String?,
      walletBalance: json['wallet_balance'] is String
          ? double.tryParse(json['wallet_balance'] as String) ?? 0.0
          : (json['wallet_balance'] as num).toDouble(),
      isPinSet: (json['transaction_pin'] as String?) != null && (json['transaction_pin'] as String?) != '0000',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'matric_number': matricNumber,
      'institution': institution,
      'wallet_balance': walletBalance,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
