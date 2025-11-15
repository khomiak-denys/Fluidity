import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/reminder_setting.dart';
import '../../repositories/reminder_setting_repository.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderSettingRepository repo;
  final String userId;
  StreamSubscription<List<ReminderSetting>>? _subscription;

  ReminderBloc({required this.repo, required this.userId}) : super(ReminderInitial()) {
    on<LoadRemindersEvent>(_onLoad);
    on<RefreshRemindersEvent>(_onLoad);
    on<AddReminderEvent>(_onAdd);
    on<ToggleReminderEvent>(_onToggle);
    on<DeleteReminderEvent>(_onDelete);
    on<_ReminderStreamUpdated>(_onStreamUpdated);
    on<_ReminderStreamError>(_onStreamError);
  }

  Future<void> _onLoad(ReminderEvent event, Emitter<ReminderState> emit) async {
    final current = state is ReminderLoaded
        ? (state as ReminderLoaded).data
        : <ReminderSetting>[];
    emit(ReminderLoading(data: current));
    await Future.delayed(const Duration(milliseconds: 100));
    if (userId.isEmpty) {
      emit(ReminderLoaded(data: const []));
      return;
    }
    await _subscription?.cancel();
    _subscription = repo.watchAll(userId).listen(
      (items) => add(_ReminderStreamUpdated(items)),
      onError: (e) => add(_ReminderStreamError(e)),
    );
  }

  Future<void> _onAdd(AddReminderEvent event, Emitter<ReminderState> emit) async {
    if (userId.isEmpty) return;
    try {
      await repo.add(userId, event.reminder);
    } catch (e) {
      final current = state is ReminderLoaded ? (state as ReminderLoaded).data : <ReminderSetting>[];
      emit(ReminderError(error: e, data: current));
    }
  }

  Future<void> _onToggle(ToggleReminderEvent event, Emitter<ReminderState> emit) async {
    if (userId.isEmpty) return;
    try {
      final current = state is ReminderLoaded ? (state as ReminderLoaded).data : <ReminderSetting>[];
      final existing = current.firstWhere((r) => r.id == event.id, orElse: () => ReminderSetting(
        id: event.id,
        scheduledTime: DateTime.now(),
        comment: '',
        isActive: false,
      ));
      final updated = ReminderSetting(
        id: existing.id,
        scheduledTime: existing.scheduledTime,
        comment: existing.comment,
        isActive: !existing.isActive,
      );
      await repo.update(userId, updated);
    } catch (e) {
      final current = state is ReminderLoaded ? (state as ReminderLoaded).data : <ReminderSetting>[];
      emit(ReminderError(error: e, data: current));
    }
  }

  Future<void> _onDelete(DeleteReminderEvent event, Emitter<ReminderState> emit) async {
    if (userId.isEmpty) return;
    try {
      await repo.delete(userId, event.id);
    } catch (e) {
      final current = state is ReminderLoaded ? (state as ReminderLoaded).data : <ReminderSetting>[];
      emit(ReminderError(error: e, data: current));
    }
  }

  void _onStreamUpdated(_ReminderStreamUpdated event, Emitter<ReminderState> emit) {
    emit(ReminderLoaded(data: event.items));
  }

  void _onStreamError(_ReminderStreamError event, Emitter<ReminderState> emit) {
    final current = state is ReminderLoaded ? (state as ReminderLoaded).data : <ReminderSetting>[];
    emit(ReminderError(error: event.error, data: current));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _ReminderStreamUpdated extends ReminderEvent {
  final List<ReminderSetting> items;
  _ReminderStreamUpdated(this.items);
}

class _ReminderStreamError extends ReminderEvent {
  final Object error;
  _ReminderStreamError(this.error);
}
