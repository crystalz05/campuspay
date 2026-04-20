import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationsEvent {}

class MarkReadEvent extends NotificationsEvent {
  final String notificationId;
  const MarkReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllReadEvent extends NotificationsEvent {}
