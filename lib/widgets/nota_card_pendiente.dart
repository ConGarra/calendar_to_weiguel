import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class NotaCardPendiente extends StatelessWidget {
  final Map<String, dynamic> nota;
  final VoidCallback onTap;
  final VoidCallback onCompletar;

  const NotaCardPendiente({
    super.key,
    required this.nota,
    required this.onTap,
    required this.onCompletar,
  });

  @override
  Widget build(BuildContext context) {
    final tipo = nota['tipo'] as String? ?? 'otro';
    final color = colorPorTipo(tipo);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kColorTarjeta,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
          boxShadow: kSombraTarjeta,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Círculo de completar + título
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCompletar,
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: color, width: 2),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    nota['titulo'] as String? ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: kColorTextoOscuro,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Descripción opcional
            if (nota['descripcion'] != null && nota['descripcion'] != '')
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 30),
                child: Text(
                  nota['descripcion'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kColorTextoSecundario,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
