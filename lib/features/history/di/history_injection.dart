import 'package:get_it/get_it.dart';
import '../../dashboard/domain/usecases/get_transactions_usecase.dart';
import '../presentation/bloc/history_bloc.dart';

void initHistoryDependencies(GetIt sl) {
  // UseCases
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));

  // Blocs
  sl.registerFactory(() => HistoryBloc(getTransactionsUseCase: sl()));
}
