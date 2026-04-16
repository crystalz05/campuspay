import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_bundles_usecase.dart';
import '../../domain/usecases/purchase_bundle_usecase.dart';
import 'data_bundle_event.dart';
import 'data_bundle_state.dart';

class DataBundleBloc extends Bloc<DataBundleEvent, DataBundleState> {
  final GetBundlesUseCase getBundlesUseCase;
  final PurchaseBundleUseCase purchaseBundleUseCase;

  DataBundleBloc({
    required this.getBundlesUseCase,
    required this.purchaseBundleUseCase,
  }) : super(DataBundleInitial()) {
    on<LoadBundlesEvent>(_onLoadBundles);
    on<PurchaseBundleEvent>(_onPurchaseBundle);
  }

  Future<void> _onLoadBundles(
    LoadBundlesEvent event,
    Emitter<DataBundleState> emit,
  ) async {
    emit(DataBundleLoading());
    final result = await getBundlesUseCase(event.network);
    result.fold(
      (failure) => emit(DataBundleError(failure.message)),
      (bundles) =>
          emit(DataBundleLoaded(bundles: bundles, network: event.network)),
    );
  }

  Future<void> _onPurchaseBundle(
    PurchaseBundleEvent event,
    Emitter<DataBundleState> emit,
  ) async {
    emit(DataBundlePurchasing());
    final result = await purchaseBundleUseCase(
      network: event.network,
      phoneNumber: event.phoneNumber,
      bundle: event.bundle,
    );
    result.fold(
      (failure) => emit(DataBundleError(failure.message)),
      (transaction) => emit(DataBundlePurchaseSuccess(
        transaction: transaction,
        bundle: event.bundle,
        phoneNumber: event.phoneNumber,
      )),
    );
  }
}
