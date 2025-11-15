import '../../models/reminder_setting.dart';

abstract class ReminderState {}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {
  final List<ReminderSetting> data;
  ReminderLoading({this.data = const []});
}

class ReminderLoaded extends ReminderState {
  final List<ReminderSetting> data;
  ReminderLoaded({required this.data});
}

class ReminderError extends ReminderState {
  final Object error;
  final List<ReminderSetting> data;
  ReminderError({required this.error, this.data = const []});
}
