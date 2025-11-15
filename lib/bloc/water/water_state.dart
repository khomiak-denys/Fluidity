import '../../models/water_entry.dart';

abstract class WaterState {}

class WaterInitial extends WaterState {}

class WaterLoading extends WaterState {
  final List<WaterEntry> data;
  WaterLoading({this.data = const []});
}

class WaterLoaded extends WaterState {
  final List<WaterEntry> data;
  WaterLoaded({required this.data});
}

class WaterError extends WaterState {
  final Object error;
  final List<WaterEntry> data;
  WaterError({required this.error, this.data = const []});
}
