import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/water_entry.dart';
import '../../repositories/water_entry_repository.dart';
import 'water_event.dart';
import 'water_state.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterEntryRepository repo;
  final String userId;
  StreamSubscription<List<WaterEntry>>? _subscription;

  WaterBloc({required this.repo, required this.userId}) : super(WaterInitial()) {
    on<LoadWaterEvent>(_onLoad);
    on<RefreshWaterEvent>(_onLoad);
    on<SimulateErrorEvent>(_onSimulateError);
    on<AddWaterEntryEvent>(_onAddEntry);
    on<DeleteWaterEntryEvent>(_onDeleteEntry);
    on<_WaterStreamUpdated>(_onStreamUpdated);
    on<_WaterStreamError>(_onStreamError);
  }

  Future<void> _onLoad(WaterEvent event, Emitter<WaterState> emit) async {
    final currentData = state is WaterLoaded ? (state as WaterLoaded).data : <WaterEntry>[];
    emit(WaterLoading(data: currentData));
    await Future.delayed(const Duration(milliseconds: 100));
    if (userId.isEmpty) {
      emit(WaterLoaded(data: const []));
      return;
    }
    await _subscription?.cancel();
    _subscription = repo.watchAll(userId).listen(
      (entries) => add(_WaterStreamUpdated(entries)),
      onError: (e) => add(_WaterStreamError(e)),
    );
  }

  Future<void> _onSimulateError(SimulateErrorEvent event, Emitter<WaterState> emit) async {
    final currentData = state is WaterLoaded ? (state as WaterLoaded).data : <WaterEntry>[];
    emit(WaterLoading(data: currentData));
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      throw 'Simulated error';
    } catch (e) {
      emit(WaterError(error: e, data: currentData));
    }
  }

  Future<void> _onAddEntry(AddWaterEntryEvent event, Emitter<WaterState> emit) async {
    if (userId.isEmpty) return;
    try {
      await repo.add(userId, event.entry);
    } catch (e) {
      final currentData = state is WaterLoaded ? (state as WaterLoaded).data : <WaterEntry>[];
      emit(WaterError(error: e, data: currentData));
    }
  }

  Future<void> _onDeleteEntry(DeleteWaterEntryEvent event, Emitter<WaterState> emit) async {
    if (userId.isEmpty) return;
    try {
      await repo.delete(userId, event.id);
    } catch (e) {
      final currentData = state is WaterLoaded ? (state as WaterLoaded).data : <WaterEntry>[];
      emit(WaterError(error: e, data: currentData));
    }
  }

  void _onStreamUpdated(_WaterStreamUpdated event, Emitter<WaterState> emit) {
    emit(WaterLoaded(data: event.entries));
  }

  void _onStreamError(_WaterStreamError event, Emitter<WaterState> emit) {
    final currentData = state is WaterLoaded ? (state as WaterLoaded).data : <WaterEntry>[];
    emit(WaterError(error: event.error, data: currentData));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _WaterStreamUpdated extends WaterEvent {
  final List<WaterEntry> entries;
  _WaterStreamUpdated(this.entries);
}

class _WaterStreamError extends WaterEvent {
  final Object error;
  _WaterStreamError(this.error);
}
