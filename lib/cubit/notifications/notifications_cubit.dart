import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../models/reminder_setting.dart';
import '../../services/notification_service.dart';
import 'notifications_state.dart';

abstract class NotificationGateway {
  Future<void> init();
  Future<void> requestPermissions();
  Future<void> sync(List<ReminderSetting> reminders);
  Future<void> cancelAll();
  void updateLocalizedStrings(dynamic loc);
}

class NotificationServiceGateway implements NotificationGateway {
  final NotificationService service;

  NotificationServiceGateway(this.service);

  @override
  Future<void> init() => service.init();

  @override
  Future<void> requestPermissions() => service.requestPermissions();

  @override
  Future<void> sync(List<ReminderSetting> reminders) => service.sync(reminders);

  @override
  Future<void> cancelAll() => service.cancelAll();

  @override
  void updateLocalizedStrings(dynamic loc) => service.updateLocalizedStrings(loc);
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationGateway notificationService;

  NotificationsCubit({required this.notificationService}) : super(const NotificationsState());

  Future<void> bootstrap() async {
    try {
      await notificationService.init();
      await notificationService.requestPermissions();
      emit(state.copyWith(
        status: NotificationsStatus.ready,
        systemAllowed: true,
        enabled: true,
      ));
    } catch (_) {
      await _disableAndCancel();
    }
  }

  Future<void> retryPermission() async {
    try {
      await notificationService.requestPermissions();
      emit(state.copyWith(systemAllowed: true, enabled: true, status: NotificationsStatus.ready));
    } catch (_) {
      await _disableAndCancel();
    }
  }

  Future<void> retryAndSync(List<ReminderSetting> reminders) async {
    await retryPermission();
    if (!state.systemAllowed || !state.enabled) return;
    await syncFromReminders(reminders);
  }

  Future<void> setEnabled(bool value, List<ReminderSetting> reminders) async {
    if (!state.systemAllowed && value) {
      return;
    }

    emit(state.copyWith(enabled: value));
    if (!value) {
      await notificationService.cancelAll();
      return;
    }

    await syncFromReminders(reminders);
  }

  Future<void> syncFromReminders(List<ReminderSetting> reminders) async {
    final hasActive = reminders.any((r) => r.isActive);
    if (!state.systemAllowed || !state.enabled || !hasActive) {
      await notificationService.cancelAll();
      return;
    }

    emit(state.copyWith(status: NotificationsStatus.syncing));
    await notificationService.sync(reminders);
    emit(state.copyWith(status: NotificationsStatus.ready));
  }

  void updateLocalizedStrings(AppLocalizations? loc) {
    if (loc == null) return;
    notificationService.updateLocalizedStrings(loc);
  }

  Future<void> cancelAll() => notificationService.cancelAll();

  Future<void> handleSignOut() async {
    try {
      await notificationService.cancelAll();
    } catch (_) {}
    emit(const NotificationsState());
  }

  Future<void> _disableAndCancel() async {
    emit(state.copyWith(
      status: NotificationsStatus.error,
      systemAllowed: false,
      enabled: false,
    ));
    try {
      await notificationService.cancelAll();
    } catch (_) {}
  }
}
