import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacionService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    tz.initializeTimeZones();
    // No necesitamos setLocalLocation porque convertimos siempre a UTC antes de programar.

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Solicitar permiso de notificaciones (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Programa un recordatorio para un evento.
  /// Solo se programa si la fecha/hora resultante es en el futuro.
  static Future<void> programarRecordatorio({
    required int idEvento,
    required String tituloEvento,
    required DateTime fechaEvento,
    required TimeOfDay horaEvento,
    required int minutosAntes,
  }) async {
    final DateTime fechaHoraEvento = DateTime(
      fechaEvento.year,
      fechaEvento.month,
      fechaEvento.day,
      horaEvento.hour,
      horaEvento.minute,
    );
    final DateTime fechaHoraNotificacion =
        fechaHoraEvento.subtract(Duration(minutes: minutosAntes));

    if (fechaHoraNotificacion.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      idEvento,
      'Recordatorio: $tituloEvento',
      minutosAntes < 60
          ? 'El evento empieza en $minutosAntes minutos'
          : 'El evento empieza en ${minutosAntes ~/ 60}h',
      tz.TZDateTime.from(fechaHoraNotificacion.toUtc(), tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorios_eventos',
          'Recordatorios de eventos',
          channelDescription:
              'Notificaciones de recordatorio para eventos del calendario',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela el recordatorio de un evento por su id.
  static Future<void> cancelarRecordatorio(int idEvento) async {
    await _plugin.cancel(idEvento);
  }
}
