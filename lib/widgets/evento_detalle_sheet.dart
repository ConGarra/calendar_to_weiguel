import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../services/notificacion_service.dart';

/// Muestra el bottom sheet de detalle y edición de un evento existente.
/// [evento] es el map con los datos del evento.
/// [onActualizado] se ejecuta tras guardar o borrar para refrescar la lista.
void mostrarDetalleEvento(
  BuildContext context, {
  required Map<String, dynamic> evento,
  required Future<void> Function() onActualizado,
}) {
  final tituloController = TextEditingController(
    text: evento['titulo'] as String? ?? '',
  );
  DateTime fechaSeleccionada = DateTime.parse(evento['fecha'] as String);
  TimeOfDay? horaSeleccionada;

  if (evento['hora'] != null && evento['hora'] != '') {
    final partes = (evento['hora'] as String).split(':');
    horaSeleccionada = TimeOfDay(
      hour: int.parse(partes[0]),
      minute: int.parse(partes[1]),
    );
  }

  int? recordatorioMinutos = evento['recordatorio_minutos'] != null
      ? int.tryParse(evento['recordatorio_minutos'].toString())
      : null;

  Color colorSeleccionado = parsearColor(evento['color'] as String?);
  bool editando = false;

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
                        editando ? 'Editar evento' : 'Detalle del evento',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kColorTextoOscuro,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              editando ? Icons.close : Icons.edit,
                              color: kColorPrimario,
                            ),
                            onPressed: () =>
                                setModalState(() => editando = !editando),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: kColorEliminar,
                            ),
                            onPressed: () => _confirmarBorrado(
                              context,
                              idEvento: int.parse(evento['id'].toString()),
                              onBorrado: () async {
                                if (context.mounted) Navigator.pop(context);
                                await onActualizado();
                              },
                            ),
                          ),
                        ],
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
                  const SizedBox(height: 14),

                  // Fecha
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today,
                      color: kColorPrimario,
                    ),
                    title: Text(
                      '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Fecha del evento'),
                    onTap: editando
                        ? () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: fechaSeleccionada,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              locale: const Locale('es', 'ES'),
                            );
                            if (picked != null) {
                              setModalState(() => fechaSeleccionada = picked);
                            }
                          }
                        : null,
                  ),

                  // Hora
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.access_time,
                      color: kColorPrimario,
                    ),
                    title: Text(
                      horaSeleccionada != null
                          ? '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}'
                          : 'Sin hora',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Hora del evento (opcional)'),
                    onTap: editando
                        ? () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: horaSeleccionada ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setModalState(() => horaSeleccionada = picked);
                            }
                          }
                        : null,
                  ),

                  // Recordatorio
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.notifications_none,
                      color: kColorPrimario,
                    ),
                    title: Text(
                      recordatorioMinutos != null
                          ? '$recordatorioMinutos min antes'
                          : 'Sin recordatorio',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Recordatorio (opcional)'),
                    onTap: editando
                        ? () => _mostrarDialogoRecordatorio(
                            context,
                            onSeleccionado: (valor) => setModalState(
                              () => recordatorioMinutos = valor,
                            ),
                          )
                        : null,
                  ),

                  // Selector de color (solo en modo edición)
                  if (editando) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Color del evento',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kColorTextoSecundario,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SelectorColor(
                      colorSeleccionado: colorSeleccionado,
                      onColorSeleccionado: (color) =>
                          setModalState(() => colorSeleccionado = color),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Botón guardar (solo en modo edición)
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
                          final idEvento = int.parse(evento['id'].toString());
                          await ApiService.editarEvento(
                            id: idEvento,
                            titulo: tituloController.text.trim(),
                            fecha: formatearFecha(fechaSeleccionada),
                            hora: formatearHora(horaSeleccionada),
                            recordatorioMinutos: recordatorioMinutos,
                            color: colorAHex(colorSeleccionado),
                          );
                          // Cancelar anterior y reprogramar si aplica
                          await NotificacionService.cancelarRecordatorio(
                            idEvento,
                          );
                          if (horaSeleccionada != null &&
                              recordatorioMinutos != null) {
                            await NotificacionService.programarRecordatorio(
                              idEvento: idEvento,
                              tituloEvento: tituloController.text.trim(),
                              fechaEvento: fechaSeleccionada,
                              horaEvento: horaSeleccionada!,
                              minutosAntes: recordatorioMinutos!,
                            );
                          }
                          if (context.mounted) Navigator.pop(context);
                          await onActualizado();
                        },
                        child: const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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

// ---------------------------------------------------------------------------
// Helpers privados
// ---------------------------------------------------------------------------

void _confirmarBorrado(
  BuildContext context, {
  required int idEvento,
  required Future<void> Function() onBorrado,
}) {
  showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Eliminar evento'),
      content: const Text('¿Seguro que quieres eliminar este evento?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Eliminar',
            style: TextStyle(color: kColorEliminar),
          ),
        ),
      ],
    ),
  ).then((confirmar) async {
    if (confirmar == true) {
      await ApiService.borrarEvento(id: idEvento);
      await NotificacionService.cancelarRecordatorio(idEvento);
      await onBorrado();
    }
  });
}

void _mostrarDialogoRecordatorio(
  BuildContext context, {
  required void Function(int?) onSeleccionado,
}) {
  showDialog(
    context: context,
    builder: (_) => SimpleDialog(
      title: const Text('Recordatorio'),
      children: [
        ...[15, 30, 60, 120].map(
          (min) => SimpleDialogOption(
            child: Text(
              min < 60 ? '$min minutos antes' : '${min ~/ 60}h antes',
            ),
            onPressed: () {
              onSeleccionado(min);
              Navigator.pop(context);
            },
          ),
        ),
        SimpleDialogOption(
          child: const Text('Sin recordatorio'),
          onPressed: () {
            onSeleccionado(null);
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

class _SelectorColor extends StatelessWidget {
  final Color colorSeleccionado;
  final void Function(Color) onColorSeleccionado;

  const _SelectorColor({
    required this.colorSeleccionado,
    required this.onColorSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: kColoresEvento.map((color) {
        final seleccionado = colorSeleccionado == color;
        return GestureDetector(
          onTap: () => onColorSeleccionado(color),
          child: Container(
            margin: const EdgeInsets.only(right: 8, bottom: 8),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: seleccionado
                  ? Border.all(color: kColorTextoOscuro, width: 3)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
