import 'package:equatable/equatable.dart';

enum NotificationType {
  transfer('transfer'),
  fee('fee'),
  data('data'),
  airtime('airtime'),
  deposit('deposit'),
  system('system');

  final String value;
  const NotificationType(this.value);

  factory NotificationType.fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final bool read;
  final NotificationType type;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.read,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        read,
        type,
        createdAt,
      ];
}
