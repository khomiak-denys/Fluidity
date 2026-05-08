import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UiEffect extends Equatable {
  final int id;
  const UiEffect(this.id);

  @override
  List<Object?> get props => [id];
}

class AuthErrorEffect extends UiEffect {
  final String code;
  const AuthErrorEffect(super.id, this.code);

  @override
  List<Object?> get props => [id, code];
}

class InfoEffect extends UiEffect {
  final String messageKey;
  const InfoEffect(super.id, this.messageKey);

  @override
  List<Object?> get props => [id, messageKey];
}

class PermissionDeniedPromptEffect extends UiEffect {
  const PermissionDeniedPromptEffect(super.id);
}

class UiEffectsState extends Equatable {
  final UiEffect? pending;

  const UiEffectsState({this.pending});

  UiEffectsState copyWith({UiEffect? pending, bool clear = false}) {
    return UiEffectsState(pending: clear ? null : (pending ?? this.pending));
  }

  @override
  List<Object?> get props => [pending];
}

class UiEffectsCubit extends Cubit<UiEffectsState> {
  int _seq = 0;

  UiEffectsCubit() : super(const UiEffectsState());

  void emitAuthError(String code) {
    _seq += 1;
    emit(UiEffectsState(pending: AuthErrorEffect(_seq, code)));
  }

  void emitInfo(String messageKey) {
    _seq += 1;
    emit(UiEffectsState(pending: InfoEffect(_seq, messageKey)));
  }

  void emitPermissionDialog() {
    _seq += 1;
    emit(UiEffectsState(pending: PermissionDeniedPromptEffect(_seq)));
  }

  void consume(int id) {
    final p = state.pending;
    if (p != null && p.id == id) {
      emit(state.copyWith(clear: true));
    }
  }
}
