import 'package:shared_preferences/shared_preferences.dart';
import 'dispositivo_service.dart';
import 'api_service.dart';

/// Gestiona la sesión actual: quién es el usuario y si está vinculado.
class SesionService {
  static const _keyEsSandra = 'es_sandra';

  /// Comprueba si este dispositivo es el de Sandra.
  /// Lo guarda localmente para no tener que consultar el backend cada vez.
  static Future<bool> esDispositivoDeSandra() async {
    final prefs = await SharedPreferences.getInstance();

    // Si ya lo sabemos, devolvemos el valor guardado
    if (prefs.containsKey(_keyEsSandra)) {
      return prefs.getBool(_keyEsSandra) ?? false;
    }

    // Si no, consultamos el backend
    final dispositivoId = await DispositivoService.obtenerDispositivoId();
    final respuesta =
        await ApiService.obtenerDispositivo(dispositivoId: dispositivoId);

    if (respuesta['exito'] == true) {
      final nombre =
          (respuesta['dispositivo']['nombre'] as String).toLowerCase();
      final esSandra = nombre == 'sandra';
      await prefs.setBool(_keyEsSandra, esSandra);
      return esSandra;
    }

    return false;
  }

  /// Actualiza si este dispositivo es el de Sandra cuando se cambia el nombre.
  static Future<void> actualizarRol(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEsSandra, nombre.toLowerCase() == 'sandra');
  }

  /// Limpia la sesión guardada (útil para pruebas o reset).
  static Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEsSandra);
  }
}