// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/reminder/reminder_bloc.dart';
import '../bloc/reminder/reminder_event.dart';
import '../bloc/water/water_bloc.dart';
import '../bloc/water/water_event.dart';
import '../cubit/session/session_cubit.dart';
import '../cubit/session/session_state.dart';
import '../cubit/ui_effects/ui_effects_cubit.dart';
import '../repositories/reminder_setting_repository.dart';
import '../repositories/water_entry_repository.dart';
import '../screens/login_screen.dart';
import 'app_shell.dart';
import 'auth_messages.dart';

class AuthGate extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AuthGate({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UiEffectsCubit, UiEffectsState>(
      listenWhen: (prev, next) => prev.pending?.id != next.pending?.id,
      listener: (context, state) {
        final effect = state.pending;
        if (effect == null) return;

        if (effect is AuthErrorEffect) {
          final msg = localizeAuthMessage(context, effect.code);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
          context.read<UiEffectsCubit>().consume(effect.id);
          return;
        }

        if (effect is InfoEffect && effect.messageKey == 'register_verification_sent') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizeAuthMessage(context, 'auth.verification_email_sent')),
              backgroundColor: Colors.green,
            ),
          );
          context.read<UiEffectsCubit>().consume(effect.id);
        }
      },
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, sessionState) {
          if (!sessionState.authenticated || (sessionState.uid?.isEmpty ?? true)) {
            return LoginScreen(
              onLogin: (ctx, email, password) async {
                await context.read<SessionCubit>().login(email, password);
                final next = context.read<SessionCubit>().state;
                if (next.authError != null) {
                  context.read<UiEffectsCubit>().emitAuthError(next.authError!);
                }
              },
              onRegister: () => navigatorKey.currentState?.pushNamed('/register'),
              error: sessionState.authError != null
                  ? localizeAuthMessage(context, sessionState.authError!)
                  : null,
            );
          }

          final uid = sessionState.uid!;
          return MultiBlocProvider(
            providers: [
              BlocProvider<WaterBloc>(
                create: (_) => WaterBloc(
                  repo: WaterEntryRepository(),
                  userId: uid,
                )..add(LoadWaterEvent()),
              ),
              BlocProvider<ReminderBloc>(
                create: (_) => ReminderBloc(
                  repo: ReminderSettingRepository(),
                  userId: uid,
                )..add(LoadRemindersEvent()),
              ),
            ],
            child: AppShell(navigatorKey: navigatorKey),
          );
        },
      ),
    );
  }
}
