import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../widgets/evento_card.dart';
import '../widgets/evento_detalle_sheet.dart';

class ProximosScreen extends StatefulWidget {
  const ProximosScreen({super.key});

  @override
  State<ProximosScreen> createState() => _ProximosScreenState();
}

class _ProximosScreenState extends State<ProximosScreen> {
  List<dynamic> _eventos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    try {
      final datos = await ApiService.listarEventos();
      setState(() {
        // Filtramos solo eventos de hoy en adelante, y ordenamos por fecha+hora
        _eventos = _filtrarYOrdenar(datos);
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  List<dynamic> _filtrarYOrdenar(List<dynamic> eventos) {
    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

    // Quedamos solo con eventos cuya fecha sea hoy o futura
    final futuros = eventos.where((ev) {
      final fecha = DateTime.parse(ev['fecha'] as String);
      return !fecha.isBefore(hoySinHora);
    }).toList();

    // Ordenamos por fecha y luego por hora (los sin hora van al final del día)
    futuros.sort((a, b) {
      final fechaA = DateTime.parse(a['fecha'] as String);
      final fechaB = DateTime.parse(b['fecha'] as String);
      final compFecha = fechaA.compareTo(fechaB);
      if (compFecha != 0) return compFecha;

      final horaA = a['hora'] as String?;
      final horaB = b['hora'] as String?;
      if (horaA == null && horaB == null) return 0;
      if (horaA == null) return 1;
      if (horaB == null) return -1;
      return horaA.compareTo(horaB);
    });

    return futuros;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorFondo,
      appBar: AppBar(
        backgroundColor: kColorFondo,
        elevation: 0,
        title: const Text(
          'Próximos',
          style: TextStyle(
            color: kColorTextoOscuro,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _eventos.isEmpty
              ? const Center(
                  child: Text(
                    'No hay eventos próximos',
                    style: TextStyle(color: kColorTextoSecundario),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _eventos.length,
                  itemBuilder: (context, index) {
                    final ev = Map<String, dynamic>.from(_eventos[index]);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostramos la fecha como cabecera antes del primer
                        // evento de cada día distinto
                        if (index == 0 ||
                            _eventos[index]['fecha'] !=
                                _eventos[index - 1]['fecha'])
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8),
                            child: Text(
                              _formatearFechaLegible(ev['fecha'] as String),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kColorTextoSecundario,
                              ),
                            ),
                          ),
                        EventoCard(
                          evento: ev,
                          onTap: () => mostrarDetalleEvento(
                            context,
                            evento: ev,
                            onActualizado: _cargarEventos,
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  String _formatearFechaLegible(String fechaStr) {
    final fecha = DateTime.parse(fechaStr);
    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

    final diferencia = fechaSinHora.difference(hoySinHora).inDays;

    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Mañana';

    const dias = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo'
    ];
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    final nombreDia = dias[fecha.weekday - 1];
    final nombreMes = meses[fecha.month - 1];
    return '$nombreDia ${fecha.day} de $nombreMes';
  }
}