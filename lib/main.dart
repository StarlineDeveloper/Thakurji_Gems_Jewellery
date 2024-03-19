import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:upgrader/upgrader.dart';

import 'Constants/constant.dart';
import 'Functions.dart';
import 'Routes/app_route.dart';
import 'Screens/splash_screen.dart';
import 'Services/notification_service.dart';
import 'notify_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp();
  await NotificationService().enableIOSNotifications();
  await NotificationService().initializePlatformNotifications();
  if (message.notification == null) {
    NotificationService().showLocalNotification(
      body: message.data['body'],
      title: message.data['title'],
      payload: 'Hello',
    );
  }

  debugPrint('Handling a background message ${message.messageId}');
}

void main() async {
  if (Functions.isUrlSecure(Constants.socketUrl)) {
    HttpOverrides.global = MyHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  Platform.isAndroid
      ? await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDOyf8H67hDHyhjA0mpsxG6O-XTXlrjgpM',
          appId: '1:584287632529:android:63cd04f28798f749b0d330',
          messagingSenderId: '584287632529',
          projectId: 'flutter-application-3949f'))
      : await Firebase.initializeApp();
  // await Upgrader.clearSavedSettings();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // Status bar color
        statusBarColor: Colors.transparent,

        // Status bar brightness (optional)
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
    );
    return MultiProvider(
      providers: NotifierProvider.providers,
      child: MaterialApp(
        builder: (context, child) {
          const lowerLimit = 1.0;
          const upperLimit = 1.0;
          final mediaQueryData = MediaQuery.of(context);
          final scale = mediaQueryData.textScaler.scale(10).clamp(lowerLimit, upperLimit);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          );
        },
        title: 'Thakur ji Gems And Jewellery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: AppColor.secondaryColor),
          useMaterial3: false,
          brightness: Brightness.light,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        ),
        home: const SplashScreen(),
        onGenerateRoute: (settings) => AppRoutes().onGeneratedRoutes(settings),
      ),
    );
  }
}
