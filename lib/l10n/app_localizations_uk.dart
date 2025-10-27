// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get language => 'Українська';

  @override
  String get loginTitle => 'Увійти';

  @override
  String get loginSubtitle => 'Введіть будь-які дані для демонстрації';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailEmptyError => 'Введіть email';

  @override
  String get emailInvalidError => 'Неправильний формат email';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordHint => 'Введіть пароль';

  @override
  String get passwordEmptyError => 'Введіть пароль';

  @override
  String get passwordLengthError => 'Мінімум 6 символів';

  @override
  String get loginButton => 'Увійти';

  @override
  String get noAccountRegister => 'Немає акаунту? Зареєструватися';

  @override
  String get featureTracking => 'Відстеження';

  @override
  String get featureGoals => 'Цілі';

  @override
  String get featureReminders => 'Нагадування';

  @override
  String get appSubtitle => 'Ваша персональна система контролю води';

  @override
  String get registerTitle => 'Реєстрація';

  @override
  String get createAccountTitle => 'Створити акаунт';

  @override
  String get createAccountSubtitle => 'Заповніть форму, щоб почати відстеження води';

  @override
  String get firstNameLabel => 'Ім\'я';

  @override
  String get firstNameHint => 'Введіть ім\'я';

  @override
  String get firstNameEmptyError => 'Введіть ім\'я';

  @override
  String get lastNameLabel => 'Прізвище';

  @override
  String get lastNameHint => 'Введіть прізвище';

  @override
  String get lastNameEmptyError => 'Введіть прізвище';

  @override
  String get registerButton => 'Зареєструватися';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get profileSubtitle => 'Налаштуйте Fluidity під себе';

  @override
  String get greeting => 'Вітаємо!';

  @override
  String get demoUser => 'Демонстраційний користувач';

  @override
  String get settings => 'Налаштування';

  @override
  String get dailyGoal => 'Добова ціль';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get signOut => 'Вийти';

  @override
  String get testCrashlytics => 'Перевірити Crashlytics';

  @override
  String get setGoal => 'Встановити ціль';

  @override
  String get dailyGoalMl => 'Добова ціль (мл)';

  @override
  String get enterAmountMl => 'Введіть кількість в мл';

  @override
  String get recommendedGoal => 'Рекомендовано 2000-3000 мл на день';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get homeTitle => 'Головна';

  @override
  String get waterIntake => 'Вживання води';

  @override
  String get addWater => 'Додати воду';

  @override
  String get today => 'Сьогодні';

  @override
  String get outOf => 'з';

  @override
  String get addEntry => 'Додати запис';

  @override
  String get amount => 'Кількість';

  @override
  String get time => 'Час';

  @override
  String get comment => 'Коментар';

  @override
  String get add => 'Додати';

  @override
  String get statistics => 'Статистика';

  @override
  String get reminders => 'Нагадування';

  @override
  String get bottomNavHome => 'Головна';

  @override
  String get bottomNavStats => 'Статистика';

  @override
  String get bottomNavReminders => 'Нагадування';

  @override
  String get bottomNavProfile => 'Профіль';

  @override
  String get english => 'Англійська';

  @override
  String get ukrainian => 'Українська';

  @override
  String get remindersSubtitle => 'Встановіть нагадування випити води';

  @override
  String get reminderAdded => 'Нагадування додано!';

  @override
  String get reminderDeleted => 'Нагадування видалено!';

  @override
  String get addReminder => 'Додати нагадування';

  @override
  String get selectTime => 'Вибрати час';

  @override
  String get remindersEmpty => 'Наразі немає нагадувань. Додайте перше!';

  @override
  String get quickAddTitle => 'Додати';

  @override
  String waterAdded(Object amount) {
    return 'Додано $amount мл води!';
  }

  @override
  String get startTrackingTitle => 'Почніть відстеження!';

  @override
  String get startTrackingBody => 'Додайте свій перший запис води, натиснувши на кнопки вище або кнопку FAB';

  @override
  String get statisticsSubtitle => 'Слідкуйте за своїм прогресом';

  @override
  String get statisticsWeekly => 'Статистика за тиждень';

  @override
  String get hourlyDistribution => 'Розподіл за сьогодні';

  @override
  String get statsTodayTitle => 'Сьогодні випито';

  @override
  String get statsAverageTitle => 'В середньому за день';

  @override
  String get statsWeekTotalTitle => 'Загалом за тиждень';

  @override
  String get entryDeleted => 'Запис видалено';

  @override
  String get typeLabel => 'Тип';

  @override
  String get congratulations => 'Вітаємо!';

  @override
  String get goalReached => 'Ви досягли своєї денної цілі!';

  @override
  String get emailValidatorEmpty => 'Будь ласка введіть ваш email';

  @override
  String get emailValidatorInvalid => 'Будь ласка введіть коректну адресу електронної пошти';

  @override
  String get passwordValidatorEmpty => 'Будь ласка введіть ваш пароль';

  @override
  String get passwordValidatorLength => 'Пароль повинен містити щонайменше 6 символів';

  @override
  String get noAccountPrompt => 'Немає акаунту? Зареєструватися';
}
