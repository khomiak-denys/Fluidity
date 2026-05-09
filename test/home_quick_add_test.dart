import 'package:bloc_test/bloc_test.dart';
import 'package:fluidity/bloc/water/water_bloc.dart';
import 'package:fluidity/bloc/water/water_event.dart';
import 'package:fluidity/bloc/water/water_state.dart';
import 'package:fluidity/l10n/app_localizations.dart';
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

  testWidgets('Натиск на "🥛 200ml" диспатчить AddWaterEntryEvent',
      (tester) async {
    final bloc = MockWaterBloc();
    when(() => bloc.state).thenReturn(WaterLoaded(data: const []));
    whenListen<WaterState>(
      bloc,
      const Stream<WaterState>.empty(),
      initialState: WaterLoaded(data: const []),
    );

    await tester.pumpWidget(makeApp(const HomeScreen(dailyGoal: 2000), bloc));
    await tester.pump();

    expect(find.text('🥛 200ml'), findsOneWidget);
    await tester.tap(find.text('🥛 200ml'));
    await tester.pump();

    verify(() => bloc.add(any(that: isA<AddWaterEntryEvent>()))).called(1);
  });
}
