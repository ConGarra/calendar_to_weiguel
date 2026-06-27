import 'package:flutter/material.dart';
import '../services/dispositivo_service.dart';
import '../services/sesion_service.dart';
import '../utils/color_utils.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controladorNombre = TextEditingController();
  final _controladorCodigo = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorCodigo.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    final nombre = _controladorNombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'Por favor escribe tu nombre');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      // Registra el dispositivo con el nombre real que ha escrito el usuario
      await DispositivoService.inicializar(nombre: nombre);
      // Guardamos el nombre localmente de forma explícita, por si el servidor
      // devolviera un valor distinto (ej: el nombre antiguo antes de la actualización)
      await DispositivoService.guardarNombre(nombre);

      // Si el usuario ha introducido un código de pareja, intentamos vincular
      final codigo = _controladorCodigo.text.trim();
      if (codigo.isNotEmpty) {
        final respuesta = await DispositivoService.vincular(codigo: codigo);
        if (respuesta['exito'] != true) {
          setState(() {
            _cargando = false;
            _error = respuesta['mensaje'] as String? ?? 'Código incorrecto';
          });
          return;
        }
      }

      // Detectar rol (Sandra o no) para mostrar el Planner si corresponde
      bool esSandra = false;
      try {
        esSandra = await SesionService.esDispositivoDeSandra();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(esSandra: esSandra)),
      );
    } catch (_) {
      setState(() {
        _cargando = false;
        _error = 'Sin conexión. Comprueba tu red e inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorFondo,
      body: Container(
        decoration: const BoxDecoration(gradient: kGradienteFondo),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text('💑', style: TextStyle(fontSize: 72)),
                ),
                const SizedBox(height: 32),
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: kColorTextoOscuro,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Antes de empezar, dinos cómo te llamas.',
                  style: TextStyle(fontSize: 15, color: kColorTextoSecundario),
                ),
                const SizedBox(height: 40),

                // ── Campo nombre ──────────────────────────────────────
                const Text(
                  'Tu nombre',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kColorTextoOscuro,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controladorNombre,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Ej: Sandra, Weiguel...',
                    hintStyle:
                        const TextStyle(color: kColorTextoSecundario),
                    filled: true,
                    fillColor: kColorTarjeta,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Campo código pareja (opcional) ────────────────────
                const Text(
                  'Código de tu pareja (opcional)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kColorTextoOscuro,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lo encuentras en Ajustes → Tu código.\nPuedes vincularte más tarde desde Ajustes.',
                  style: TextStyle(
                    fontSize: 12,
                    color: kColorTextoSecundario,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controladorCodigo,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Ej: AB12CD',
                    hintStyle:
                        const TextStyle(color: kColorTextoSecundario),
                    filled: true,
                    fillColor: kColorTarjeta,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // ── Botón Continuar ───────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _continuar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColorPrimario,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
