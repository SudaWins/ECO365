import 'package:flutter/material.dart';
import 'Services/notifi_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'home_page.dart';
//teste de commit 1
void main() {
  /* WidgetsFlutterBinding.ensureInitialized(); */
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  NotificationService().initNotification();
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //primarySwatch: const Color.blue,
        colorSchemeSeed: Color(0x28c667),
        brightness: Brightness.dark,
        useMaterial3: true
      ),
      home: const MyHomePage(title: 'ECO 365'),
    );
  }
}
