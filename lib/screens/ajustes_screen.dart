import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/dispositivo_service.dart';
import '../utils/color_utils.dart';
import '../services/sesion_service.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  String? _codigo;
  String? _nombre;
  bool _vinculado = false;
  bool _cargando = true;
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final codigo = await DispositivoService.obtenerCodigoVinculo();
    final nombre = await DispositivoService.obtenerNombre();
    final vinculado = await DispositivoService.estaVinculado();
    setState(() {
      _codigo = codigo;
      _nombre = nombre;
      _vinculado = vinculado;
      _cargando = false;
    });
  }

  Future<void> _vincular() async {
    final codigo = _codigoController.text.trim().toUpperCase();
    if (codigo.isEmpty || codigo.length != 6) {
      _mostrarSnackbar('Introduce un código de 6 caracteres');
      return;
    }

    final respuesta = await DispositivoService.vincular(codigo: codigo);
    if (respuesta['exito'] == true) {
      _mostrarSnackbar('¡Vinculado correctamente! 🎉');
      await _cargarDatos();
    } else {
      _mostrarSnackbar(respuesta['error'] as String? ?? 'Error al vincular');
    }
  }

  Future<void> _guardarNombre() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) return;
    await DispositivoService.guardarNombre(nombre);
    await SesionService.actualizarRol(nombre); 
    _mostrarSnackbar('Nombre guardado');
    await _cargarDatos();
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: kColorPrimario,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorFondo,
      appBar: AppBar(
        backgroundColor: kColorFondo,
        elevation: 0,
        title: const Text(
          'Ajustes',
          style: TextStyle(
            color: kColorTextoOscuro,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Sección: Tu código
                _buildSeccion(
                  titulo: 'Tu código de vinculación',
                  descripcion:
                      'Comparte este código con tu pareja para vincular los dispositivos.',
                  child: _codigo == null
                      ? const Text(
                          'No registrado todavía',
                          style: TextStyle(color: kColorTextoSecundario),
                        )
                      : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: kColorPanel,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _codigo!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: kColorPrimario,
                                  letterSpacing: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Botón copiar
                            IconButton(
                              icon: const Icon(Icons.copy,
                                  color: kColorPrimario),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: _codigo!));
                                _mostrarSnackbar('Código copiado');
                              },
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),

                // Sección: Estado de vinculación
                _buildSeccion(
                  titulo: 'Estado',
                  descripcion: _vinculado
                      ? 'Dispositivos vinculados correctamente ✅'
                      : 'Aún no vinculado con otro dispositivo.',
                  child: _vinculado
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _codigoController,
                              maxLength: 6,
                              textCapitalization:
                                  TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: 'Código de tu pareja',
                                filled: true,
                                fillColor: kColorPanel,
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kColorPrimario,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _vincular,
                                child: const Text(
                                  'Vincular dispositivo',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),

                // Sección: Tu nombre
                _buildSeccion(
                  titulo: 'Tu nombre',
                  descripcion:
                      'Así aparecerá en los eventos que crees.',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            hintText: _nombre ?? 'Escribe tu nombre',
                            filled: true,
                            fillColor: kColorPanel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kColorPrimario,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _guardarNombre,
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required String descripcion,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kColorTextoOscuro,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: const TextStyle(
              fontSize: 12,
              color: kColorTextoSecundario,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }
}