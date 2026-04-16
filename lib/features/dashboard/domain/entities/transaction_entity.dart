import 'package:equatable/equatable.dart';

enum TransactionType {
  fee('fee'),
  data('data'),
  transfer('transfer'),
  deposit('deposit'),
  airtime('airtime');

  final String value;
  const TransactionType(this.value);

  factory TransactionType.fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.transfer,
    );
  }
}

enum TransactionStatus {
  pending('pending'),
  success('success'),
  failed('failed');

  final String value;
  const TransactionStatus(this.value);

  factory TransactionStatus.fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.pending,
    );
  }
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final TransactionStatus status;
  final String? reference;
  final String? description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    this.reference,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        status,
        reference,
        description,
        createdAt,
      ];
}
