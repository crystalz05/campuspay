import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../domain/entities/data_bundle_entity.dart';

abstract class DataBundleState extends Equatable {
  const DataBundleState();

  @override
  List<Object?> get props => [];
}

class DataBundleInitial extends DataBundleState {}

class DataBundleLoading extends DataBundleState {}

class DataBundleLoaded extends DataBundleState {
  final List<DataBundleEntity> bundles;
  final NetworkProvider network;

  const DataBundleLoaded({required this.bundles, required this.network});

  @override
  List<Object?> get props => [bundles, network];
}

class DataBundlePurchasing extends DataBundleState {}

class DataBundlePurchaseSuccess extends DataBundleState {
  final TransactionEntity transaction;
  final DataBundleEntity bundle;
  final String phoneNumber;

  const DataBundlePurchaseSuccess({
    required this.transaction,
    required this.bundle,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [transaction, bundle, phoneNumber];
}

class DataBundleError extends DataBundleState {
  final String message;

  const DataBundleError(this.message);

  @override
  List<Object?> get props => [message];
}
