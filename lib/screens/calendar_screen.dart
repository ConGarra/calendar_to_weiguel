import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../widgets/calendar_cell.dart';
import '../widgets/evento_card.dart';
import '../widgets/evento_form_sheet.dart';
import '../widgets/evento_detalle_sheet.dart';
import '../widgets/error_red_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _eventos = [];
  bool _cargando = true;
  bool _errorRed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _cargarEventos();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cargarEventos(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarEventos() async {
    setState(() {
      _errorRed = false;
      _cargando = true;
    });
    try {
      final datos = await ApiService.listarEventos();
      setState(() {
        _eventos = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _errorRed = true;
      });
    }
  }

  List<dynamic> _eventosDelDia(DateTime dia) {
    final fechaStr =
        '${dia.year.toString().padLeft(4, '0')}-'
        '${dia.month.toString().padLeft(2, '0')}-'
        '${dia.day.toString().padLeft(2, '0')}';
    return _eventos.where((ev) => ev['fecha'] == fechaStr).toList();
  }

  bool _esPasado(DateTime dia) {
    final hoy = DateTime.now();
    return dia.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
  }

  @override
  Widget build(BuildContext context) {
    final eventosDelDiaSeleccionado =
        _selectedDay != null ? _eventosDelDia(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: kColorFondo,
      appBar: AppBar(
        backgroundColor: kColorFondo,
        elevation: 0,
        title: const Text(
          'Calendario',
          style: TextStyle(
            color: kColorTextoOscuro,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kColorPrimario,
        foregroundColor: Colors.white,
        onPressed: () => mostrarFormularioEvento(
          context,
          fechaInicial: _selectedDay ?? DateTime.now(),
          onGuardado: _cargarEventos,
        ),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kGradienteFondo),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _errorRed
                ? ErrorRedWidget(onReintentar: _cargarEventos)
                : Column(
                children: [
                  _buildCalendario(),
                  const Divider(height: 1),
                  _buildListaEventos(eventosDelDiaSeleccionado),
                ],
              ),
      ),
    );
  }

  Widget _buildCalendario() {
    return TableCalendar(
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: _focusedDay,
      locale: 'es_ES',
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) =>
          _selectedDay != null && isSameDay(_selectedDay!, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      eventLoader: _eventosDelDia,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) => CalendarCell(
          dia: day,
          eventos: _eventosDelDia(day),
          pasado: _esPasado(day),
          esHoy: false,
          seleccionado: false,
        ),
        todayBuilder: (context, day, _) => CalendarCell(
          dia: day,
          eventos: _eventosDelDia(day),
          pasado: false,
          esHoy: true,
          seleccionado: false,
        ),
        selectedBuilder: (context, day, _) => CalendarCell(
          dia: day,
          eventos: _eventosDelDia(day),
          pasado: _esPasado(day),
          esHoy: false,
          seleccionado: true,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: kColorTextoOscuro,
        ),
      ),
      rowHeight: 64,
      calendarStyle: const CalendarStyle(markersMaxCount: 0),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kColorTextoOscuro,
        ),
        weekendStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kColorTextoOscuro,
        ),
      ),
    );
  }

  Widget _buildListaEventos(List<dynamic> eventos) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: kColorPanel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: eventos.isEmpty
            ? const Center(
                child: Text(
                  'Sin eventos este día',
                  style: TextStyle(color: kColorTextoSecundario),
                ),
              )
            : ListView.builder(
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  final ev = Map<String, dynamic>.from(eventos[index]);
                  return EventoCard(
                    evento: ev,
                    onTap: () => mostrarDetalleEvento(
                      context,
                      evento: ev,
                      onActualizado: _cargarEventos,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
