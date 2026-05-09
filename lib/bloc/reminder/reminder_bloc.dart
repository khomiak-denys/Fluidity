import 'package:flutter_bloc/flutter_bloc.dart';
import '../common/stream_backed_bloc.dart';
import '../../models/reminder_setting.dart';
import '../../repositories/reminder_setting_repository.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';

class ReminderBloc extends StreamBackedBloc<ReminderEvent, ReminderState, ReminderSetting> {
  final ReminderSettingRepository repo;

  ReminderBloc({required this.repo, required super.userId}) : super(initialState: ReminderInitial()) {
    on<LoadRemindersEvent>(_onLoad);
    on<RefreshRemindersEvent>(_onLoad);
    on<AddReminderEvent>(_onAdd);
    on<ToggleReminderEvent>(_onToggle);
    on<DeleteReminderEvent>(_onDelete);
    on<_ReminderStreamUpdated>(_onStreamUpdated);
    on<_ReminderStreamError>(_onStreamError);
  }

  Future<void> _onLoad(ReminderEvent event, Emitter<ReminderState> emit) async {
    await handleLoad(
      emit,
      onData: (items) => add(_ReminderStreamUpdated(items)),
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
    emit(errorState(event.error, currentData(state)));
  }

  @override
  List<ReminderSetting> currentData(ReminderState state) {
    if (state is ReminderLoaded) return state.data;
    if (state is ReminderLoading) return state.data;
    if (state is ReminderError) return state.data;
    return const <ReminderSetting>[];
  }

  @override
  ReminderState loadingState(List<ReminderSetting> data) => ReminderLoading(data: data);

  @override
  ReminderState loadedState(List<ReminderSetting> data) => ReminderLoaded(data: data);

  @override
  ReminderState errorState(Object error, List<ReminderSetting> data) => ReminderError(error: error, data: data);

  @override
  Stream<List<ReminderSetting>> watchAll(String userId) => repo.watchAll(userId);
}

class _ReminderStreamUpdated extends ReminderEvent {
  final List<ReminderSetting> items;
  _ReminderStreamUpdated(this.items);
}

class _ReminderStreamError extends ReminderEvent {
  final Object error;
  _ReminderStreamError(this.error);
}
