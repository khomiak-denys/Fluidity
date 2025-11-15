import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/water_entry.dart';
import 'water_event.dart';
import 'water_state.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  WaterBloc() : super(WaterInitial()) {
    on<LoadWaterEvent>(_onLoad);
    on<RefreshWaterEvent>(_onLoad);
    on<SimulateErrorEvent>(_onSimulateError);
    on<AddWaterEntryEvent>(_onAddEntry);
    on<DeleteWaterEntryEvent>(_onDeleteEntry);
  }

  Future<void> _onLoad(WaterEvent event, Emitter<WaterState> emit) async {
    final currentData = state is WaterLoaded ? (state as WaterLoaded).data : <WaterEntry>[];
    emit(WaterLoading(data: currentData));
    await Future.delayed(const Duration(milliseconds: 500));
    try {
  // Load empty by default (no hardcoded demo data)
  emit(WaterLoaded(data: const []));
    } catch (e) {
      emit(WaterError(error: e, data: currentData));
    }
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
    final currentData = state is WaterLoaded ? List<WaterEntry>.from((state as WaterLoaded).data) : <WaterEntry>[];
    currentData.insert(0, event.entry);
    emit(WaterLoaded(data: currentData));
  }

  Future<void> _onDeleteEntry(DeleteWaterEntryEvent event, Emitter<WaterState> emit) async {
    final currentData = state is WaterLoaded ? List<WaterEntry>.from((state as WaterLoaded).data) : <WaterEntry>[];
    currentData.removeWhere((e) => e.id == event.id);
    emit(WaterLoaded(data: currentData));
  }
}
