import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ratchasima/pages/disaster/korat_disaster_alert_page.dart';
import 'package:ratchasima/pages/notification/notification_list.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class KoratNotificationService {
  KoratNotificationService._();

  static final KoratNotificationService instance = KoratNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    await _createAndroidNotificationChannels();
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _createAndroidNotificationChannels() async {
    const updatesChannel = AndroidNotificationChannel(
      'korat_connect_updates',
      'Korat Connect',
      description: 'ข่าวสารและการอัปเดตจาก Korat Connect',
      importance: Importance.high,
    );

    const activitiesChannel = AndroidNotificationChannel(
      'korat_connect_activities',
      'กิจกรรม Korat Connect',
      description: 'แจ้งเตือนกิจกรรมและบริการสาธารณะในจังหวัด',
      importance: Importance.high,
    );

    const disasterChannel = AndroidNotificationChannel(
      'korat_disaster_alerts',
      'แจ้งเตือนภัยพิบัติฉุกเฉินโคราช',
      description: 'แจ้งเตือนระดับน้ำลำตะคอง สภาพอากาศ และประกาศฉุกเฉินจังหวัดนครราชสีมา',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(updatesChannel);
    await androidImplementation?.createNotificationChannel(activitiesChannel);
    await androidImplementation?.createNotificationChannel(disasterChannel);
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String payload = 'notifications',
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'korat_connect_updates',
        'Korat Connect',
        channelDescription: 'ข่าวสารและการอัปเดตจาก Korat Connect',
        importance: Importance.high,
        priority: Priority.high,
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> scheduleActivityReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String payload = 'activity_reminder',
  }) async {
    final fallbackDate = DateTime.now().add(const Duration(seconds: 5));
    final safeDate =
        scheduledDate.isAfter(DateTime.now()) ? scheduledDate : fallbackDate;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'korat_connect_activities',
        'กิจกรรม Korat Connect',
        channelDescription: 'แจ้งเตือนกิจกรรมและบริการสาธารณะในจังหวัด',
        importance: Importance.high,
        priority: Priority.high,
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(safeDate, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> showDisasterAlert({
    required int id,
    required String title,
    required String body,
    String payload = 'disaster_alert',
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'korat_disaster_alerts',
        'แจ้งเตือนภัยพิบัติฉุกเฉินโคราช',
        channelDescription: 'แจ้งเตือนระดับน้ำลำตะคอง สภาพอากาศ และประกาศฉุกเฉินจังหวัดนครราชสีมา',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == 'disaster_alert') {
      appNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const KoratDisasterAlertPage(),
        ),
      );
    } else if (response.payload != null) {
      appNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const NotificationList(title: 'แจ้งเตือน'),
        ),
      );
    }
  }
}
