import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Gestiona el ID único del dispositivo y el estado de vinculación.
/// Usa SharedPreferences para guardar los datos localmente.
class DispositivoService {
  static const _keyDispositivoId = 'dispositivo_id';
  static const _keyNombre = 'nombre';
  static const _keyCodigoVinculo = 'codigo_vinculo';
  static const _keyVinculado = 'vinculado';

  /// Obtiene o genera el ID único del dispositivo.
  /// Lo guarda en SharedPreferences para que persista entre sesiones.
  static Future<String> obtenerDispositivoId() async {
    final prefs = await SharedPreferences.getInstance();

    // Si ya tenemos un ID guardado, lo devolvemos directamente
    String? id = prefs.getString(_keyDispositivoId);
    if (id != null) return id;

    // Si no, lo generamos a partir de la info del dispositivo
    final deviceInfo = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id; // ID único de Android
    } catch (_) {
      // Si falla (ej. en iOS o emulador), usamos un timestamp como fallback
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await prefs.setString(_keyDispositivoId, id);
    return id;
  }

  /// Inicializa el dispositivo: lo registra en el backend si es la primera vez.
  /// Devuelve los datos del dispositivo (nombre, código, vinculado).
  static Future<Map<String, dynamic>> inicializar({
    required String nombre,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dispositivoId = await obtenerDispositivoId();

    // Registramos en el backend (si ya existe, devuelve los datos existentes)
    final respuesta = await ApiService.registrarDispositivo(
      dispositivoId: dispositivoId,
      nombre: nombre,
    );

    if (respuesta['exito'] == true) {
      final dispositivo = respuesta['dispositivo'] as Map<String, dynamic>;

      // Guardamos localmente
      await prefs.setString(_keyNombre, dispositivo['nombre'] as String);
      await prefs.setString(
          _keyCodigoVinculo, dispositivo['codigo_vinculo'] as String);
    }

    return respuesta;
  }

  /// Vincula este dispositivo con el código del otro.
  static Future<Map<String, dynamic>> vincular({
    required String codigo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dispositivoId = await obtenerDispositivoId();

    final respuesta = await ApiService.vincularDispositivo(
      dispositivoId: dispositivoId,
      codigo: codigo,
    );

    if (respuesta['exito'] == true) {
      await prefs.setBool(_keyVinculado, true);
      await prefs.setString(_keyCodigoVinculo, codigo.toUpperCase());
    }

    return respuesta;
  }

  /// Devuelve el nombre guardado localmente.
  static Future<String?> obtenerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNombre);
  }

  /// Devuelve el código de vínculo guardado localmente.
  static Future<String?> obtenerCodigoVinculo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCodigoVinculo);
  }

  /// Devuelve true si el dispositivo ya está vinculado con otro.
  static Future<bool> estaVinculado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVinculado) ?? false;
  }

  /// Guarda el nombre del usuario localmente.
  static Future<void> guardarNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNombre, nombre);
  }
}