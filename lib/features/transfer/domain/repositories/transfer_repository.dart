import '../../../../core/error/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class TransferRepository {
  Future<Either<Failure, UserEntity>> searchRecipient(String query);
  
  Future<Either<Failure, String>> processTransfer({
    required String receiverId,
    required double amount,
    String? note,
    required String pin,
  });
}
