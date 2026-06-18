import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/calendar_screen.dart';
import 'screens/nota_screen.dart';
import 'utils/color_utils.dart';
import 'screens/proximos_screen.dart';
import 'screens/ajustes_screen.dart';
import 'services/dispositivo_service.dart';
import 'services/sesion_service.dart';
import 'screens/planner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es_ES', null);
  await DispositivoService.inicializar(nombre: 'Usuario');

  // Comprobamos si este dispositivo es el de Sandra
  final esSandra = await SesionService.esDispositivoDeSandra();

  runApp(MyApp(esSandra: esSandra));
}

class MyApp extends StatelessWidget {
  final bool esSandra;
  const MyApp({super.key, required this.esSandra});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar to Weiguel',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kColorPrimario),
      ),
      home: MainScreen(esSandra: esSandra),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool esSandra;
  const MainScreen({super.key, required this.esSandra});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceActivo = 0;

  @override
  Widget build(BuildContext context) {
    // Pantallas según el dispositivo
    final pantallas = [
      const CalendarScreen(),
      const ProximosScreen(),
      const NotesScreen(),
      if (widget.esSandra) const PlannerScreen(), // solo para Sandra
      const AjustesScreen(),
    ];

    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month),
        label: 'Calendario',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.hourglass_top),
        label: 'Próximos',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.sticky_note_2_outlined),
        label: 'Notas',
      ),
      if (widget.esSandra)
        const BottomNavigationBarItem(
          icon: Icon(Icons.view_week_outlined),
          label: 'Planner',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Ajustes',
      ),
    ];

    return Scaffold(
      body: pantallas[_indiceActivo],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActivo,
        onTap: (indice) => setState(() => _indiceActivo = indice),
        backgroundColor: kColorFondo,
        selectedItemColor: kColorPrimario,
        unselectedItemColor: kColorTextoSecundario,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
