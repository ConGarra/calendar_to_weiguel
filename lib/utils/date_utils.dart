import 'package:flutter/material.dart';

/// Formatea un [DateTime] a "YYYY-MM-DD" para la base de datos.
String formatearFecha(DateTime fecha) {
  return '${fecha.year.toString().padLeft(4, '0')}-'
      '${fecha.month.toString().padLeft(2, '0')}-'
      '${fecha.day.toString().padLeft(2, '0')}';
}

/// Formatea un [TimeOfDay] a "HH:MM:00" para la base de datos.
/// Devuelve null si [hora] es null.
String? formatearHora(TimeOfDay? hora) {
  if (hora == null) return null;
  return '${hora.hour.toString().padLeft(2, '0')}:'
      '${hora.minute.toString().padLeft(2, '0')}:00';
}
