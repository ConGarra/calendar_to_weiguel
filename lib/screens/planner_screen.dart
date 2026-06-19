import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart' as date_utils;
import 'dart:convert';

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
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    // Calculamos el lunes de la semana actual
    final hoy = DateTime.now();
    _semanaInicio = hoy.subtract(Duration(days: hoy.weekday - 1));
    _semanaInicio = DateTime(
      _semanaInicio.year,
      _semanaInicio.month,
      _semanaInicio.day,
    );
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
          _contenidoDias = dias.map((k, v) => MapEntry(k, v as String? ?? ''));
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
      _semanaInicio = _semanaInicio.add(Duration(days: 7 * direccion));
    });
    _cargarSemana();
  }

  // Formatea el rango de la semana para el header: "16 - 22 jun"
  String _labelSemana() {
    final fin = _semanaInicio.add(const Duration(days: 6));
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final mes = meses[fin.month - 1];
    return '${_semanaInicio.day} – ${fin.day} $mes';
  }

  // Abre el editor de un día
  void _editarDia(DateTime fecha, String contenidoActual) {
    final fechaStr = date_utils.formatearFecha(fecha);
    final nombreDia = _nombresDias[fecha.weekday - 1];
    final items = List<Map<String, dynamic>>.from(
      _parsearItems(contenidoActual).map((e) => Map<String, dynamic>.from(e)),
    );
    final nuevaLineaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kColorFondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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

              // Lista de ítems existentes
              if (items.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final hecho = items[index]['h'] as bool? ?? false;
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setModalState(() => items[index]['h'] = !hecho),
                            child: Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hecho
                                    ? kColorPrimario
                                    : Colors.transparent,
                                border: Border.all(
                                  color: kColorPrimario,
                                  width: 2,
                                ),
                              ),
                              child: hecho
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              items[index]['t'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: hecho
                                    ? kColorTextoSecundario
                                    : kColorTextoOscuro,
                                decoration: hecho
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: kColorTextoSecundario,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setModalState(() => items.removeAt(index)),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline,
                                color: kColorEliminar,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),

              // Campo para añadir nueva línea
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nuevaLineaController,
                      decoration: InputDecoration(
                        hintText: 'Añadir línea...',
                        filled: true,
                        fillColor: kColorPanel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (valor) {
                        if (valor.trim().isNotEmpty) {
                          setModalState(() {
                            items.add({'t': valor.trim(), 'h': false});
                            nuevaLineaController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final valor = nuevaLineaController.text.trim();
                      if (valor.isNotEmpty) {
                        setModalState(() {
                          items.add({'t': valor, 'h': false});
                          nuevaLineaController.clear();
                        });
                      }
                    },
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

              const SizedBox(height: 16),

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
                    final nuevoContenido = _serializarItems(items);
                    await ApiService.guardarDiaPlanner(
                      fecha: fechaStr,
                      contenido: nuevoContenido,
                    );
                    setState(() => _contenidoDias[fechaStr] = nuevoContenido);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
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

  // Convierte el contenido JSON a una lista de ítems.
  // Si el contenido no es JSON válido (texto antiguo), lo trata como líneas sueltas.
  List<Map<String, dynamic>> _parsearItems(String contenido) {
    if (contenido.isEmpty) return [];
    try {
      final lista = json.decode(contenido) as List<dynamic>;
      return lista.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return contenido
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) => {'t': l, 'h': false})
          .toList();
    }
  }

  // Convierte la lista de ítems de vuelta a JSON para guardar en BD.
  String _serializarItems(List<Map<String, dynamic>> items) {
    return json.encode(items);
  }

  // Toca una línea en la vista del día → la tacha/destacha y guarda automáticamente.
  Future<void> _toggleItemDia(String fechaStr, int index) async {
    final items = _parsearItems(_contenidoDias[fechaStr] ?? '');
    if (index >= items.length) return;
    items[index]['h'] = !(items[index]['h'] as bool? ?? false);
    final nuevoContenido = _serializarItems(items);
    await ApiService.guardarDiaPlanner(
      fecha: fechaStr,
      contenido: nuevoContenido,
    );
    setState(() => _contenidoDias[fechaStr] = nuevoContenido);
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
          : Container(
              decoration: const BoxDecoration(gradient: kGradienteFondo),
              child: ListView(
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
        final items = _parsearItems(contenido);
        final esHoy = isSameDayAs(fecha, DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: esHoy ? kColorPrimario.withValues(alpha: 0.1) : kColorTarjeta,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: esHoy ? kColorPrimario : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: esHoy ? null : kSombraTarjeta,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              // Ítems del día — tap en línea = tachar/destachar
              Expanded(
                child: items.isEmpty
                    ? GestureDetector(
                        onTap: () => _editarDia(fecha, contenido),
                        child: Text(
                          'Toca para añadir...',
                          style: TextStyle(
                            fontSize: 15,
                            color: kColorTextoSecundario.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          final hecho = item['h'] as bool? ?? false;
                          return GestureDetector(
                            onTap: () => _toggleItemDia(fechaStr, i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                item['t'] as String? ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: hecho
                                      ? kColorTextoSecundario
                                      : kColorTextoOscuro,
                                  decoration: hecho
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: kColorTextoSecundario,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              // Lápiz — abre el editor para añadir/borrar líneas
              GestureDetector(
                onTap: () => _editarDia(fecha, contenido),
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: kColorTextoSecundario,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildToDoList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kColorTarjeta,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kSombraTarjeta,
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
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                    onTap: () => _toggleTarea(Map<String, dynamic>.from(tarea)),
                    child: Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completado ? kColorPrimario : Colors.transparent,
                        border: Border.all(color: kColorPrimario, width: 2),
                      ),
                      child: completado
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tarea['titulo'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 16,
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
                    onTap: () =>
                        _borrarTarea(int.parse(tarea['id'].toString())),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        color: kColorEliminar,
                        size: 18,
                      ),
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
