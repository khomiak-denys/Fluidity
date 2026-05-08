import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../../repositories/user_profile_repository.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final FirebaseService firebaseService;
  final UserProfileRepository userProfileRepository;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;

  SessionCubit({
    required this.firebaseService,
    required this.userProfileRepository,
  }) : super(const SessionState());

  Future<void> bootstrap() async {
    _bindAuthStream();
  }

  void _bindAuthStream() {
    _authSub?.cancel();
    _authSub = firebaseService.auth.authStateChanges().listen((user) {
      if (user == null) {
        _profileSub?.cancel();
        emit(const SessionState(
          status: SessionStatus.unauthenticated,
          authenticated: false,
        ));
        return;
      }

      emit(state.copyWith(
        status: SessionStatus.authenticated,
        authenticated: true,
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        clearAuthError: true,
      ));
      _attachProfileStream(user.uid);
    });
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: SessionStatus.loading, clearAuthError: true));
    final error = await firebaseService.signInWithEmail(email.trim(), password);
    if (error == null) {
      await firebaseService.logEvent('login', {'method': 'email'});
      await _ensureProfileForCurrentUser();
      return;
    }

    emit(state.copyWith(
      status: SessionStatus.error,
      authError: error,
      authenticated: false,
    ));
  }

  Future<void> register(String firstName, String lastName, String email, String password) async {
    emit(state.copyWith(status: SessionStatus.loading, clearAuthError: true));
    final error = await firebaseService.registerWithEmail(
      firstName.trim(),
      lastName.trim(),
      email.trim(),
      password,
    );

    if (error == null) {
      return;
    }

    emit(state.copyWith(
      status: SessionStatus.error,
      authError: error,
      authenticated: false,
    ));
  }

  Future<void> signOut() async {
    try {
      await firebaseService.signOut();
    } catch (_) {}
  }

  Future<void> _ensureProfileForCurrentUser() async {
    final user = firebaseService.auth.currentUser;
    if (user == null) return;

    final existing = await userProfileRepository.getById(user.uid);
    if (existing != null) return;

    final display = user.displayName ?? '';
    final parts = display.trim().split(' ');
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final profile = UserProfile(
      id: user.uid,
      firstName: first,
      lastName: last,
      email: user.email ?? '',
      targetWaterAmount: 2000,
      registrationDate: DateTime.now(),
    );

    await userProfileRepository.upsert(profile);
  }

  void _attachProfileStream(String uid) {
    _profileSub?.cancel();
    _profileSub = userProfileRepository.watchById(uid).listen((profile) {
      emit(state.copyWith(profile: profile));
    });
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    await _profileSub?.cancel();
    return super.close();
  }
}
