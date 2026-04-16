import 'package:equatable/equatable.dart';
import '../../domain/entities/data_bundle_entity.dart';

abstract class DataBundleEvent extends Equatable {
  const DataBundleEvent();

  @override
  List<Object?> get props => [];
}

class LoadBundlesEvent extends DataBundleEvent {
  final NetworkProvider network;
  const LoadBundlesEvent(this.network);

  @override
  List<Object?> get props => [network];
}

class PurchaseBundleEvent extends DataBundleEvent {
  final NetworkProvider network;
  final String phoneNumber;
  final DataBundleEntity bundle;

  const PurchaseBundleEvent({
    required this.network,
    required this.phoneNumber,
    required this.bundle,
  });

  @override
  List<Object?> get props => [network, phoneNumber, bundle];
}
