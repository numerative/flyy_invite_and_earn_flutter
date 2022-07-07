import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:flyy_invite_earn_flutter/setup_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  initFCM();
  listenFCM();
  requestNotificationPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flyy Invite & Earn Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SetupPage(),
    );
  }
}


void initFCM() async {
  final token = await FirebaseMessaging.instance.getToken();
  FlyyFlutterPlugin.sendFCMTokenToServer(token!);
}

void requestNotificationPermission() async {
  if (Platform.isIOS) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
}

void listenFCM() {
  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    if (Platform.isAndroid) {
      if (remoteMessage != null &&
          remoteMessage.data != null &&
          remoteMessage.data.containsKey("notification_source") &&
          remoteMessage.data["notification_source"] != null &&
          remoteMessage.data["notification_source"] == "flyy_sdk") {
        FlyyFlutterPlugin.handleNotification(remoteMessage.data);
      }
    } else if (Platform.isIOS) {
      if (remoteMessage.data.containsKey("notification_source") &&
          remoteMessage.data["notification_source"] != null &&
          remoteMessage.data["notification_source"] == "flyy_sdk") {
        FlyyFlutterPlugin.handleForegroundNotification(remoteMessage.data);
      }
    }
  }).onError((error) {
    print(error);
  });
}

/// It must be a top-level function (e.g. not a class method which requires initialization).
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage) async {
  if (remoteMessage.data.containsKey("notification_source") &&
      remoteMessage.data["notification_source"] != null &&
      remoteMessage.data["notification_source"] == "flyy_sdk") {
    FlyyFlutterPlugin.handleBackgroundNotification(remoteMessage.data);
  }
}
