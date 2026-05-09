import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

String localizeAuthMessage(BuildContext ctx, String code) {
  final loc = AppLocalizations.of(ctx)!;
  switch (code) {
    case 'auth.email_not_verified':
      return loc.auth_email_not_verified;
    case 'auth.invalid_credentials':
      return loc.auth_invalid_credentials;
    case 'auth.invalid_email':
      return loc.auth_invalid_email;
    case 'auth.weak_password':
      return loc.auth_weak_password;
    case 'auth.email_already_in_use':
      return loc.auth_email_already_in_use;
    case 'auth.registration_error':
      return loc.auth_registration_error;
    case 'auth.verification_email_sent':
      return loc.auth_verification_email_sent;
    case 'auth.unknown_error':
    default:
      return loc.auth_unknown_error;
  }
}
