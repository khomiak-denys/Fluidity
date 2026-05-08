import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StreamBackedBloc<E, S, T> extends Bloc<E, S> {
  final String userId;
  StreamSubscription<List<T>>? _subscription;

  StreamBackedBloc({required this.userId, required S initialState}) : super(initialState);

  List<T> currentData(S state);
  S loadingState(List<T> data);
  S loadedState(List<T> data);
  S errorState(Object error, List<T> data);
  Stream<List<T>> watchAll(String userId);

  Future<void> handleLoad(
    Emitter<S> emit, {
    required void Function(List<T> items) onData,
    required void Function(Object error) onError,
  }) async {
    final current = currentData(state);
    emit(loadingState(current));

    if (userId.isEmpty) {
      emit(loadedState(<T>[]));
      return;
    }

    await _subscription?.cancel();
    _subscription = watchAll(userId).listen(
      onData,
      onError: onError,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
