import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  late final FirebaseAuth auth;
  late final FirebaseAnalytics analytics;
  late final FirebaseCrashlytics crashlytics;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instance;
    analytics = FirebaseAnalytics.instance;
    crashlytics = FirebaseCrashlytics.instance;

    // Enable Crashlytics collection by default
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    // Route Flutter errors to Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      crashlytics.recordFlutterError(details);
    };

    // Capture synchronous errors (non-web)
    if (!kIsWeb) {
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await auth.signOut();
        return 'auth.email_not_verified';
      }
      await analytics.logLogin(loginMethod: 'email');
      return null;
    } on FirebaseAuthException catch (e) {
      await crashlytics.recordError(e, e.stackTrace, reason: 'signInWithEmail failed');
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'auth.invalid_credentials';
      } else if (e.code == 'invalid-email') {
        return 'auth.invalid_email';
      }
      return 'auth.unknown_error';
    } catch (e, st) {
      await crashlytics.recordError(e, st, reason: 'signInWithEmail failed');
      return 'auth.unknown_error';
    }
  }

  Future<String?> registerWithEmail(String firstName, String lastName, String email, String password) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName('$firstName $lastName');
      await cred.user?.sendEmailVerification();
      await auth.signOut(); // Force sign out until email is verified
      await analytics.logEvent(name: 'sign_up', parameters: {'method': 'email'});
      return null;
    } on FirebaseAuthException catch (e) {
      await crashlytics.recordError(e, e.stackTrace, reason: 'registerWithEmail failed');
      if (e.code == 'weak-password') {
        return 'auth.weak_password';
      } else if (e.code == 'email-already-in-use') {
        return 'auth.email_already_in_use';
      } else if (e.code == 'invalid-email') {
        return 'auth.invalid_email';
      }
      return 'auth.registration_error';
    } catch (e, st) {
      await crashlytics.recordError(e, st, reason: 'registerWithEmail failed');
      return 'auth.unknown_error';
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    try {
      await analytics.logEvent(name: name, parameters: params);
    } catch (_) {}
  }

  // For testing Crashlytics
  void forceCrash() {
    crashlytics.crash();
  }
}
