import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';

abstract class SplashState {}
class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashNavigateToLogin extends SplashState {}
class SplashNavigateToHome extends SplashState {}

class SplashCubit extends Cubit<SplashState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  SplashCubit({required this.getCurrentUserUseCase}) : super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());
    // Simulate some initialization for effect
    await Future.delayed(const Duration(seconds: 2));

    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => emit(SplashNavigateToLogin()),
      (user) {
        if (user != null) {
          emit(SplashNavigateToHome());
        } else {
          emit(SplashNavigateToLogin());
        }
      },
    );
  }
}
