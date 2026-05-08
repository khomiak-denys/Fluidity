import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluidity/cubit/session/session_cubit.dart';
import 'package:fluidity/cubit/session/session_state.dart';
import 'package:fluidity/models/user_profile.dart';
import 'package:fluidity/repositories/user_profile_repository.dart';
import 'package:fluidity/services/firebase_service.dart';

class _MockFirebaseService extends Mock implements FirebaseService {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockFirebaseUser extends Mock implements User {}

class _MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late _MockFirebaseService firebaseService;
  late _MockFirebaseAuth firebaseAuth;
  late _MockUserProfileRepository userProfileRepository;
  late StreamController<User?> authController;
  late StreamController<UserProfile?> profileController;

  setUp(() {
    firebaseService = _MockFirebaseService();
    firebaseAuth = _MockFirebaseAuth();
    userProfileRepository = _MockUserProfileRepository();
    authController = StreamController<User?>.broadcast();
    profileController = StreamController<UserProfile?>.broadcast();

    when(() => firebaseService.auth).thenReturn(firebaseAuth);
    when(() => firebaseAuth.authStateChanges()).thenAnswer((_) => authController.stream);
  });

  tearDown(() async {
    await authController.close();
    await profileController.close();
  });

  blocTest<SessionCubit, SessionState>(
    'bootstrap waits for auth stream and emits unauthenticated on null user',
    build: () => SessionCubit(
      firebaseService: firebaseService,
      userProfileRepository: userProfileRepository,
    ),
    act: (cubit) async {
      await cubit.bootstrap();
      authController.add(null);
    },
    expect: () => const <SessionState>[
      SessionState(
        status: SessionStatus.unauthenticated,
        authenticated: false,
      ),
    ],
    verify: (_) {
      verify(() => firebaseAuth.authStateChanges()).called(1);
      verifyNever(() => firebaseAuth.currentUser);
    },
  );

  blocTest<SessionCubit, SessionState>(
    'stream user emits authenticated and profile update',
    build: () {
      when(() => userProfileRepository.watchById('uid-1')).thenAnswer((_) => profileController.stream);
      return SessionCubit(
        firebaseService: firebaseService,
        userProfileRepository: userProfileRepository,
      );
    },
    act: (cubit) async {
      await cubit.bootstrap();
      final user = _MockFirebaseUser();
      when(() => user.uid).thenReturn('uid-1');
      when(() => user.email).thenReturn('u@test.dev');
      when(() => user.displayName).thenReturn('User One');

      authController.add(user);
      await Future<void>.delayed(Duration.zero);
      profileController.add(
        UserProfile(
          id: 'uid-1',
          firstName: 'User',
          lastName: 'One',
          email: 'u@test.dev',
          targetWaterAmount: 2200,
          registrationDate: DateTime(2026, 1, 1),
        ),
      );
    },
    expect: () => <SessionState>[
      const SessionState(
        status: SessionStatus.authenticated,
        authenticated: true,
        uid: 'uid-1',
        email: 'u@test.dev',
        displayName: 'User One',
      ),
      SessionState(
        status: SessionStatus.authenticated,
        authenticated: true,
        uid: 'uid-1',
        email: 'u@test.dev',
        displayName: 'User One',
        profile: UserProfile(
          id: 'uid-1',
          firstName: 'User',
          lastName: 'One',
          email: 'u@test.dev',
          targetWaterAmount: 2200,
          registrationDate: DateTime(2026, 1, 1),
        ),
      ),
    ],
  );

  blocTest<SessionCubit, SessionState>(
    'login failure emits loading then error',
    build: () {
      when(() => firebaseService.signInWithEmail('bad@test.dev', '123456')).thenAnswer((_) async => 'auth.invalid_credentials');
      return SessionCubit(
        firebaseService: firebaseService,
        userProfileRepository: userProfileRepository,
      );
    },
    act: (cubit) => cubit.login('bad@test.dev', '123456'),
    expect: () => const <SessionState>[
      SessionState(status: SessionStatus.loading),
      SessionState(
        status: SessionStatus.error,
        authenticated: false,
        authError: 'auth.invalid_credentials',
      ),
    ],
  );

  blocTest<SessionCubit, SessionState>(
    'login success does not emit authenticated without stream event',
    build: () {
      when(() => firebaseService.signInWithEmail('ok@test.dev', '123456')).thenAnswer((_) async => null);
      when(() => firebaseService.logEvent('login', any())).thenAnswer((_) async {});
      when(() => firebaseAuth.currentUser).thenReturn(null);
      return SessionCubit(
        firebaseService: firebaseService,
        userProfileRepository: userProfileRepository,
      );
    },
    act: (cubit) => cubit.login('ok@test.dev', '123456'),
    expect: () => const <SessionState>[
      SessionState(status: SessionStatus.loading),
    ],
  );

  blocTest<SessionCubit, SessionState>(
    'signOut relies on stream for unauthenticated state',
    build: () {
      when(() => firebaseService.signOut()).thenAnswer((_) async {});
      return SessionCubit(
        firebaseService: firebaseService,
        userProfileRepository: userProfileRepository,
      );
    },
    act: (cubit) async {
      await cubit.bootstrap();
      await cubit.signOut();
      authController.add(null);
    },
    expect: () => const <SessionState>[
      SessionState(
        status: SessionStatus.unauthenticated,
        authenticated: false,
      ),
    ],
    verify: (_) {
      verify(() => firebaseService.signOut()).called(1);
    },
  );
}
