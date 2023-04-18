import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificationService {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<bool> setup() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);

    return await _localNotificationsPlugin.initialize(initSettings) ?? false;
  }

  void addNotification(
    String title,
    String body,
    int endTime, {
    String channel = 'default',
  }) async {
    tzData.initializeTimeZones();
    final scheduleTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);
    final iosDetail = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
    );

    final androidDetail = AndroidNotificationDetails(
      channel, // channel Id
      channel, // channel Name
    );

    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );
    const id = 0;

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      noticeDetail,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
}
