import 'package:equatable/equatable.dart';
import '../../../data_bundle/domain/entities/data_bundle_entity.dart';

abstract class AirtimeEvent extends Equatable {
  const AirtimeEvent();

  @override
  List<Object?> get props => [];
}

class PurchaseAirtimeEvent extends AirtimeEvent {
  final NetworkProvider network;
  final String phoneNumber;
  final double amount;

  const PurchaseAirtimeEvent({
    required this.network,
    required this.phoneNumber,
    required this.amount,
  });

  @override
  List<Object?> get props => [network, phoneNumber, amount];
}
