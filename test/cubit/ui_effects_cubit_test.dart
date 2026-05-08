import 'package:flutter_test/flutter_test.dart';

import 'package:fluidity/cubit/ui_effects/ui_effects_cubit.dart';

void main() {
  late UiEffectsCubit cubit;

  setUp(() {
    cubit = UiEffectsCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('emitAuthError publishes auth error effect', () {
    cubit.emitAuthError('auth.invalid_credentials');

    final pending = cubit.state.pending;
    expect(pending, isA<AuthErrorEffect>());
    expect((pending as AuthErrorEffect).code, 'auth.invalid_credentials');
  });

  test('consume clears current effect by id', () {
    cubit.emitInfo('register_verification_sent');
    final id = cubit.state.pending!.id;

    cubit.consume(id);

    expect(cubit.state.pending, isNull);
  });
}
