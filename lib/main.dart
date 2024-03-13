import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:chukstem/routes.dart';
import 'package:chukstem/screens/splash/splash.dart';
import 'package:chukstem/services/push_notification_service.dart';
import 'package:chukstem/strings.dart';
import 'package:chukstem/theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  FirebaseMessaging.onBackgroundMessage(
      _messageHandler
  );
  await PushNotificationService().setupInteractedMessage();
  runApp(MyApp(),
  );
}

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, child) => GetMaterialApp(
          title: Strings.app_name,
      debugShowCheckedModeBanner: false,
      theme: theme(),
      initialRoute: Splash.routeName,
      routes: routes,
      ),);
  }
}
