import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS and macOS initialization settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Create a notification channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'aegis_status_channel', // id
      'System Status', // name
      description: 'Persistent notification for Aegis Track system status.',
      importance: Importance.low, // low so it doesn't pop up over screen constantly
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permissions for Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> updateStatusNotification(bool isOnline) async {
    final String statusText = isOnline ? 'System is Online' : 'System is Offline';
    
    // We use importance low/default to keep it in the drawer but not pop up heads-up notifications repeatedly
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'aegis_status_channel',
      'System Status',
      channelDescription: 'Persistent notification for Aegis Track system status.',
      importance: Importance.low,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      showWhen: false, // Don't show timestamp to keep it clean
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id: 888, // Fixed ID so it updates the same notification instead of creating new ones
      title: 'Aegis Track',
      body: statusText,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
