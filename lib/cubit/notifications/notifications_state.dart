import 'package:equatable/equatable.dart';

enum NotificationsStatus { initial, ready, syncing, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final bool enabled;
  final bool systemAllowed;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.enabled = true,
    this.systemAllowed = false,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    bool? enabled,
    bool? systemAllowed,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
      systemAllowed: systemAllowed ?? this.systemAllowed,
    );
  }

  @override
  List<Object?> get props => [status, enabled, systemAllowed];
}
