import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore_for_file: use_build_context_synchronously

import '../cubit/app_settings/app_settings_cubit.dart';
import '../cubit/app_settings/app_settings_state.dart';
import '../cubit/session/session_cubit.dart';
import '../cubit/session/session_state.dart';
import '../cubit/ui_effects/ui_effects_cubit.dart';
import '../l10n/app_localizations.dart';
import '../screens/register_screen.dart';
import 'auth_gate.dart';
import 'auth_messages.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, next) => prev.profile?.targetWaterAmount != next.profile?.targetWaterAmount,
      listener: (context, state) {
        final goal = state.profile?.targetWaterAmount;
        if (goal != null) {
          context.read<AppSettingsCubit>().setDailyGoalLocal(goal);
        }
      },
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, appState) {
          return MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(appState.language),
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,
            routes: {
              '/register': (routeContext) {
                final sessionState = routeContext.watch<SessionCubit>().state;
                return RegisterScreen(
                  onRegister: (_, firstName, lastName, email, password) async {
                    await routeContext.read<SessionCubit>().register(firstName, lastName, email, password);
                    final next = routeContext.read<SessionCubit>().state;
                    if (next.authError == null) {
                      routeContext.read<UiEffectsCubit>().emitInfo('register_verification_sent');
                      _navigatorKey.currentState?.pop();
                      return;
                    }
                    routeContext.read<UiEffectsCubit>().emitAuthError(next.authError!);
                  },
                  error: sessionState.authError != null
                      ? localizeAuthMessage(routeContext, sessionState.authError!)
                      : null,
                );
              },
            },
            home: AuthGate(navigatorKey: _navigatorKey),
          );
        },
      ),
    );
  }
}
