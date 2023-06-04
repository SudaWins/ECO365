import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';//A shared_preferences é uma biblioteca que permite salvar dados persistentes de forma simples no dispositivo. Com ela, você pode armazenar e recuperar os valores de daysCount para cada notificação individualmente.
import 'package:flutter/cupertino.dart';



class NotificationService {
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
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

/*   Future showNotification(

      {int id = 0,
      String?
      title,
      String? body,
      String? payLoad}
      ) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  } */
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Função auxiliar para calcular a data e hora da próxima notificação
  Future<tz.TZDateTime> _nextNotificationDateTime(int id) async {
    final location = tz.getLocation('America/Sao_Paulo');

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final int storedDaysCount = preferences.getInt('daysCount_$id') ?? 0;
    final int daysCount = storedDaysCount > 0 ? storedDaysCount : 0;

    // Salvar o valor de daysCount no SharedPreferences
    await preferences.setInt('daysCount_$id', daysCount);

    if (daysCount > 0) {
      // Se houver um valor de daysCount maior que zero, adicionar esse número de dias à data e hora atual
      return tz.TZDateTime.now(location).add(Duration(days: daysCount));
    } else {
      // Caso contrário, adicionar 5 segundos à data e hora atual
      return tz.TZDateTime.now(location).add(Duration(seconds: 20));
    }
    
  }

  Future<void> _scheduleNextNotification(int id, String title, String body, NotificationDetails platformChannelSpecifics, DateTime nextNotificationTime) async {
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(nextNotificationTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'notification',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Função para lidar com as ações da notificação
  Future<void> handleNotificationAction(String payload, int id, String title, String body, NotificationDetails platformChannelSpecifics) async {
    if (payload == 'vou_fazer') {
      // Ação "Vou Fazer" selecionada
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      final int storedDaysCount = preferences.getInt('daysCount_$id') ?? 0;
      await preferences.setInt('daysCount_$id', 0); // Zerar a contagem de dias

      final DateTime nextNotificationTime = DateTime.now().add(Duration(seconds: 30));
      await _scheduleNextNotification(id, title, body, platformChannelSpecifics, nextNotificationTime);

      // Agendar a próxima notificação para daqui a 5 minutos
      /* await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)), //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! minutes:
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'notification',
        matchDateTimeComponents: DateTimeComponents.time,
      ); */
    } else if (payload == 'ja_fiz') {
      // Ação "Já Fiz" selecionada
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      final int storedDaysCount = preferences.getInt('daysCount_$id') ?? 0;
      final int daysCount = storedDaysCount + 1; // Adicionar um dia à contagem

      await preferences.setInt('daysCount_$id', daysCount);

      // Agendar a próxima notificação para daqui a "daysCount" dias
      /* await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(days: daysCount)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'notification',
        matchDateTimeComponents: DateTimeComponents.time,
      ); */

      // Agendar a próxima notificação usando a função auxiliar _nextNotificationDateTime
      final DateTime nextNotificationTime = await _nextNotificationDateTime(id);
      await _scheduleNextNotification(id, title, body, platformChannelSpecifics, nextNotificationTime);

      // Agendar a próxima notificação usando a função auxiliar _nextNotificationDateTime
      /* await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        await _nextNotificationDateTime(id), // Calcula a data e hora da próxima notificação
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'notification', // Adicione um payload para identificar a notificação
      ); */
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> showNotification() async {
    final int id = 0; // ID único da notificação
    final String title = 'Título da notificação';
    final String body = 'Conteúdo da notificação';

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channelId', // ID único do canal
      'channelName', // Nome do canal
      importance: Importance.defaultImportance,
      playSound: true,
      styleInformation: BigTextStyleInformation(''), // Define um estilo de texto para a notificação
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

    final NotificationDetails platformChannelSpecifics =
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
      await _nextNotificationDateTime(id), // Calcula a data e hora da próxima notificação
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'notification', // Adicione um payload para identificar a notificação
    );
  }
}
