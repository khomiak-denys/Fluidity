import 'package:bloc_test/bloc_test.dart';
import 'package:fluidity/bloc/water/water_bloc.dart';
import 'package:fluidity/bloc/water/water_event.dart';
import 'package:fluidity/bloc/water/water_state.dart';
import 'package:fluidity/l10n/app_localizations.dart';
import 'package:fluidity/models/water_entry.dart';
import 'package:fluidity/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeWaterEvent extends Fake implements WaterEvent {}

class FakeWaterState extends Fake implements WaterState {}

class MockWaterBloc extends MockBloc<WaterEvent, WaterState>
    implements WaterBloc {}

Widget makeApp(Widget child, WaterBloc bloc) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<WaterBloc>.value(
      value: bloc,
      child: child,
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeWaterEvent());
    registerFallbackValue(FakeWaterState());
  });

  testWidgets('HomeScreen показує список із 2 записів', (tester) async {
    final now = DateTime.now();
    final entries = [
      WaterEntry(
        id: 'e1',
        amountMl: 200,
        timestamp: now,
        drinkType: 'glass',
        comment: '200 ml glass',
      ),
      WaterEntry(
        id: 'e2',
        amountMl: 300,
        timestamp: now,
        drinkType: 'cup',
        comment: '300 ml cup',
      ),
    ];

    final bloc = MockWaterBloc();
    when(() => bloc.state).thenReturn(WaterLoaded(data: entries));
    whenListen<WaterState>(
      bloc,
      const Stream<WaterState>.empty(),
      initialState: WaterLoaded(data: entries),
    );

    await tester.pumpWidget(makeApp(const HomeScreen(dailyGoal: 2000), bloc));
    await tester.pump();

    expect(find.text('Сьогоднішні записи (2)'), findsOneWidget);
  });
}
