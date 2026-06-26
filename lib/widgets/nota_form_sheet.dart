import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';

void mostrarFormularioNota(
  BuildContext context, {
  required Future<void> Function() onGuardado,
}) {
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final tipoPersonalizadoController = TextEditingController();
  String tipoSeleccionado = 'peli';
  bool escribiendoTipoNuevo = false;
  List<String> tiposPersonalizados = [];
  Color colorTipoPersonalizado = const Color(0xFF4A4A4A);

  // Tipos fijos que siempre aparecen
  const tiposFijos = [
    {'valor': 'peli', 'label': '🎬 Peli'},
    {'valor': 'serie', 'label': '📺 Serie'},
    {'valor': 'idea_cita', 'label': '💝 Cita'},
  ];

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
          // Carga los tipos personalizados la primera vez
          if (tiposPersonalizados.isEmpty) {
            ApiService.listarTipos().then((datos) {
              setModalState(() {
                tiposPersonalizados = datos
                    .map((t) => t['nombre'] as String)
                    .toList();
              });
            }).catchError((_) {
              // Si falla la carga de tipos, se continúa solo con los fijos
            });
          }

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
                    'Nueva nota',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kColorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Selector de tipo
                  const Text(
                    'Tipo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kColorTextoSecundario,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Chips: fijos + personalizados + botón nuevo
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Tipos fijos
                      ...tiposFijos.map(
                        (tipo) => _ChipTipo(
                          label: tipo['label']!,
                          seleccionado: tipoSeleccionado == tipo['valor'],
                          onTap: () => setModalState(() {
                            tipoSeleccionado = tipo['valor']!;
                            escribiendoTipoNuevo = false;
                          }),
                        ),
                      ),

                      // Tipos personalizados guardados
                      ...tiposPersonalizados.map(
                        (tipo) => _ChipTipo(
                          label: tipo,
                          seleccionado: tipoSeleccionado == tipo,
                          onTap: () => setModalState(() {
                            tipoSeleccionado = tipo;
                            escribiendoTipoNuevo = false;
                          }),
                        ),
                      ),

                      // Botón para escribir tipo nuevo
                      _ChipTipo(
                        label: '➕ Nuevo tipo',
                        seleccionado: escribiendoTipoNuevo,
                        onTap: () => setModalState(
                          () => escribiendoTipoNuevo = !escribiendoTipoNuevo,
                        ),
                      ),
                    ],
                  ),

                  // Campo de texto para tipo personalizado
                  if (escribiendoTipoNuevo) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: tipoPersonalizadoController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Nombre del tipo (ej. Salidas parques)',
                        filled: true,
                        fillColor: kColorPanel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (valor) =>
                          setModalState(() => tipoSeleccionado = valor.trim()),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Color de la categoría',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kColorTextoSecundario,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kColoresEvento.map((color) {
                        final seleccionado = colorTipoPersonalizado == color;
                        return GestureDetector(
                          onTap: () => setModalState(
                            () => colorTipoPersonalizado = color,
                          ),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: seleccionado
                                  ? Border.all(
                                      color: kColorTextoOscuro,
                                      width: 3,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Título de la nota
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
                  const SizedBox(height: 12),

                  // Descripción
                  TextField(
                    controller: descripcionController,
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
                        if (tipoSeleccionado.isEmpty) return;

                        try {
                          // Si es un tipo personalizado nuevo, lo guardamos
                          final tiposFijosValores = [
                            'peli',
                            'serie',
                            'idea_cita',
                          ];
                          if (!tiposFijosValores.contains(tipoSeleccionado) &&
                              tipoSeleccionado.isNotEmpty) {
                            await ApiService.crearTipo(
                              nombre: tipoSeleccionado,
                              color: colorAHex(colorTipoPersonalizado),
                            );
                          }
                          await ApiService.crearNota(
                            titulo: tituloController.text.trim(),
                            tipo: tipoSeleccionado,
                            descripcion: descripcionController.text.trim().isEmpty
                                ? null
                                : descripcionController.text.trim(),
                          );
                          await onGuardado();
                          if (context.mounted) Navigator.pop(context);
                        } catch (_) {
                          // Error de red — el sheet se queda abierto
                        }
                      },
                      child: const Text(
                        'Guardar nota',
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

class _ChipTipo extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipTipo({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? kColorPrimario : kColorPanel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: seleccionado ? Colors.white : kColorTextoOscuro,
          ),
        ),
      ),
    );
  }
}
