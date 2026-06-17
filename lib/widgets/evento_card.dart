import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

/// Tarjeta que representa un evento en la lista del día seleccionado.
class EventoCard extends StatelessWidget {
  final Map<String, dynamic> evento;
  final VoidCallback onTap;

  const EventoCard({
    super.key,
    required this.evento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = parsearColor(evento['color'] as String?);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: ListTile(
          title: Text(
            evento['titulo'] as String? ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kColorTextoOscuro,
            ),
          ),
          subtitle: Text(
            evento['hora'] != null ? 'Hora: ${evento["hora"]}' : 'Sin hora',
            style: const TextStyle(color: kColorTextoSecundario),
          ),
          trailing: evento['recordatorio_minutos'] != null
              ? Icon(Icons.notifications_active, color: color)
              : null,
        ),
      ),
    );
  }
}
