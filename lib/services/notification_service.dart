import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../models/reminder_setting.dart';

// Top-level background callback required by flutter_local_notifications on Android.
// Must be a static or top-level function and marked as an entry point so it is
// reachable from the background isolate after tree-shaking.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[Notif][BG] onDidReceiveNotificationResponse: id=${response.id} actionId=${response.actionId} payload=${response.payload}');
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  final Set<int> _activeIds = <int>{};
  String _drinkTitle = 'Time to drink water 💧';

  int _clampToInt32(int v) => v & 0x7fffffff;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    // Timezone init (best-effort without native plugin)
    tzdata.initializeTimeZones();
    String? chosenLocation;
    final abbreviation = DateTime.now().timeZoneName; // e.g. EET, EEST, GMT, UTC
    const Map<String, String> abbrevMap = {
      'UTC': 'UTC',
      'GMT': 'GMT',
      // Ukraine uses Europe/Kyiv in the tz database (renamed from Europe/Kiev)
      'EET': 'Europe/Kyiv',
      'EEST': 'Europe/Kyiv',
      'CEST': 'Europe/Berlin',
      'CET': 'Europe/Berlin',
      'BST': 'Europe/London',
      'EDT': 'America/New_York',
      'EST': 'America/New_York',
      'PDT': 'America/Los_Angeles',
      'PST': 'America/Los_Angeles',
    };
    final mapped = abbrevMap[abbreviation];
    if (mapped != null && tz.timeZoneDatabase.locations.containsKey(mapped)) {
      chosenLocation = mapped;
    }
    chosenLocation ??= 'UTC';
    tz.setLocalLocation(tz.getLocation(chosenLocation));
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Notif] Timezone initialized. Abbrev=$abbreviation, tzLocation=$chosenLocation');
    }

    // Initialize plugin
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[Notif] onDidReceiveNotificationResponse: id=${resp.id} actionId=${resp.actionId} payload=${resp.payload}');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Notif] Plugin initialized');
    }

    // After initialization, attempt to restore any persisted daily schedules if Firestore not yet loaded.
    await _restorePersistedDailySchedules();

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Notif] iOS permission result: $granted');
      }
    } else if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Notif] Android POST_NOTIFICATIONS granted: $granted');
      }
    }
  }

  AndroidNotificationDetails _androidDetails() {
    const channelId = 'reminders_channel';
    const channelName = 'Reminders';
    const channelDesc = 'Water intake reminders';
    return const AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
  }

  DarwinNotificationDetails _iosDetails() {
    return const DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: true);
  }

  NotificationDetails _details() => NotificationDetails(android: _androidDetails(), iOS: _iosDetails());

  // Centralized content builders so you can tweak notification text in one place.
  // Customize these two methods to change title/body templates.
  String _buildDailyTitle(ReminderSetting r) {
    return _drinkTitle;
  }

  String _buildDailyBody(ReminderSetting r) {
    if (r.comment.trim().isNotEmpty) return r.comment.trim();
    final hh = r.scheduledTime.hour.toString().padLeft(2, '0');
    final mm = r.scheduledTime.minute.toString().padLeft(2, '0');
    return "It's time to drink water 💧 ($hh:$mm)";
  }

  int _toNotifId(String id) {
    final parsed = int.tryParse(id);
    final value = parsed ?? id.hashCode;
    return _clampToInt32(value);
  }

  Future<void> scheduleDaily(ReminderSetting reminder) async {
    if (kIsWeb) return;
    // Ensure initialization if user triggered before deferred init finished
    if (!_initialized) {
      if (kDebugMode) { print('[Notif] scheduleDaily called before init, running init() now'); }
      await init();
      await requestPermissions();
    }
    if (!reminder.isActive) return;
    final id = _toNotifId(reminder.id);
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, reminder.scheduledTime.hour, reminder.scheduledTime.minute);
    tz.TZDateTime firstTime = tz.TZDateTime.from(scheduled, tz.local);
    if (firstTime.isBefore(tz.TZDateTime.now(tz.local))) {
      // schedule for next day if time already passed
      firstTime = firstTime.add(const Duration(days: 1));
    }
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Notif] scheduleDaily id=$id at=$firstTime (local tz=${tz.local.name}) comment="${reminder.comment}"');
    }
    try {
      await _plugin.zonedSchedule(
        id,
        _buildDailyTitle(reminder),
        _buildDailyBody(reminder),
        firstTime,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: reminder.id,
      );
      await _persistDaily(reminder); // ensure stored locally for future restore
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Notif] scheduleDaily failed: $e');
      }
    }
  }

  Future<void> cancel(String id) async {
    if (kIsWeb) return;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Notif] cancel id=${_toNotifId(id)}');
    }
    await _plugin.cancel(_toNotifId(id));
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Notif] cancelAll');
    }
    await _plugin.cancelAll();
  }

  Future<void> sync(List<ReminderSetting> reminders) async {
    if (kIsWeb) return;
    final sw = Stopwatch()..start();
    try {
      final active = reminders.where((e) => e.isActive).toList();
      final newIds = active.map((r) => _toNotifId(r.id)).toSet();
      final toCancel = _activeIds.difference(newIds);
      final toAdd = active.where((r) => !_activeIds.contains(_toNotifId(r.id))).toList();
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Notif] sync start: total=${reminders.length} active=${active.length} add=${toAdd.length} cancel=${toCancel.length}');
      }
      // Cancel removed/inactive
      for (final id in toCancel) {
        await _plugin.cancel(_clampToInt32(id));
      }
      // (Re) schedule new ones
      for (final r in toAdd) {
        await scheduleDaily(r);
      }
      _activeIds
        ..clear()
        ..addAll(newIds);
      // Persist the full active list (overwrite) for consistency; scheduleDaily already persisted individually
      await _persistActiveList(active);
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Notif] sync done in ${sw.elapsedMilliseconds}ms (activeIds=${_activeIds.length})');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Notification sync error: $e');
      }
    }
  }

  // Debug helper methods removed per request (no longer scheduling immediate test notifications)

  // ---------------- Persistence helpers ----------------
  static const _prefsKeyDaily = 'notif_daily_list_v1';

  Map<String, dynamic> _reminderToJson(ReminderSetting r) => {
        'id': r.id,
        'comment': r.comment,
        'hour': r.scheduledTime.hour,
        'minute': r.scheduledTime.minute,
        'active': r.isActive,
      };

  Future<void> _persistDaily(ReminderSetting r) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKeyDaily);
      List<dynamic> list = raw != null ? jsonDecode(raw) as List<dynamic> : <dynamic>[];
      // Replace existing by id if present.
      list.removeWhere((e) => e is Map && e['id'] == r.id);
      list.add(_reminderToJson(r));
      await prefs.setString(_prefsKeyDaily, jsonEncode(list));
    } catch (e) {
      if (kDebugMode) { print('[Notif] persistDaily error: $e'); }
    }
  }

  Future<void> _persistActiveList(List<ReminderSetting> active) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = active.map(_reminderToJson).toList();
      await prefs.setString(_prefsKeyDaily, jsonEncode(list));
    } catch (e) {
      if (kDebugMode) { print('[Notif] persistActiveList error: $e'); }
    }
  }

  Future<void> _restorePersistedDailySchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKeyDaily);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        if (item is Map) {
          final active = item['active'] == true;
          if (!active) continue;
          final idStr = item['id']?.toString() ?? '';
          final hour = (item['hour'] as num?)?.toInt();
          final minute = (item['minute'] as num?)?.toInt();
          if (hour == null || minute == null || idStr.isEmpty) continue;
          final comment = item['comment']?.toString() ?? '';
          // Reconstruct a transient ReminderSetting-like object for scheduling.
          final reconstructed = ReminderSetting(
            id: idStr,
            comment: comment,
            scheduledTime: DateTime(0, 1, 1, hour, minute),
            isActive: true,
          );
          // Avoid double scheduling if sync already covered it.
          final intId = _toNotifId(idStr);
          if (_activeIds.contains(intId)) continue;
          if (kDebugMode) { print('[Notif] restore persisted daily id=$idStr hour=$hour minute=$minute'); }
          await scheduleDaily(reconstructed);
        }
      }
    } catch (e) {
      if (kDebugMode) { print('[Notif] restorePersistedDailySchedules error: $e'); }
    }
  }

  // Allow updating localized strings (must be called from UI context when locale changes)
  void updateLocalizedStrings(dynamic loc) {
    try {
      // Expecting an AppLocalizations instance; kept dynamic to avoid direct dependency import here.
      final title = loc.notificationDrinkTitle as String?;
      if (title != null && title.trim().isNotEmpty) {
        _drinkTitle = title.trim();
      }
    } catch (_) {
      // ignore localization update errors silently
    }
  }
}
