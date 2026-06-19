import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../widgets/nota_form_sheet.dart';
import '../widgets/nota_detalle_sheet.dart';
import '../widgets/nota_card_pendiente.dart';
import '../widgets/nota_card_completada.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<dynamic> _notas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNotas();
  }

  Future<void> _cargarNotas() async {
    try {
      final datos = await ApiService.listarNotas();
      debugPrint('Notas cargadas: ${datos.length}');
      for (final n in datos) {
        debugPrint(
          '  - ${n['titulo']} completado: ${n['completado']} puntuacion: ${n['puntuacion']}',
        );
      }
      setState(() {
        _notas = datos;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando notas: $e');
      setState(() => _cargando = false);
    }
  }

  Future<void> _toggleCompletar(Map<String, dynamic> nota) async {
    final yaCompletado = nota['completado'].toString() == '1';

    // Si ya está completada, simplemente la desmarcamos
    if (yaCompletado) {
      await ApiService.editarNota(
        id: int.parse(nota['id'].toString()),
        titulo: nota['titulo'] as String,
        tipo: nota['tipo'] as String,
        descripcion: nota['descripcion'] as String?,
        completado: 0,
        puntuacion: nota['puntuacion'] != null
            ? int.tryParse(nota['puntuacion'].toString())
            : null,
      );
      await _cargarNotas();
      return;
    }

    // Si no está completada, preguntamos la puntuación
    int puntuacion = 5;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('¡Completado! ¿Qué puntuación le das?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFE8A83E)),
                      Expanded(
                        child: Slider(
                          value: puntuacion.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: kColorPrimario,
                          label: '$puntuacion/10',
                          onChanged: (val) =>
                              setDialogState(() => puntuacion = val.toInt()),
                        ),
                      ),
                      Text(
                        '$puntuacion/10',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Guardar',
                    style: TextStyle(color: kColorPrimario),
                  ),
                ),
                // Opción de completar sin puntuar
                TextButton(
                  onPressed: () {
                    puntuacion = -1; // señal de "sin puntuación"
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    'Sin puntuación',
                    style: TextStyle(color: kColorTextoSecundario),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmar != true) return;
    debugPrint('Completando con puntuacion: $puntuacion');
    debugPrint('Puntuacion enviada: ${puntuacion == -1 ? null : puntuacion}');
    final respuesta = await ApiService.editarNota(
      id: int.parse(nota['id'].toString()),
      titulo: nota['titulo'] as String,
      tipo: nota['tipo'] as String,
      descripcion: nota['descripcion'] as String?,
      completado: 1,
      puntuacion: puntuacion == -1 ? null : puntuacion,
    );
    debugPrint('Respuesta: $respuesta');
    await _cargarNotas();
  }

  // Agrupa las notas por tipo, separando pendientes de completadas
  Map<String, Map<String, dynamic>> _agrupar(List<dynamic> notas) {
    // Estructura: { 'peli': { 'pendientes': [...], 'completadas': [...], 'color': '#7B3FA0' } }
    final Map<String, Map<String, dynamic>> grupos = {};

    for (final nota in notas) {
      final tipo = nota['tipo'] as String? ?? 'otro';
      final completado = nota['completado'].toString() == '1';

      grupos[tipo] ??= {
        'pendientes': [],
        'completadas': [],
        'color': nota['tipo_color'] as String? ?? '#4A4A4A',
      };

      if (completado) {
        grupos[tipo]!['completadas'].add(nota);
      } else {
        grupos[tipo]!['pendientes'].add(nota);
      }
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _agrupar(_notas);

    return Scaffold(
      backgroundColor: kColorFondo,
      appBar: AppBar(
        backgroundColor: kColorFondo,
        elevation: 0,
        title: const Text(
          'Notas',
          style: TextStyle(
            color: kColorTextoOscuro,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kColorPrimario,
        foregroundColor: Colors.white,
        onPressed: () =>
            mostrarFormularioNota(context, onGuardado: _cargarNotas),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kGradienteFondo),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _notas.isEmpty
            ? const Center(
                child: Text(
                  'Sin notas todavía\nPulsa + para añadir',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kColorTextoSecundario),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                if (grupos['peli'] != null)
                  _buildGrupo(
                    '🎬 Pelis',
                    grupos['peli']!['pendientes'] as List<dynamic>,
                    grupos['peli']!['completadas'] as List<dynamic>,
                    const Color(0xFF7B3FA0),
                  ),
                if (grupos['serie'] != null)
                  _buildGrupo(
                    '📺 Series',
                    grupos['serie']!['pendientes'] as List<dynamic>,
                    grupos['serie']!['completadas'] as List<dynamic>,
                    const Color(0xFF5BA8C4),
                  ),
                if (grupos['idea_cita'] != null)
                  _buildGrupo(
                    '💝 Ideas de cita',
                    grupos['idea_cita']!['pendientes'] as List<dynamic>,
                    grupos['idea_cita']!['completadas'] as List<dynamic>,
                    const Color(0xFFE86B8A),
                  ),
                ...grupos.entries
                    .where(
                      (e) =>
                          e.key != 'peli' &&
                          e.key != 'serie' &&
                          e.key != 'idea_cita',
                    )
                    .map(
                      (e) => _buildGrupo(
                        '📌 ${e.key}',
                        e.value['pendientes'] as List<dynamic>,
                        e.value['completadas'] as List<dynamic>,
                        parsearColor(e.value['color'] as String?),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildGrupo(
    String titulo,
    List<dynamic> pendientes,
    List<dynamic> completadas,
    Color color,
  ) {
    if (pendientes.isEmpty && completadas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // El cuerpo del grupo es blanco tintado, igual que el resto de tarjetas
        color: kColorTarjeta,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kSombraTarjeta,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Franja superior con el color sólido de la categoría
          // — solo ocupa el título, las esquinas superiores van redondeadas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          // Cabeceras de columna
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Pendientes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kColorTextoOscuro,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Completadas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kColorTextoOscuro,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Dos columnas de tarjetas
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna izquierda — pendientes
                  Expanded(
                    child: Column(
                      children: pendientes.isEmpty
                          ? [
                              Container(
                                height: 50,
                                alignment: Alignment.center,
                                child: const Text(
                                  '¡Todo hecho! 🎉',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kColorTextoOscuro,
                                  ),
                                ),
                              ),
                            ]
                          : pendientes.map((nota) {
                              final n = Map<String, dynamic>.from(nota);
                              return NotaCardPendiente(
                                nota: n,
                                onTap: () => mostrarDetalleNota(
                                  context,
                                  nota: n,
                                  onActualizado: _cargarNotas,
                                ),
                                onCompletar: () => _toggleCompletar(n),
                              );
                            }).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Columna derecha — completadas
                  Expanded(
                    child: Column(
                      children: completadas.isEmpty
                          ? [
                              Container(
                                height: 50,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Aún sin completar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kColorTextoOscuro,
                                  ),
                                ),
                              ),
                            ]
                          : completadas.map((nota) {
                              final n = Map<String, dynamic>.from(nota);
                              return NotaCardCompletada(
                                nota: n,
                                onTap: () => mostrarDetalleNota(
                                  context,
                                  nota: n,
                                  onActualizado: _cargarNotas,
                                ),
                                onDescompletar: () => _toggleCompletar(n),
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
