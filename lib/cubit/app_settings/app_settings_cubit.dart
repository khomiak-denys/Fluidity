import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repositories/user_profile_repository.dart';
import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final UserProfileRepository userProfileRepository;

  AppSettingsCubit({
    required String initialLanguage,
    required this.userProfileRepository,
  }) : super(AppSettingsState(language: initialLanguage));

  Future<void> bootstrap() async {
    emit(state.copyWith(status: AppSettingsStatus.ready));
  }

  void setTab(String tab) {
    emit(state.copyWith(activeTab: tab));
  }

  Future<void> setLanguage(String language) async {
    emit(state.copyWith(language: language));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  void setDailyGoalLocal(int goal) {
    emit(state.copyWith(dailyGoal: goal));
  }

  Future<void> setDailyGoal(int goal, String? uid) async {
    final previousGoal = state.dailyGoal;
    emit(state.copyWith(dailyGoal: goal, status: AppSettingsStatus.loading));
    if (uid == null || uid.isEmpty) {
      emit(state.copyWith(status: AppSettingsStatus.ready));
      return;
    }
    try {
      await userProfileRepository.updateGoal(uid, goal);
      emit(state.copyWith(status: AppSettingsStatus.ready));
    } catch (_) {
      emit(state.copyWith(
        dailyGoal: previousGoal,
        status: AppSettingsStatus.error,
      ));
    }
  }

  void resetForSignOut() {
    emit(state.copyWith(dailyGoal: 2000, activeTab: 'home'));
  }
}
