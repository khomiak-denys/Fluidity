import '../../models/reminder_setting.dart';

abstract class ReminderEvent {}

class LoadRemindersEvent extends ReminderEvent {}

class RefreshRemindersEvent extends ReminderEvent {}

class AddReminderEvent extends ReminderEvent {
  final ReminderSetting reminder;
  AddReminderEvent(this.reminder);
}

class ToggleReminderEvent extends ReminderEvent {
  final String id;
  ToggleReminderEvent(this.id);
}

class DeleteReminderEvent extends ReminderEvent {
  final String id;
  DeleteReminderEvent(this.id);
}
