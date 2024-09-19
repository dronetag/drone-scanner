import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

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
    String body, {
    String channel = 'default',
  }) async {
    tz_data.initializeTimeZones();
    const iosDetail = DarwinNotificationDetails(
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

    await _localNotificationsPlugin.show(id, title, body, noticeDetail);
  }
}
