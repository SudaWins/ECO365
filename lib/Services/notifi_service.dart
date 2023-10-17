import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart'; //A shared_preferences é uma biblioteca que permite salvar dados persistentes de forma simples no dispositivo. Com ela, você pode armazenar e recuperar os valores de daysCount para cada notificação individualmente.
import 'package:flutter/cupertino.dart';

class Weekdays {
  bool? monday = false;
  bool? tuesday = false;
  bool? wednesday = false;
  bool? thursday = false;
  bool? friday = false;
  bool? saturday = false;
  bool? sunday = false;
}

class NotificationService {
  String title;
  String body;
  Weekdays weekdays = Weekdays();

  //NotificationService();
  NotificationService(
      {required this.title, required this.body, required this.weekdays});

  //função para trocar titulo  e outra pra torcar o body com um simples setter para isso

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('flutter_logo');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});

    tz.initializeTimeZones();
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance
                .max), //nível de importancia de uma notificação, min nem apita no cel do user, max aparece no topo como mais recente.
        iOS: DarwinNotificationDetails());
  }

  // Função auxiliar para calcular a data e hora da próxima notificação
  Future<tz.TZDateTime> _nextNotificationDateTime(int id) async {
    final location = tz.getLocation('America/Sao_Paulo');

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final int storedDaysCount = preferences.getInt('daysCount_$id') ??
        0; //?? operador coalescência nula (verifica se o valor a esquerda dele é nulo)
    final int daysCount = storedDaysCount > 0 ? storedDaysCount : 0;

    // Salvar o valor de daysCount no SharedPreferences
    await preferences.setInt('daysCount_$id', daysCount);

    if (daysCount > 0) {
      // Se houver um valor de daysCount maior que zero, adicionar esse número de dias à data e hora atual
      return tz.TZDateTime.now(location).add(Duration(days: daysCount));
    } else {
      // Caso contrário, adicionar 5 segundos à data e hora atual
      return tz.TZDateTime.now(location).add(const Duration(seconds: 20));
    }
  }

  Future<void> _scheduleNextNotification(
    int id,
    String title,
    String body,
    NotificationDetails platformChannelSpecifics,
    DateTime nextNotificationTime,
    /* DateTime savedNotificationTime */
  ) async {
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(nextNotificationTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'notification',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Função para lidar com as ações da notificação
  Future<void> handleNotificationAction(String payload, int id, String title,
      String body, NotificationDetails platformChannelSpecifics) async {
    if (payload == 'vou_fazer') {
      // Ação "Vou Fazer" selecionada
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      //final int storedDaysCount = preferences.getInt('daysCount_$id') ?? 0;
      await preferences.setInt('daysCount_$id', 0); // Zerar a contagem de dias

      final DateTime nextNotificationTime =
          DateTime.now().add(const Duration(seconds: 30));
      await _scheduleNextNotification(id, title, body, platformChannelSpecifics,
          nextNotificationTime /* , savedNotificationTime */);
    } else if (payload == 'ja_fiz') {
      // Ação "Já Fiz" selecionada
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final int storedDaysCount = preferences.getInt('daysCount_$id') ?? 0;
      final int daysCount = storedDaysCount + 1; // Adicionar um dia à contagem

      await preferences.setInt('daysCount_$id', daysCount);

      // Agendar a próxima notificação usando a função auxiliar _nextNotificationDateTime
      final DateTime nextNotificationTime = await _nextNotificationDateTime(id);
      await _scheduleNextNotification(id, title, body, platformChannelSpecifics,
          nextNotificationTime /* , savedNotificationTime */);
    }
  }

  Future<void> showNotification(NotificationService notificationService) async {
    const int id = 0; // ID único da notificação
    String title = notificationService.title;
    String body = notificationService.body;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channelId', // ID único do canal
      'channelName', // Nome do canal
      importance: Importance.defaultImportance,
      playSound: true,
      styleInformation: BigTextStyleInformation(
          ''), // Define um estilo de texto para a notificação
      actions: [
        // Botão "Vou Fazer"
        AndroidNotificationAction(
          'vou_fazer', // ID único para o botão
          'Vou Fazer', // Texto do botão
        ),
        // Botão "Já Fiz"
        AndroidNotificationAction(
          'ja_fiz', // ID único para o botão
          'Já Fiz', // Texto do botão
        ),
      ],
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Mostrar a notificação imediata
    await notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );

    // Agendar a próxima notificação usando a função auxiliar _nextNotificationDateTime
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      await _nextNotificationDateTime(
          id), // Calcula a data e hora da próxima notificação
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload:
          'notification', // Adicione um payload para identificar a notificação
    );
  }
}
