import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluidity/cubit/app_settings/app_settings_cubit.dart';
import 'package:fluidity/repositories/user_profile_repository.dart';

class _MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late _MockUserProfileRepository repo;
  late AppSettingsCubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    repo = _MockUserProfileRepository();
    cubit = AppSettingsCubit(initialLanguage: 'en', userProfileRepository: repo);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('setTab updates active tab', () {
    cubit.setTab('profile');
    expect(cubit.state.activeTab, 'profile');
  });

  test('setLanguage persists value', () async {
    await cubit.setLanguage('uk');
    final prefs = await SharedPreferences.getInstance();

    expect(cubit.state.language, 'uk');
    expect(prefs.getString('language'), 'uk');
  });

  test('setDailyGoal updates repository when uid exists', () async {
    when(() => repo.updateGoal('uid-1', 2500)).thenAnswer((_) async {});

    await cubit.setDailyGoal(2500, 'uid-1');

    verify(() => repo.updateGoal('uid-1', 2500)).called(1);
    expect(cubit.state.dailyGoal, 2500);
  });
}
