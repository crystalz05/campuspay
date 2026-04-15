import '../../domain/entities/fee_payment_entity.dart';

class FeePaymentModel extends FeePaymentEntity {
  const FeePaymentModel({
    required super.rrrNumber,
    required super.amount,
    required super.institutionName,
    required super.feePurpose,
  });

  factory FeePaymentModel.fromJson(Map<String, dynamic> json) {
    return FeePaymentModel(
      rrrNumber: json['rrr_number'] as String,
      amount: (json['amount'] as num).toDouble(),
      institutionName: json['institution_name'] as String,
      feePurpose: json['fee_purpose'] as String? ?? 'School Fee',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rrr_number': rrrNumber,
      'amount': amount,
      'institution_name': institutionName,
      'fee_purpose': feePurpose,
    };
  }
}
