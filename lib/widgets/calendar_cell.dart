import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

/// Celda personalizada del calendario.
/// Muestra el número del día y, si hay eventos, un fragmento del título del primero.
class CalendarCell extends StatelessWidget {
  final DateTime dia;
  final List<dynamic> eventos;
  final bool pasado;
  final bool esHoy;
  final bool seleccionado;

  const CalendarCell({
    super.key,
    required this.dia,
    required this.eventos,
    required this.pasado,
    required this.esHoy,
    required this.seleccionado,
  });

  @override
  Widget build(BuildContext context) {
    String? fragmento;
    Color? colorEvento;

    if (eventos.isNotEmpty) {
      final titulo = eventos[0]['titulo'] as String? ?? '';
      fragmento = titulo.length > 8 ? '${titulo.substring(0, 8)}…' : titulo;
      colorEvento = parsearColor(eventos[0]['color'] as String?);
    }

    return Container(
      margin: const EdgeInsets.all(1),
      width: 45,
      height: 80,
      decoration: BoxDecoration(
        color: esHoy ? kColorTextoOscuro : Colors.transparent,
        border: seleccionado
            ? Border.all(color: kColorPrimario, width: 2)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Text(
            '${dia.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: esHoy
                  ? Colors.white
                  : pasado
                      ? kColorPasado
                      : kColorTextoOscuro,
              decoration: pasado ? TextDecoration.lineThrough : null,
              decorationColor: kColorPasado,
            ),
          ),
          if (fragmento != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: colorEvento ?? kColorPrimario,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  fragmento,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (eventos.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '+${eventos.length - 1}',
                style: const TextStyle(
                  fontSize: 8,
                  color: kColorPrimario,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
