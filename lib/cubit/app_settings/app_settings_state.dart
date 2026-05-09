import 'package:equatable/equatable.dart';

enum AppSettingsStatus { initial, ready, loading, error }

class AppSettingsState extends Equatable {
  final AppSettingsStatus status;
  final String language;
  final String activeTab;
  final int dailyGoal;

  const AppSettingsState({
    this.status = AppSettingsStatus.initial,
    this.language = 'en',
    this.activeTab = 'home',
    this.dailyGoal = 2000,
  });

  AppSettingsState copyWith({
    AppSettingsStatus? status,
    String? language,
    String? activeTab,
    int? dailyGoal,
  }) {
    return AppSettingsState(
      status: status ?? this.status,
      language: language ?? this.language,
      activeTab: activeTab ?? this.activeTab,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  @override
  List<Object?> get props => [status, language, activeTab, dailyGoal];
}
