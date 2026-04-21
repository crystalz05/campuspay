import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> completeProfile({
    required String matricNumber,
    required String institution,
  });

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({required String newPassword});

  Future<Either<Failure, void>> setTransactionPin({required String pin});

  Future<Either<Failure, void>> resendVerificationEmail({required String email});

  Future<Either<Failure, void>> updateProfile({String? fullName, String? matricNumber, String? institution});

  Stream<UserEntity?> get onAuthStateChanged;
}
