import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class NotaCardCompletada extends StatelessWidget {
  final Map<String, dynamic> nota;
  final VoidCallback onTap;
  final VoidCallback onDescompletar;

  const NotaCardCompletada({
    super.key,
    required this.nota,
    required this.onTap,
    required this.onDescompletar,
  });

  @override
  Widget build(BuildContext context) {
    final tipo = nota['tipo'] as String? ?? 'otro';
    final color = _colorPorTipo(tipo);
    final puntuacion = nota['puntuacion'] != null
        ? int.tryParse(nota['puntuacion'].toString())
        : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kColorPanel.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
          boxShadow: kSombraTarjeta,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Círculo marcado + título tachado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDescompletar,
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    nota['titulo'] as String? ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: kColorTextoSecundario,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: kColorTextoSecundario,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Puntuación
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 30),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 13, color: Color(0xFFE8A83E)),
                  const SizedBox(width: 3),
                  Text(
                    puntuacion != null ? '$puntuacion/10' : 'sin nota',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: puntuacion != null
                          ? const Color(0xFFE8A83E)
                          : kColorTextoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _colorPorTipo(String tipo) {
  switch (tipo) {
    case 'peli':
      return const Color(0xFF7B3FA0);
    case 'serie':
      return const Color(0xFF5BA8C4);
    case 'idea_cita':
      return const Color(0xFFE86B8A);
    default:
      return const Color(0xFF4A4A4A);
  }
}