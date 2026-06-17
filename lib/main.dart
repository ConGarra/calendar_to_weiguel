import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/calendar_screen.dart';
import 'screens/nota_screen.dart';
import 'utils/color_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Índice de la pestaña activa: 0 = Calendario, 1 = Notas
  int _indiceActivo = 0;

  // Las dos pantallas — se crean una vez y no se destruyen al cambiar pestaña
  final List<Widget> _pantallas = const [
    CalendarScreen(),
    NotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Muestra la pantalla activa según el índice
      body: _pantallas[_indiceActivo],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActivo,
        onTap: (indice) => setState(() => _indiceActivo = indice),
        backgroundColor: kColorFondo,
        selectedItemColor: kColorPrimario,
        unselectedItemColor: kColorTextoSecundario,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_outlined),
            label: 'Notas',
          ),
        ],
      ),
    );
  }
}