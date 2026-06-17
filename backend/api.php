<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "db.php";

$datos = json_decode(file_get_contents("php://input"), true);
$accion = $datos["accion"] ?? "";

switch ($accion) {

    // -------------------------------------------------------
    // EVENTOS
    // -------------------------------------------------------

    case "listar_eventos":
        $resultado = $conexion->query("SELECT * FROM eventos ORDER BY fecha, hora");
        $eventos = [];
        while ($fila = $resultado->fetch_assoc()) {
            $eventos[] = $fila;
        }
        echo json_encode($eventos);
        break;

    case "crear_evento":
        $titulo = $datos["titulo"] ?? "";
        $fecha = $datos["fecha"] ?? "";
        $hora = $datos["hora"] ?? null;
        $recordatorio = $datos["recordatorio_minutos"] ?? null;
        $creado_por = $datos["creado_por"] ?? null;
        $color = $datos["color"] ?? "#E8794A";

        if ($titulo === "" || $fecha === "") {
            echo json_encode(["error" => "Faltan campos obligatorios (titulo, fecha)"]);
            break;
        }

        $stmt = $conexion->prepare(
            "INSERT INTO eventos (titulo, fecha, hora, recordatorio_minutos, creado_por, color)
             VALUES (?, ?, ?, ?, ?, ?)"
        );
        $stmt->bind_param("ssssss", $titulo, $fecha, $hora, $recordatorio, $creado_por, $color);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true, "id" => $stmt->insert_id]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "editar_evento":
        $id = $datos["id"] ?? null;
        $titulo = $datos["titulo"] ?? "";
        $fecha = $datos["fecha"] ?? "";
        $hora = $datos["hora"] ?? null;
        $recordatorio = $datos["recordatorio_minutos"] ?? null;
        $color = $datos["color"] ?? "#E8794A";

        if ($id === null || $titulo === "" || $fecha === "") {
            echo json_encode(["error" => "Faltan campos obligatorios (id, titulo, fecha)"]);
            break;
        }

        $stmt = $conexion->prepare(
            "UPDATE eventos SET titulo=?, fecha=?, hora=?, recordatorio_minutos=?, color=? WHERE id=?"
        );
        $stmt->bind_param("sssisi", $titulo, $fecha, $hora, $recordatorio, $color, $id);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "borrar_evento":
        $id = $datos["id"] ?? null;

        if ($id === null) {
            echo json_encode(["error" => "Falta el id"]);
            break;
        }

        $stmt = $conexion->prepare("DELETE FROM eventos WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    // -------------------------------------------------------
    // NOTAS
    // -------------------------------------------------------

    case "listar_tipos":
        // Devuelve todos los tipos personalizados ordenados alfabéticamente
        $resultado = $conexion->query("SELECT * FROM tipos_nota ORDER BY nombre ASC");
        $tipos = [];
        while ($fila = $resultado->fetch_assoc()) {
            $tipos[] = $fila;
        }
        echo json_encode($tipos);
        break;

    case "crear_tipo":
        $nombre = $datos["nombre"] ?? "";
        $color = $datos["color"] ?? "#4A4A4A";
        if ($nombre === "") {
            echo json_encode(["error" => "Falta el nombre"]);
            break;
        }
        $stmt = $conexion->prepare("INSERT IGNORE INTO tipos_nota (nombre, color) VALUES (?, ?)");
        $stmt->bind_param("ss", $nombre, $color);
        if ($stmt->execute()) {
            echo json_encode(["exito" => true]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "listar_notas":
        // JOIN con tipos_nota para traer el color del tipo personalizado
        $resultado = $conexion->query("
        SELECT n.*, t.color AS tipo_color
        FROM notas n
        LEFT JOIN tipos_nota t ON n.tipo = t.nombre
        ORDER BY n.creado_en DESC
    ");
        $notas = [];
        while ($fila = $resultado->fetch_assoc()) {
            $notas[] = $fila;
        }
        echo json_encode($notas);
        break;

    case "crear_nota":
        $titulo = $datos["titulo"] ?? "";
        $tipo = $datos["tipo"] ?? "otro";
        $descripcion = $datos["descripcion"] ?? null;
        $creado_por = $datos["creado_por"] ?? null;

        if ($titulo === "") {
            echo json_encode(["error" => "Falta el titulo"]);
            break;
        }

        $stmt = $conexion->prepare(
            "INSERT INTO notas (titulo, tipo, descripcion, creado_por) VALUES (?, ?, ?, ?)"
        );
        $stmt->bind_param("ssss", $titulo, $tipo, $descripcion, $creado_por);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true, "id" => $stmt->insert_id]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "editar_nota":
        $id = $datos["id"] ?? null;
        $titulo = $datos["titulo"] ?? "";
        $tipo = $datos["tipo"] ?? "otro";
        $descripcion = $datos["descripcion"] ?? null;
        $completado = $datos["completado"] ?? 0;
        $puntuacion = isset($datos["puntuacion"]) ? (int) $datos["puntuacion"] : null;

        if ($id === null || $titulo === "") {
            echo json_encode(["error" => "Faltan campos obligatorios (id, titulo)"]);
            break;
        }

        $stmt = $conexion->prepare(
            "UPDATE notas SET titulo=?, tipo=?, descripcion=?, completado=?, puntuacion=? WHERE id=?"
        );
        $stmt->bind_param("sssiii", $titulo, $tipo, $descripcion, $completado, $puntuacion, $id);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "borrar_nota":
        $id = $datos["id"] ?? null;

        if ($id === null) {
            echo json_encode(["error" => "Falta el id"]);
            break;
        }

        $stmt = $conexion->prepare("DELETE FROM notas WHERE id=?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    default:
        echo json_encode(["error" => "Accion no reconocida: $accion"]);
        break;
}

$conexion->close();
