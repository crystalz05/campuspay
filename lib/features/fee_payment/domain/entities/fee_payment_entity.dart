import 'package:equatable/equatable.dart';

class FeePaymentEntity extends Equatable {
  final String rrrNumber;
  final double amount;
  final String institutionName;
  final String feePurpose;

  const FeePaymentEntity({
    required this.rrrNumber,
    required this.amount,
    required this.institutionName,
    required this.feePurpose,
  });

  @override
  List<Object?> get props => [rrrNumber, amount, institutionName, feePurpose];
}
