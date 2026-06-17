import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Paleta global de la app
// ---------------------------------------------------------------------------

/// Fondo principal (crema).
const kColorFondo = Color(0xFFF7F3EE);

/// Fondo de paneles, inputs y lista de eventos (morado suave).
const kColorPanel = Color(0xFFEDE8F5);

/// Color primario de la app (azul/morado).
const kColorPrimario = Color(0xFF6B7FD4);

/// Texto principal oscuro.
const kColorTextoOscuro = Color(0xFF1C2035);

/// Texto secundario / subtítulos.
const kColorTextoSecundario = Color(0xFF6B6F8A);

/// Color de días pasados en el calendario.
const kColorPasado = Color(0xFFB0ADC5);

/// Color de acciones destructivas (eliminar).
const kColorEliminar = Color(0xFFD44F4F);

// ---------------------------------------------------------------------------
/// Colores disponibles para los eventos.
const List<Color> kColoresEvento = [
  Color(0xFF6B7FD4),
  Color(0xFF9B8EC4),
  Color(0xFF5BA8C4),
  Color(0xFF7EC8A0),
  Color(0xFFC47EAA),
  Color(0xFF3B4A7A),
  Color(0xFFD44F4F),
  Color(0xFF7B3FA0),
  Color(0xFFE8A83E),
  Color(0xFF4CAF82),
  Color(0xFFE86B8A),
  Color(0xFF4A4A4A),
];

/// Convierte un string hex ("#RRGGBB") a [Color].
/// Devuelve el color por defecto si el valor es nulo o inválido.
Color parsearColor(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF6B7FD4);
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  } catch (_) {
    return const Color(0xFF6B7FD4);
  }
}

/// Convierte un [Color] a string hex "#RRGGBB".
String colorAHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

/// Devuelve el color asociado a un tipo de nota.
/// Para tipos personalizados acepta un color hex opcional.
Color colorPorTipo(String tipo, {String? colorHex}) {
  switch (tipo) {
    case 'peli':
      return const Color(0xFF7B3FA0);
    case 'serie':
      return const Color(0xFF5BA8C4);
    case 'idea_cita':
      return const Color(0xFFE86B8A);
    default:
      return parsearColor(colorHex);
  }
}