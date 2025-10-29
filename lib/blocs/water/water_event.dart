import '../../models/water_intake.dart';

abstract class WaterEvent {}

class LoadWaterEvent extends WaterEvent {}

class RefreshWaterEvent extends WaterEvent {}

class SimulateErrorEvent extends WaterEvent {}

class AddWaterEntryEvent extends WaterEvent {
  final WaterIntakeEntry entry;
  AddWaterEntryEvent(this.entry);
}

class DeleteWaterEntryEvent extends WaterEvent {
  final String id;
  DeleteWaterEntryEvent(this.id);
}
