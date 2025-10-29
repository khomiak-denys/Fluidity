import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/water_intake.dart';
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
    final currentData = state is WaterLoaded ? (state as WaterLoaded).data : <WaterIntakeEntry>[];
    emit(WaterLoading(data: currentData));
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Hardcoded demo data
      final result = [
        WaterIntakeEntry(id: '1', amount: 250, time: '09:30', type: 'glass', comment: 'Morning'),
        WaterIntakeEntry(id: '2', amount: 500, time: '12:15', type: 'bottle', comment: 'Lunch'),
        WaterIntakeEntry(id: '3', amount: 350, time: '15:45', type: 'cup', comment: 'Afternoon'),
      ];
      emit(WaterLoaded(data: result));
    } catch (e) {
      emit(WaterError(error: e, data: currentData));
    }
  }

  Future<void> _onSimulateError(SimulateErrorEvent event, Emitter<WaterState> emit) async {
    final currentData = state is WaterLoaded ? (state as WaterLoaded).data : <WaterIntakeEntry>[];
    emit(WaterLoading(data: currentData));
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      throw 'Simulated error';
    } catch (e) {
      emit(WaterError(error: e, data: currentData));
    }
  }

  Future<void> _onAddEntry(AddWaterEntryEvent event, Emitter<WaterState> emit) async {
    final currentData = state is WaterLoaded ? List<WaterIntakeEntry>.from((state as WaterLoaded).data) : <WaterIntakeEntry>[];
    currentData.insert(0, event.entry);
    emit(WaterLoaded(data: currentData));
  }

  Future<void> _onDeleteEntry(DeleteWaterEntryEvent event, Emitter<WaterState> emit) async {
    final currentData = state is WaterLoaded ? List<WaterIntakeEntry>.from((state as WaterLoaded).data) : <WaterIntakeEntry>[];
    currentData.removeWhere((e) => e.id == event.id);
    emit(WaterLoaded(data: currentData));
  }
}
