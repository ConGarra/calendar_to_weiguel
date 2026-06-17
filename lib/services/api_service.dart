import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    return json.decode(res.body);
  }

  // -------------------------------------------------------
  // EVENTOS
  // -------------------------------------------------------

  static Future<List<dynamic>> listarEventos() async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"accion": "listar_eventos"}),
    );
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> crearEvento({
    required String titulo,
    required String fecha,
    String? hora,
    int? recordatorioMinutos,
    String? creadoPor,
    String? color,
  }) async {
    return _post({
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
    return _post({
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
    return _post({"accion": "borrar_evento", "id": id});
  }

  // -------------------------------------------------------
  // NOTAS
  // -------------------------------------------------------

  static Future<List<dynamic>> listarNotas() async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"accion": "listar_notas"}),
    );
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> crearNota({
    required String titulo,
    required String tipo,
    String? descripcion,
    String? creadoPor,
  }) async {
    return _post({
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
    return _post({
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
    return _post({"accion": "borrar_nota", "id": id});
  }
  // -------------------------------------------------------
  // TIPOS DE NOTA
  // -------------------------------------------------------

  static Future<List<dynamic>> listarTipos() async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"accion": "listar_tipos"}),
    );
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> crearTipo({
    required String nombre,
    String color = '#4A4A4A',
  }) async {
    return _post({"accion": "crear_tipo", "nombre": nombre, "color": color});
  }
}
