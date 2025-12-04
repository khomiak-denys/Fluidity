import 'package:bloc_test/bloc_test.dart';
import 'package:fluidity/bloc/water/water_bloc.dart';
import 'package:fluidity/bloc/water/water_event.dart';
import 'package:fluidity/bloc/water/water_state.dart';
import 'package:fluidity/l10n/app_localizations.dart';
import 'package:fluidity/ui/button.dart';
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

  testWidgets(
      'CustomAddDialog: введення кількості -> Save диспатчить AddWaterEntryEvent',
      (tester) async {
    final bloc = MockWaterBloc();
    when(() => bloc.state).thenReturn(WaterLoaded(data: const []));
    whenListen<WaterState>(
      bloc,
      const Stream<WaterState>.empty(),
      initialState: WaterLoaded(data: const []),
    );

    await tester.pumpWidget(makeApp(const HomeScreen(dailyGoal: 2000), bloc));
    await tester.pumpAndSettle();

    // Відкрити діалог додавання
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Поле Amount (перше TextField у діалозі)
    final amountField = find.byType(TextField).first;
    await tester.enterText(amountField, '250');
    await tester.pump();

    // Натиснути Save (AppButton з локалізованим текстом)
    final saveBtn = find.widgetWithText(AppButton, 'Save');
    expect(saveBtn, findsOneWidget);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    verify(() => bloc.add(any(that: isA<AddWaterEntryEvent>()))).called(1);
  });
}
