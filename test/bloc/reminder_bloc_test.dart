import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluidity/bloc/reminder/reminder_bloc.dart';
import 'package:fluidity/bloc/reminder/reminder_event.dart';
import 'package:fluidity/bloc/reminder/reminder_state.dart';
import 'package:fluidity/models/reminder_setting.dart';
import 'package:fluidity/repositories/reminder_setting_repository.dart';

class _MockReminderSettingRepository extends Mock implements ReminderSettingRepository {}

void main() {
  late _MockReminderSettingRepository repo;

  setUpAll(() {
    registerFallbackValue(
      ReminderSetting(
        id: 'fallback',
        scheduledTime: DateTime(2026, 1, 1, 0, 0),
        comment: '',
        isActive: false,
      ),
    );
  });

  setUp(() {
    repo = _MockReminderSettingRepository();
  });

  test('LoadRemindersEvent with empty userId emits loading then empty loaded without subscription', () async {
    final bloc = ReminderBloc(repo: repo, userId: '');

    final expected = [
      isA<ReminderLoading>(),
      isA<ReminderLoaded>().having((s) => s.data, 'data', isEmpty),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(LoadRemindersEvent());

    await Future<void>.delayed(const Duration(milliseconds: 20));
    verifyNever(() => repo.watchAll(any()));
    await bloc.close();
  });

  test('LoadRemindersEvent subscribes and emits loaded data from stream', () async {
    final controller = StreamController<List<ReminderSetting>>();
    when(() => repo.watchAll('u1')).thenAnswer((_) => controller.stream);

    final bloc = ReminderBloc(repo: repo, userId: 'u1');
    final item = ReminderSetting(
      id: 'r1',
      scheduledTime: DateTime(2026, 1, 1, 9, 0),
      comment: 'Drink',
      isActive: true,
    );

    final expected = [
      isA<ReminderLoading>(),
      isA<ReminderLoaded>().having((s) => s.data, 'data', [item]),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(LoadRemindersEvent());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    controller.add([item]);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await bloc.close();
    await controller.close();
  });

  test('stream error emits ReminderError with last known data', () async {
    final controller = StreamController<List<ReminderSetting>>();
    when(() => repo.watchAll('u1')).thenAnswer((_) => controller.stream);

    final bloc = ReminderBloc(repo: repo, userId: 'u1');
    final item = ReminderSetting(
      id: 'r1',
      scheduledTime: DateTime(2026, 1, 1, 9, 0),
      comment: 'Drink',
      isActive: true,
    );

    bloc.add(LoadRemindersEvent());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    controller.add([item]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final expectError = expectLater(
      bloc.stream,
      emits(
        isA<ReminderError>().having((s) => s.data, 'data', [item]),
      ),
    );

    controller.addError(Exception('boom'));

    await expectError;
    await bloc.close();
    await controller.close();
  });

  test('ToggleReminderEvent flips isActive and calls repository update', () async {
    when(() => repo.update(any(), any())).thenAnswer((_) async {});

    final controller = StreamController<List<ReminderSetting>>();
    when(() => repo.watchAll('u1')).thenAnswer((_) => controller.stream);

    final bloc = ReminderBloc(repo: repo, userId: 'u1');
    final item = ReminderSetting(
      id: 'r1',
      scheduledTime: DateTime(2026, 1, 1, 9, 0),
      comment: 'Drink',
      isActive: true,
    );

    bloc.add(LoadRemindersEvent());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    controller.add([item]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    bloc.add(ToggleReminderEvent('r1'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    verify(
      () => repo.update(
        'u1',
        ReminderSetting(
          id: 'r1',
          scheduledTime: item.scheduledTime,
          comment: item.comment,
          isActive: false,
        ),
      ),
    ).called(1);

    await bloc.close();
    await controller.close();
  });
}
