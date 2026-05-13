import 'package:flutter_bloc/flutter_bloc.dart';
import '../common/stream_backed_bloc.dart';
import '../../models/water_entry.dart';
import '../../repositories/water_entry_repository.dart';
import 'water_event.dart';
import 'water_state.dart';

class WaterBloc extends StreamBackedBloc<WaterEvent, WaterState, WaterEntry> {
  final WaterEntryRepository repo;

  WaterBloc({required this.repo, required super.userId})
      : super(initialState: WaterInitial()) {
    on<LoadWaterEvent>(_onLoad);
    on<RefreshWaterEvent>(_onLoad);
    on<AddWaterEntryEvent>(_onAddEntry);
    on<DeleteWaterEntryEvent>(_onDeleteEntry);
    on<_WaterStreamUpdated>(_onStreamUpdated);
    on<_WaterStreamError>(_onStreamError);
  }

  Future<void> _onLoad(WaterEvent event, Emitter<WaterState> emit) async {
    await handleLoad(
      emit,
      onData: (entries) => add(_WaterStreamUpdated(entries)),
      onError: (e) => add(_WaterStreamError(e)),
    );
  }

  Future<void> _onAddEntry(
      AddWaterEntryEvent event, Emitter<WaterState> emit) async {
    if (userId.isEmpty) return;
    try {
      await repo.add(userId, event.entry);
    } catch (e) {
      final currentData =
          state is WaterLoaded ? (state as WaterLoaded).data : <WaterEntry>[];
      emit(WaterError(error: e, data: currentData));
    }
  }

  Future<void> _onDeleteEntry(
      DeleteWaterEntryEvent event, Emitter<WaterState> emit) async {
    if (userId.isEmpty) return;
    try {
      await repo.delete(userId, event.id);
    } catch (e) {
      final currentData =
          state is WaterLoaded ? (state as WaterLoaded).data : <WaterEntry>[];
      emit(WaterError(error: e, data: currentData));
    }
  }

  void _onStreamUpdated(_WaterStreamUpdated event, Emitter<WaterState> emit) {
    emit(WaterLoaded(data: event.entries));
  }

  void _onStreamError(_WaterStreamError event, Emitter<WaterState> emit) {
    emit(errorState(event.error, currentData(state)));
  }

  @override
  List<WaterEntry> currentData(WaterState state) {
    if (state is WaterLoaded) return state.data;
    if (state is WaterLoading) return state.data;
    if (state is WaterError) return state.data;
    return const <WaterEntry>[];
  }

  @override
  WaterState loadingState(List<WaterEntry> data) => WaterLoading(data: data);

  @override
  WaterState loadedState(List<WaterEntry> data) => WaterLoaded(data: data);

  @override
  WaterState errorState(Object error, List<WaterEntry> data) =>
      WaterError(error: error, data: data);

  @override
  Stream<List<WaterEntry>> watchAll(String userId) => repo.watchAll(userId);
}

class _WaterStreamUpdated extends WaterEvent {
  final List<WaterEntry> entries;
  _WaterStreamUpdated(this.entries);
}

class _WaterStreamError extends WaterEvent {
  final Object error;
  _WaterStreamError(this.error);
}
