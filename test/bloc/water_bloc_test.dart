import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluidity/bloc/water/water_bloc.dart';
import 'package:fluidity/bloc/water/water_event.dart';
import 'package:fluidity/bloc/water/water_state.dart';
import 'package:fluidity/models/water_entry.dart';
import 'package:fluidity/repositories/water_entry_repository.dart';

class _MockWaterEntryRepository extends Mock implements WaterEntryRepository {}

void main() {
  late _MockWaterEntryRepository repo;

  setUp(() {
    repo = _MockWaterEntryRepository();
  });

  test('LoadWaterEvent with empty userId emits loading then empty loaded without subscription', () async {
    final bloc = WaterBloc(repo: repo, userId: '');

    final expected = [
      isA<WaterLoading>(),
      isA<WaterLoaded>().having((s) => s.data, 'data', isEmpty),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(LoadWaterEvent());

    await Future<void>.delayed(const Duration(milliseconds: 20));
    verifyNever(() => repo.watchAll(any()));
    await bloc.close();
  });

  test('LoadWaterEvent subscribes and emits loaded data from stream', () async {
    final controller = StreamController<List<WaterEntry>>();
    when(() => repo.watchAll('u1')).thenAnswer((_) => controller.stream);

    final bloc = WaterBloc(repo: repo, userId: 'u1');
    final entry = WaterEntry(
      id: '1',
      amountMl: 250,
      timestamp: DateTime(2026, 1, 1, 8, 0),
      drinkType: 'Water',
    );

    final expected = [
      isA<WaterLoading>(),
      isA<WaterLoaded>().having((s) => s.data, 'data', [entry]),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(LoadWaterEvent());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    controller.add([entry]);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await bloc.close();
    await controller.close();
  });

  test('stream error emits WaterError with last known data', () async {
    final controller = StreamController<List<WaterEntry>>();
    when(() => repo.watchAll('u1')).thenAnswer((_) => controller.stream);

    final bloc = WaterBloc(repo: repo, userId: 'u1');
    final entry = WaterEntry(
      id: '1',
      amountMl: 250,
      timestamp: DateTime(2026, 1, 1, 8, 0),
      drinkType: 'Water',
    );

    bloc.add(LoadWaterEvent());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    controller.add([entry]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final expectError = expectLater(
      bloc.stream,
      emits(
        isA<WaterError>().having((s) => s.data, 'data', [entry]),
      ),
    );

    controller.addError(Exception('boom'));

    await expectError;
    await bloc.close();
    await controller.close();
  });
}
