import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_root.dart';
import 'cubit/app_settings/app_settings_cubit.dart';
import 'cubit/notifications/notifications_cubit.dart';
import 'cubit/session/session_cubit.dart';
import 'cubit/ui_effects/ui_effects_cubit.dart';
import 'repositories/user_profile_repository.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'en';

  runApp(WaterTrackerApp(initialLanguage: savedLang));
}

class WaterTrackerApp extends StatelessWidget {
  final String initialLanguage;

  const WaterTrackerApp({super.key, this.initialLanguage = 'en'});

  @override
  Widget build(BuildContext context) {
    final profileRepo = UserProfileRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(
          create: (_) => SessionCubit(
            firebaseService: FirebaseService.instance,
            userProfileRepository: profileRepo,
          )..bootstrap(),
        ),
        BlocProvider<AppSettingsCubit>(
          create: (_) => AppSettingsCubit(
            initialLanguage: initialLanguage,
            userProfileRepository: profileRepo,
          )..bootstrap(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) => NotificationsCubit(
            notificationService: NotificationServiceGateway(NotificationService.instance),
          )..bootstrap(),
        ),
        BlocProvider<UiEffectsCubit>(
          create: (_) => UiEffectsCubit(),
        ),
      ],
      child: const AppRoot(),
    );
  }
}
