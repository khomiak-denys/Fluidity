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
        return 'Будь ласка, підтвердіть свою електронну пошту, перш ніж увійти.';
      }
      await analytics.logLogin(loginMethod: 'email');
      return null;
    } on FirebaseAuthException catch (e) {
      await crashlytics.recordError(e, e.stackTrace, reason: 'signInWithEmail failed');
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Неправильний email або пароль.';
      } else if (e.code == 'invalid-email') {
        return 'Неправильний формат email.';
      }
      return 'Сталася помилка. Спробуйте пізніше.';
    } catch (e, st) {
      await crashlytics.recordError(e, st, reason: 'signInWithEmail failed');
      return 'Сталася невідома помилка.';
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
        return 'Пароль занадто слабкий.';
      } else if (e.code == 'email-already-in-use') {
        return 'Цей email вже зареєстровано.';
      } else if (e.code == 'invalid-email') {
        return 'Неправильний формат email.';
      }
      return 'Сталася помилка реєстрації.';
    } catch (e, st) {
      await crashlytics.recordError(e, st, reason: 'registerWithEmail failed');
      return 'Сталася невідома помилка.';
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
