import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  static Future<dynamic> _post(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));
      return json.decode(res.body);
    } on FormatException {
      throw Exception('Respuesta inválida del servidor');
    }
  }

  // Helper para métodos que esperan un Map como respuesta
  static Future<Map<String, dynamic>> _postMap(Map<String, dynamic> body) async {
    return (await _post(body)) as Map<String, dynamic>;
  }

  // -------------------------------------------------------
  // EVENTOS
  // -------------------------------------------------------

  static Future<List<dynamic>> listarEventos() async {
    return (await _post({"accion": "listar_eventos"})) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> crearEvento({
    required String titulo,
    required String fecha,
    String? hora,
    int? recordatorioMinutos,
    String? creadoPor,
    String? color,
  }) async {
    return _postMap({
      "accion": "crear_evento",
      "titulo": titulo,
      "fecha": fecha,
      "hora": hora,
      "recordatorio_minutos": recordatorioMinutos,
      "creado_por": creadoPor,
      "color": color ?? "#E8794A",
    });
  }

  static Future<Map<String, dynamic>> editarEvento({
    required int id,
    required String titulo,
    required String fecha,
    String? hora,
    int? recordatorioMinutos,
    String? color,
  }) async {
    return _postMap({
      "accion": "editar_evento",
      "id": id,
      "titulo": titulo,
      "fecha": fecha,
      "hora": hora,
      "recordatorio_minutos": recordatorioMinutos,
      "color": color ?? "#6B7FD4",
    });
  }

  static Future<Map<String, dynamic>> borrarEvento({required int id}) async {
    return _postMap({"accion": "borrar_evento", "id": id});
  }

  // -------------------------------------------------------
  // NOTAS
  // -------------------------------------------------------

  static Future<List<dynamic>> listarNotas() async {
    return (await _post({"accion": "listar_notas"})) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> crearNota({
    required String titulo,
    required String tipo,
    String? descripcion,
    String? creadoPor,
  }) async {
    return _postMap({
      "accion": "crear_nota",
      "titulo": titulo,
      "tipo": tipo,
      "descripcion": descripcion,
      "creado_por": creadoPor,
    });
  }

  static Future<Map<String, dynamic>> editarNota({
    required int id,
    required String titulo,
    required String tipo,
    String? descripcion,
    int completado = 0,
    int? puntuacion,
  }) async {
    return _postMap({
      "accion": "editar_nota",
      "id": id,
      "titulo": titulo,
      "tipo": tipo,
      "descripcion": descripcion,
      "completado": completado,
      "puntuacion": puntuacion,
    });
  }

  static Future<Map<String, dynamic>> borrarNota({required int id}) async {
    return _postMap({"accion": "borrar_nota", "id": id});
  }

  // -------------------------------------------------------
  // PLANNER
  // -------------------------------------------------------

  /// Obtiene los contenidos de los 7 días y las tareas de una semana.
  /// [semanaInicio] es el lunes de esa semana en formato "YYYY-MM-DD".
  static Future<Map<String, dynamic>> obtenerSemanaPlanner({
    required String semanaInicio,
  }) async {
    return _postMap({
      "accion": "obtener_semana_planner",
      "semana_inicio": semanaInicio,
    });
  }

  /// Guarda o actualiza el contenido de texto de un día.
  static Future<Map<String, dynamic>> guardarDiaPlanner({
    required String fecha,
    required String contenido,
  }) async {
    return _postMap({
      "accion": "guardar_dia_planner",
      "fecha": fecha,
      "contenido": contenido,
    });
  }

  /// Crea una tarea nueva en el To Do List de la semana.
  static Future<Map<String, dynamic>> crearTareaPlanner({
    required String semanaInicio,
    required String titulo,
  }) async {
    return _postMap({
      "accion": "crear_tarea_planner",
      "semana_inicio": semanaInicio,
      "titulo": titulo,
    });
  }

  /// Marca o desmarca una tarea como completada.
  static Future<Map<String, dynamic>> toggleTareaPlanner({
    required int id,
    required int completado,
  }) async {
    return _postMap({
      "accion": "toggle_tarea_planner",
      "id": id,
      "completado": completado,
    });
  }

  /// Elimina una tarea del To Do List.
  static Future<Map<String, dynamic>> borrarTareaPlanner({
    required int id,
  }) async {
    return _postMap({"accion": "borrar_tarea_planner", "id": id});
  }
  // -------------------------------------------------------
  // TIPOS DE NOTA
  // -------------------------------------------------------

  static Future<List<dynamic>> listarTipos() async {
    return (await _post({"accion": "listar_tipos"})) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> crearTipo({
    required String nombre,
    String color = '#4A4A4A',
  }) async {
    return _postMap({"accion": "crear_tipo", "nombre": nombre, "color": color});
  }
  // -------------------------------------------------------
  // DISPOSITIVOS / VINCULACIÓN
  // -------------------------------------------------------

  static Future<Map<String, dynamic>> registrarDispositivo({
    required String dispositivoId,
    required String nombre,
  }) async {
    return _postMap({
      "accion": "registrar_dispositivo",
      "dispositivo_id": dispositivoId,
      "nombre": nombre,
    });
  }

  static Future<Map<String, dynamic>> vincularDispositivo({
    required String dispositivoId,
    required String codigo,
  }) async {
    return _postMap({
      "accion": "vincular_dispositivo",
      "dispositivo_id": dispositivoId,
      "codigo": codigo,
    });
  }

  static Future<Map<String, dynamic>> obtenerDispositivo({
    required String dispositivoId,
  }) async {
    return _postMap({
      "accion": "obtener_dispositivo",
      "dispositivo_id": dispositivoId,
    });
  }
}
