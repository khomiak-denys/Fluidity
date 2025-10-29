import '../../models/water_intake.dart';

abstract class WaterState {}

class WaterInitial extends WaterState {}

class WaterLoading extends WaterState {
  final List<WaterIntakeEntry> data;
  WaterLoading({this.data = const []});
}

class WaterLoaded extends WaterState {
  final List<WaterIntakeEntry> data;
  WaterLoaded({required this.data});
}

class WaterError extends WaterState {
  final Object error;
  final List<WaterIntakeEntry> data;
  WaterError({required this.error, this.data = const []});
}
