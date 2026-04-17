import 'dart:developer';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_data_source.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource remoteDataSource;

  TransferRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> searchRecipient(String query) async {
    try {
      final userModel = await remoteDataSource.searchRecipient(query);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppAuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('Unexpected error in searchRecipient repo', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> processTransfer({
    required String receiverId,
    required double amount,
    String? note,
    required String pin,
  }) async {
    try {
      final transactionId = await remoteDataSource.processTransfer(
        receiverId: receiverId,
        amount: amount,
        note: note,
        pin: pin,
      );
      return Right(transactionId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppAuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      log('Unexpected error in processTransfer repo', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
