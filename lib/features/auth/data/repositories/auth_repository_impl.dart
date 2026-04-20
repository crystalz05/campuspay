import 'package:supabase_flutter/supabase_flutter.dart' show User;
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(_mapAuthErrorMessage(e.message)));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(_mapAuthErrorMessage(e.message)));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred during registration.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> completeProfile({
    required String matricNumber,
    required String institution,
  }) async {
    try {
      final userModel = await remoteDataSource.completeProfile(
        matricNumber: matricNumber,
        institution: institution,
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(_mapAuthErrorMessage(e.message)));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(_mapAuthErrorMessage(e.message)));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred while completing profile.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(AuthFailure(_mapAuthErrorMessage(e.message)));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(_mapAuthErrorMessage(e.message)));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred during login.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel);
    } catch (e) {
      return const Left(ServerFailure('Unable to fetch current user session.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Logout failed.'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(_mapAuthErrorMessage(e.message)));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(_mapAuthErrorMessage(e.message)));
    } catch (e) {
      return const Left(ServerFailure('Failed to send password reset email.'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String newPassword}) async {
    try {
      await remoteDataSource.resetPassword(newPassword: newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(_mapAuthErrorMessage(e.message)));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(_mapAuthErrorMessage(e.message)));
    } catch (e) {
      return const Left(ServerFailure('Failed to reset password.'));
    }
  }

  @override
  Future<Either<Failure, void>> setTransactionPin({required String pin}) async {
    try {
      await remoteDataSource.setTransactionPin(pin: pin);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(_mapAuthErrorMessage(e.message)));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(_mapAuthErrorMessage(e.message)));
    } catch (e) {
      return const Left(ServerFailure('Failed to set transaction PIN.'));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail({required String email}) async {
    try {
      await remoteDataSource.resendVerificationEmail(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(_mapAuthErrorMessage(e.message)));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(_mapAuthErrorMessage(e.message)));
    } catch (e) {
      return const Left(ServerFailure('Failed to resend verification email.'));
    }
  }

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    return remoteDataSource.onAuthStateChanged.asyncMap((supabaseUser) async {
      if (supabaseUser == null) return null;
      final result = await getCurrentUser();
      return result.fold((l) => null, (r) => r);
    });
  }

  String _mapAuthErrorMessage(String message) {
    if (message.contains('invalid-credential') || message.contains('Invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (message.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (message.contains('email-already-in-use') || message.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    if (message.contains('network-request-failed')) {
      return 'Connection error. Please check your internet.';
    }
    if (message.toLowerCase().contains('email not confirmed') || message.toLowerCase().contains('email not verified')) {
      return 'email-not-verified';
    }
    if (message.contains('users_matric_number_key') || message.toLowerCase().contains('unique constraint')) {
      return 'An account with this matric number already exists.';
    }
    return message;
  }
}
