import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';
import '../services/notificacion_service.dart';

/// Muestra el bottom sheet para crear un nuevo evento.
/// [fechaInicial] es el día seleccionado en el calendario.
/// [onGuardado] se ejecuta tras guardar con éxito para refrescar la lista.
void mostrarFormularioEvento(
  BuildContext context, {
  required DateTime fechaInicial,
  required Future<void> Function() onGuardado,
}) {
  final tituloController = TextEditingController();
  DateTime fechaSeleccionada = fechaInicial;
  TimeOfDay? horaSeleccionada;
  int? recordatorioMinutos;
  Color colorSeleccionado = kColorPrimario;

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
                  const Text(
                    'Nuevo evento',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kColorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  TextField(
                    controller: tituloController,
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
                    onTap: () async {
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
                    },
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
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setModalState(() => horaSeleccionada = picked);
                      }
                    },
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
                    onTap: () => _mostrarDialogoRecordatorio(
                      context,
                      onSeleccionado: (valor) =>
                          setModalState(() => recordatorioMinutos = valor),
                    ),
                  ),

                  // Color
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
                  const SizedBox(height: 24),

                  // Botón guardar
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
                        final respuesta = await ApiService.crearEvento(
                          titulo: tituloController.text.trim(),
                          fecha: formatearFecha(fechaSeleccionada),
                          hora: formatearHora(horaSeleccionada),
                          recordatorioMinutos: recordatorioMinutos,
                          color: colorAHex(colorSeleccionado),
                        );
                        // Programar recordatorio si tiene hora y recordatorio
                        if (horaSeleccionada != null &&
                            recordatorioMinutos != null &&
                            respuesta['id'] != null) {
                          await NotificacionService.programarRecordatorio(
                            idEvento: int.parse(respuesta['id'].toString()),
                            tituloEvento: tituloController.text.trim(),
                            fechaEvento: fechaSeleccionada,
                            horaEvento: horaSeleccionada!,
                            minutosAntes: recordatorioMinutos!,
                          );
                        }
                        if (context.mounted) Navigator.pop(context);
                        await onGuardado();
                      },
                      child: const Text(
                        'Guardar evento',
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
// Widgets y helpers privados
// ---------------------------------------------------------------------------

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
