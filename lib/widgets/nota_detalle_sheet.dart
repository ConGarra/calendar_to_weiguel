import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';

void mostrarDetalleNota(
  BuildContext context, {
  required Map<String, dynamic> nota,
  required Future<void> Function() onActualizado,
}) {
  final tituloController =
      TextEditingController(text: nota['titulo'] as String? ?? '');
  final descripcionController =
      TextEditingController(text: nota['descripcion'] as String? ?? '');
  String tipoSeleccionado = nota['tipo'] as String? ?? 'otro';
  bool editando = false;
  int puntuacion = nota['puntuacion'] != null
      ? int.tryParse(nota['puntuacion'].toString()) ?? 5
      : 5;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: kColorFondo,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cabecera
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editando ? 'Editar nota' : 'Detalle de nota',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kColorTextoOscuro,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          editando ? Icons.close : Icons.edit,
                          color: kColorPrimario,
                        ),
                        onPressed: () =>
                            setModalState(() => editando = !editando),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Título
                  TextField(
                    controller: tituloController,
                    enabled: editando,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      filled: true,
                      fillColor: kColorPanel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Descripción
                  TextField(
                    controller: descripcionController,
                    enabled: editando,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripción (opcional)',
                      filled: true,
                      fillColor: kColorPanel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Puntuación
                  const Text(
                    'Puntuación',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kColorTextoSecundario,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFE8A83E), size: 20),
                      Expanded(
                        child: Slider(
                          value: puntuacion.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: kColorPrimario,
                          label: '$puntuacion/10',
                          onChanged: editando
                              ? (val) =>
                                  setModalState(() => puntuacion = val.toInt())
                              : null,
                        ),
                      ),
                      Text(
                        '$puntuacion/10',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: kColorTextoOscuro,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botón guardar
                  if (editando)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kColorPrimario,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          if (tituloController.text.trim().isEmpty) return;
                          await ApiService.editarNota(
                            id: int.parse(nota['id'].toString()),
                            titulo: tituloController.text.trim(),
                            tipo: tipoSeleccionado,
                            descripcion:
                                descripcionController.text.trim().isEmpty
                                    ? null
                                    : descripcionController.text.trim(),
                            completado: nota['completado'].toString() == '1' ? 1 : 0,
                            puntuacion: puntuacion,
                          );
                          if (context.mounted) Navigator.pop(context);
                          await onActualizado();
                        },
                        child: const Text(
                          'Guardar cambios',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}