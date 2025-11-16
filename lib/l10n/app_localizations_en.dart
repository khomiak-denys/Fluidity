// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Enter any data for demonstration';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailEmptyError => 'Enter email';

  @override
  String get emailInvalidError => 'Invalid email format';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter password';

  @override
  String get passwordEmptyError => 'Enter password';

  @override
  String get passwordLengthError => 'Minimum 6 characters';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccountRegister => 'No account? Register';

  @override
  String get featureTracking => 'Tracking';

  @override
  String get featureGoals => 'Goals';

  @override
  String get featureReminders => 'Reminders';

  @override
  String get appSubtitle => 'Your personal water control system';

  @override
  String get registerTitle => 'Registration';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get createAccountSubtitle => 'Fill out the form to start tracking water';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get firstNameHint => 'Enter first name';

  @override
  String get firstNameEmptyError => 'Enter first name';

  @override
  String get lastNameLabel => 'Last Name';

  @override
  String get lastNameHint => 'Enter last name';

  @override
  String get lastNameEmptyError => 'Enter last name';

  @override
  String get registerButton => 'Register';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle => 'Customize Fluidity for yourself';

  @override
  String get greeting => 'Welcome!';

  @override
  String get demoUser => 'Demo User';

  @override
  String get settings => 'Settings';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get notifications => 'Notifications';

  @override
  String get signOut => 'Sign Out';

  @override
  String get testCrashlytics => 'Test Crashlytics';

  @override
  String get setGoal => 'Set Goal';

  @override
  String get dailyGoalMl => 'Daily Goal (ml)';

  @override
  String get enterAmountMl => 'Enter amount in ml';

  @override
  String get recommendedGoal => 'Recommended 2000-3000 ml per day';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get homeTitle => 'Home';

  @override
  String get waterIntake => 'Water Intake';

  @override
  String get addWater => 'Add Water';

  @override
  String get today => 'Today';

  @override
  String get outOf => 'out of';

  @override
  String get addEntry => 'Add Entry';

  @override
  String get amount => 'Amount';

  @override
  String get time => 'Time';

  @override
  String get comment => 'Comment';

  @override
  String get add => 'Add';

  @override
  String get statistics => 'Statistics';

  @override
  String get reminders => 'Reminders';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavStats => 'Statistics';

  @override
  String get bottomNavReminders => 'Reminders';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get english => 'English';

  @override
  String get ukrainian => 'Ukrainian';

  @override
  String get remindersSubtitle => 'Set reminders to drink water';

  @override
  String get reminderAdded => 'Reminder added!';

  @override
  String get reminderDeleted => 'Reminder deleted!';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get selectTime => 'Select time';

  @override
  String get remindersEmpty => 'No reminders yet. Add the first one!';

  @override
  String get quickAddTitle => 'Add';

  @override
  String waterAdded(Object amount) {
    return 'Added $amount ml of water!';
  }

  @override
  String get startTrackingTitle => 'Start tracking!';

  @override
  String get startTrackingBody => 'Add your first water entry using the buttons above or the FAB';

  @override
  String get statisticsSubtitle => 'Keep track of your progress';

  @override
  String get statisticsWeekly => 'Statistics for the week';

  @override
  String get statisticsDaily => 'Statistics for the day';

  @override
  String get statisticsMonthly => 'Statistics for the month';

  @override
  String get hourlyDistribution => 'Hourly distribution (today)';

  @override
  String get statsTodayTitle => 'Today\'s intake';

  @override
  String get statsAverageTitle => 'Daily average';

  @override
  String get statsWeekTotalTitle => 'Weekly total';

  @override
  String get statsMonthTotalTitle => 'Monthly total';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get typeLabel => 'Type';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get goalReached => 'You\'ve reached your daily goal!';

  @override
  String get emailValidatorEmpty => 'Please enter your email';

  @override
  String get emailValidatorInvalid => 'Please enter a valid email address';

  @override
  String get passwordValidatorEmpty => 'Please enter your password';

  @override
  String get passwordValidatorLength => 'Password must be at least 6 characters';

  @override
  String get noAccountPrompt => 'No account? Register';

  @override
  String get addCommentHint => 'Add a comment (optional)';

  @override
  String get errorLoadingEntries => 'Could not load entries';

  @override
  String get errorPermissionDenied => 'Permission denied. Please grant access and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get errorLoadingReminders => 'Could not load reminders';

  @override
  String get weekdayMonShort => 'Mon';

  @override
  String get weekdayTueShort => 'Tue';

  @override
  String get weekdayWedShort => 'Wed';

  @override
  String get weekdayThuShort => 'Thu';

  @override
  String get weekdayFriShort => 'Fri';

  @override
  String get weekdaySatShort => 'Sat';

  @override
  String get weekdaySunShort => 'Sun';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get auth_email_not_verified => 'Please verify your email before signing in.';

  @override
  String get auth_invalid_credentials => 'Incorrect email or password.';

  @override
  String get auth_invalid_email => 'Invalid email format.';

  @override
  String get auth_weak_password => 'The password is too weak.';

  @override
  String get auth_email_already_in_use => 'This email is already registered.';

  @override
  String get auth_registration_error => 'Registration failed. Please try again later.';

  @override
  String get auth_unknown_error => 'An unknown error occurred. Please try again later.';

  @override
  String get auth_verification_email_sent => 'A verification email has been sent to your address. Please check your inbox.';
}
