import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

enum SessionStatus { initial, loading, authenticated, unauthenticated, error }

class SessionState extends Equatable {
  final SessionStatus status;
  final bool authenticated;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? authError;
  final UserProfile? profile;

  const SessionState({
    this.status = SessionStatus.initial,
    this.authenticated = false,
    this.uid,
    this.email,
    this.displayName,
    this.authError,
    this.profile,
  });

  SessionState copyWith({
    SessionStatus? status,
    bool? authenticated,
    String? uid,
    String? email,
    String? displayName,
    String? authError,
    bool clearAuthError = false,
    UserProfile? profile,
    bool clearProfile = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      authenticated: authenticated ?? this.authenticated,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      authError: clearAuthError ? null : (authError ?? this.authError),
      profile: clearProfile ? null : (profile ?? this.profile),
    );
  }

  @override
  List<Object?> get props => [status, authenticated, uid, email, displayName, authError, profile];
}
