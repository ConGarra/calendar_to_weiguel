import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart' as date_utils;

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  // Lunes de la semana actualmente mostrada
  late DateTime _semanaInicio;
  Map<String, String> _contenidoDias = {};
  List<dynamic> _tareas = [];
  bool _cargando = true;
  final _tareaController = TextEditingController();

  // Nombres de los días en español
  static const _nombresDias = [
    'Lunes', 'Martes', 'Miércoles',
    'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    // Calculamos el lunes de la semana actual
    final hoy = DateTime.now();
    _semanaInicio = hoy.subtract(Duration(days: hoy.weekday - 1));
    _semanaInicio = DateTime(
        _semanaInicio.year, _semanaInicio.month, _semanaInicio.day);
    _cargarSemana();
  }

  Future<void> _cargarSemana() async {
    setState(() => _cargando = true);
    try {
      final respuesta = await ApiService.obtenerSemanaPlanner(
        semanaInicio: date_utils.formatearFecha(_semanaInicio),
      );
      if (respuesta['exito'] == true) {
        final dias = Map<String, dynamic>.from(respuesta['dias'] as Map);
        setState(() {
          _contenidoDias =
              dias.map((k, v) => MapEntry(k, v as String? ?? ''));
          _tareas = respuesta['tareas'] as List<dynamic>;
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  // Navega a la semana anterior o siguiente
  void _cambiarSemana(int direccion) {
    setState(() {
      _semanaInicio =
          _semanaInicio.add(Duration(days: 7 * direccion));
    });
    _cargarSemana();
  }

  // Formatea el rango de la semana para el header: "16 - 22 jun"
  String _labelSemana() {
    final fin = _semanaInicio.add(const Duration(days: 6));
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    final mes = meses[fin.month - 1];
    return '${_semanaInicio.day} – ${fin.day} $mes';
  }

  // Abre el editor de un día
  void _editarDia(DateTime fecha, String contenidoActual) {
    final controller = TextEditingController(text: contenidoActual);
    final fechaStr = date_utils.formatearFecha(fecha);
    final nombreDia = _nombresDias[fecha.weekday - 1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kColorFondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombreDia,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kColorTextoOscuro,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 8,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '¿Qué tienes para este día?',
                filled: true,
                fillColor: kColorPanel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  await ApiService.guardarDiaPlanner(
                    fecha: fechaStr,
                    contenido: controller.text,
                  );
                  setState(() {
                    _contenidoDias[fechaStr] = controller.text;
                  });
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _crearTarea() async {
    final titulo = _tareaController.text.trim();
    if (titulo.isEmpty) return;
    await ApiService.crearTareaPlanner(
      semanaInicio: date_utils.formatearFecha(_semanaInicio),
      titulo: titulo,
    );
    _tareaController.clear();
    await _cargarSemana();
  }

  Future<void> _toggleTarea(Map<String, dynamic> tarea) async {
    final completado = tarea['completado'].toString() == '1' ? 0 : 1;
    await ApiService.toggleTareaPlanner(
      id: int.parse(tarea['id'].toString()),
      completado: completado,
    );
    await _cargarSemana();
  }

  Future<void> _borrarTarea(int id) async {
    await ApiService.borrarTareaPlanner(id: id);
    await _cargarSemana();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorFondo,
      appBar: AppBar(
        backgroundColor: kColorFondo,
        elevation: 0,
        title: const Text(
          'Planner',
          style: TextStyle(
            color: kColorTextoOscuro,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Navegación de semana
                _buildNavegacionSemana(),
                const SizedBox(height: 16),

                // Días de la semana
                _buildDiasSemana(),
                const SizedBox(height: 20),

                // To Do List
                _buildToDoList(),
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildNavegacionSemana() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kColorPanel,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: kColorPrimario),
            onPressed: () => _cambiarSemana(-1),
          ),
          Text(
            _labelSemana(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kColorTextoOscuro,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: kColorPrimario),
            onPressed: () => _cambiarSemana(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDiasSemana() {
    return Column(
      children: List.generate(7, (index) {
        final fecha = _semanaInicio.add(Duration(days: index));
        final fechaStr = date_utils.formatearFecha(fecha);
        final contenido = _contenidoDias[fechaStr] ?? '';
        final esHoy = isSameDayAs(fecha, DateTime.now());

        return GestureDetector(
          onTap: () => _editarDia(fecha, contenido),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: esHoy ? kColorPrimario.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: esHoy ? kColorPrimario : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del día
                SizedBox(
                  width: 36,
                  child: Text(
                    _nombresDias[index].substring(0, 3).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: esHoy ? kColorPrimario : kColorTextoSecundario,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Número del día
                SizedBox(
                  width: 28,
                  child: Text(
                    '${fecha.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: esHoy ? kColorPrimario : kColorTextoOscuro,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Contenido del día
                Expanded(
                  child: contenido.isEmpty
                      ? Text(
                          'Toca para añadir...',
                          style: TextStyle(
                            fontSize: 13,
                            color: kColorTextoSecundario.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Text(
                          contenido,
                          style: const TextStyle(
                            fontSize: 13,
                            color: kColorTextoOscuro,
                          ),
                        ),
                ),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: kColorTextoSecundario,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToDoList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To Do List',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kColorTextoOscuro,
            ),
          ),
          const SizedBox(height: 12),

          // Campo para añadir tarea
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tareaController,
                  decoration: InputDecoration(
                    hintText: 'Nueva tarea...',
                    filled: true,
                    fillColor: kColorPanel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: (_) => _crearTarea(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _crearTarea,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: kColorPrimario,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista de tareas
          if (_tareas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Sin tareas esta semana',
                  style: TextStyle(color: kColorTextoSecundario),
                ),
              ),
            )
          else
            ..._tareas.map((tarea) {
              final completado = tarea['completado'].toString() == '1';
              return Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        _toggleTarea(Map<String, dynamic>.from(tarea)),
                    child: Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completado ? kColorPrimario : Colors.transparent,
                        border: Border.all(
                          color: kColorPrimario,
                          width: 2,
                        ),
                      ),
                      child: completado
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tarea['titulo'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: completado
                            ? kColorTextoSecundario
                            : kColorTextoOscuro,
                        decoration: completado
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: kColorTextoSecundario,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _borrarTarea(
                        int.parse(tarea['id'].toString())),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline,
                          color: kColorEliminar, size: 18),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tareaController.dispose();
    super.dispose();
  }
}

// Helper para comparar dos fechas sin hora
bool isSameDayAs(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}