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

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await analytics.logLogin(loginMethod: 'email');
      return true;
    } catch (e, st) {
      await crashlytics.recordError(e, st, reason: 'signInWithEmail failed');
      return false;
    }
  }

  Future<bool> registerWithEmail(String firstName, String lastName, String email, String password) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName('$firstName $lastName');
      await analytics.logEvent(name: 'sign_up', parameters: {'method': 'email'});
      return true;
    } catch (e, st) {
      await crashlytics.recordError(e, st, reason: 'registerWithEmail failed');
      return false;
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
