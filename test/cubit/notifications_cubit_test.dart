import 'package:flutter_test/flutter_test.dart';

import 'package:fluidity/cubit/notifications/notifications_cubit.dart';
import 'package:fluidity/cubit/notifications/notifications_state.dart';
import 'package:fluidity/models/reminder_setting.dart';

class _FakeNotificationGateway implements NotificationGateway {
  bool initCalled = false;
  bool requestCalled = false;
  bool cancelAllCalled = false;
  int syncCalls = 0;
  bool throwOnPermission = false;

  @override
  Future<void> init() async {
    initCalled = true;
  }

  @override
  Future<void> requestPermissions() async {
    requestCalled = true;
    if (throwOnPermission) {
      throw Exception('permission denied');
    }
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalled = true;
  }

  @override
  Future<void> sync(List<ReminderSetting> reminders) async {
    syncCalls += 1;
  }

  @override
  void updateLocalizedStrings(dynamic loc) {}
}

void main() {
  late _FakeNotificationGateway gateway;
  late NotificationsCubit cubit;

  setUp(() {
    gateway = _FakeNotificationGateway();
    cubit = NotificationsCubit(notificationService: gateway);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('bootstrap enables notifications when permission request succeeds', () async {
    await cubit.bootstrap();

    expect(gateway.initCalled, isTrue);
    expect(gateway.requestCalled, isTrue);
    expect(cubit.state.systemAllowed, isTrue);
    expect(cubit.state.enabled, isTrue);
  });

  test('bootstrap disables notifications when permission request fails', () async {
    gateway.throwOnPermission = true;

    await cubit.bootstrap();

    expect(cubit.state.systemAllowed, isFalse);
    expect(cubit.state.enabled, isFalse);
    expect(gateway.cancelAllCalled, isTrue);
  });

  test('setEnabled(false) cancels all notifications', () async {
    await cubit.bootstrap();
    await cubit.setEnabled(false, const []);

    expect(gateway.cancelAllCalled, isTrue);
    expect(cubit.state.enabled, isFalse);
  });

  test('retryAndSync success requests permission and syncs', () async {
    await cubit.bootstrap();
    gateway.requestCalled = false;
    final reminders = [
      ReminderSetting(
        id: '1',
        scheduledTime: DateTime(2026, 1, 1, 9, 0),
        comment: 'Water',
        isActive: true,
      ),
    ];

    await cubit.retryAndSync(reminders);

    expect(gateway.requestCalled, isTrue);
    expect(gateway.syncCalls, 1);
  });

  test('retryAndSync denied transitions to disabled state', () async {
    await cubit.bootstrap();
    gateway.throwOnPermission = true;

    await cubit.retryAndSync(const []);

    expect(cubit.state.systemAllowed, isFalse);
    expect(cubit.state.enabled, isFalse);
    expect(gateway.cancelAllCalled, isTrue);
  });

  test('handleSignOut cancels notifications and resets state', () async {
    await cubit.bootstrap();
    await cubit.handleSignOut();

    expect(gateway.cancelAllCalled, isTrue);
    expect(cubit.state.status, NotificationsStatus.initial);
    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.systemAllowed, isFalse);
  });
}
