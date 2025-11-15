import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter any data for demonstration'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @emailEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get emailEmptyError;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get emailInvalidError;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordHint;

  /// No description provided for @passwordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordEmptyError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordLengthError;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccountRegister;

  /// No description provided for @featureTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get featureTracking;

  /// No description provided for @featureGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get featureGoals;

  /// No description provided for @featureReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get featureReminders;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal water control system'**
  String get appSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registerTitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill out the form to start tracking water'**
  String get createAccountSubtitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get firstNameHint;

  /// No description provided for @firstNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get firstNameEmptyError;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get lastNameHint;

  /// No description provided for @lastNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get lastNameEmptyError;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Fluidity for yourself'**
  String get profileSubtitle;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get greeting;

  /// No description provided for @demoUser.
  ///
  /// In en, this message translates to:
  /// **'Demo User'**
  String get demoUser;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @testCrashlytics.
  ///
  /// In en, this message translates to:
  /// **'Test Crashlytics'**
  String get testCrashlytics;

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get setGoal;

  /// No description provided for @dailyGoalMl.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal (ml)'**
  String get dailyGoalMl;

  /// No description provided for @enterAmountMl.
  ///
  /// In en, this message translates to:
  /// **'Enter amount in ml'**
  String get enterAmountMl;

  /// No description provided for @recommendedGoal.
  ///
  /// In en, this message translates to:
  /// **'Recommended 2000-3000 ml per day'**
  String get recommendedGoal;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @addWater.
  ///
  /// In en, this message translates to:
  /// **'Add Water'**
  String get addWater;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'out of'**
  String get outOf;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get bottomNavStats;

  /// No description provided for @bottomNavReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get bottomNavReminders;

  /// No description provided for @bottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @ukrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get ukrainian;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set reminders to drink water'**
  String get remindersSubtitle;

  /// No description provided for @reminderAdded.
  ///
  /// In en, this message translates to:
  /// **'Reminder added!'**
  String get reminderAdded;

  /// No description provided for @reminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted!'**
  String get reminderDeleted;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @remindersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet. Add the first one!'**
  String get remindersEmpty;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickAddTitle;

  /// Snackbar shown after adding water
  ///
  /// In en, this message translates to:
  /// **'Added {amount} ml of water!'**
  String waterAdded(Object amount);

  /// No description provided for @startTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking!'**
  String get startTrackingTitle;

  /// No description provided for @startTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first water entry using the buttons above or the FAB'**
  String get startTrackingBody;

  /// No description provided for @statisticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your progress'**
  String get statisticsSubtitle;

  /// No description provided for @statisticsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Statistics for the week'**
  String get statisticsWeekly;
  String get statisticsDaily;
  String get statisticsMonthly;

  /// No description provided for @hourlyDistribution.
  ///
  /// In en, this message translates to:
  /// **'Hourly distribution (today)'**
  String get hourlyDistribution;

  /// No description provided for @statsTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s intake'**
  String get statsTodayTitle;

  /// No description provided for @statsAverageTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get statsAverageTitle;

  /// No description provided for @statsWeekTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly total'**
  String get statsWeekTotalTitle;

  /// No description provided for @statsMonthTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly total'**
  String get statsMonthTotalTitle;

  /// No description provided for @errorLoadingEntries.
  ///
  /// In en, this message translates to:
  /// **'Error loading entries'**
  String get errorLoadingEntries;
  /// No description provided for @errorLoadingReminders.
  ///
  /// In en, this message translates to:
  /// **'Error loading reminders'**
  String get errorLoadingReminders;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please check your access and try again.'**
  String get errorPermissionDenied;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your daily goal!'**
  String get goalReached;

  /// No description provided for @emailValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailValidatorEmpty;

  /// No description provided for @emailValidatorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailValidatorInvalid;

  /// No description provided for @passwordValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordValidatorEmpty;

  /// No description provided for @passwordValidatorLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordValidatorLength;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccountPrompt;

  /// No description provided for @auth_email_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before signing in.'**
  String get auth_email_not_verified;

  /// No description provided for @auth_invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get auth_invalid_credentials;

  /// No description provided for @auth_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get auth_invalid_email;

  /// No description provided for @auth_weak_password.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get auth_weak_password;

  /// No description provided for @auth_email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get auth_email_already_in_use;

  /// No description provided for @auth_registration_error.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again later.'**
  String get auth_registration_error;

  /// No description provided for @auth_unknown_error.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Please try again later.'**
  String get auth_unknown_error;

  /// No description provided for @auth_verification_email_sent.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to your address. Please check your inbox.'**
  String get auth_verification_email_sent;

  // New: period and misc labels
  String get periodDay;
  String get periodWeek;
  String get periodMonth;
  String get weekdayMonShort;
  String get weekdayTueShort;
  String get weekdayWedShort;
  String get weekdayThuShort;
  String get weekdayFriShort;
  String get weekdaySatShort;
  String get weekdaySunShort;
  String get retry;
  String get addCommentHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
