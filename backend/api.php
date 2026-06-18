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
    // -------------------------------------------------------
// DISPOSITIVOS / VINCULACIÓN
// -------------------------------------------------------

    case "registrar_dispositivo":
        // Registra un dispositivo nuevo y genera su código de vínculo único
        $dispositivo_id = $datos["dispositivo_id"] ?? "";
        $nombre = $datos["nombre"] ?? "Usuario";

        if ($dispositivo_id === "") {
            echo json_encode(["error" => "Falta dispositivo_id"]);
            break;
        }

        // Generamos un código de 6 caracteres aleatorio y único
        $codigo = strtoupper(substr(md5(uniqid($dispositivo_id, true)), 0, 6));

        $stmt = $conexion->prepare(
            "INSERT IGNORE INTO dispositivos (dispositivo_id, nombre, codigo_vinculo)
         VALUES (?, ?, ?)"
        );
        $stmt->bind_param("sss", $dispositivo_id, $nombre, $codigo);

        if ($stmt->execute()) {
            // Devolvemos los datos del dispositivo (sea nuevo o ya existente)
            $stmt2 = $conexion->prepare(
                "SELECT * FROM dispositivos WHERE dispositivo_id = ?"
            );
            $stmt2->bind_param("s", $dispositivo_id);
            $stmt2->execute();
            $result = $stmt2->get_result()->fetch_assoc();
            echo json_encode(["exito" => true, "dispositivo" => $result]);
            $stmt2->close();
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "vincular_dispositivo":
        // Vincula este dispositivo al código de vínculo de otro dispositivo
        $dispositivo_id = $datos["dispositivo_id"] ?? "";
        $codigo = strtoupper(trim($datos["codigo"] ?? ""));

        if ($dispositivo_id === "" || $codigo === "") {
            echo json_encode(["error" => "Faltan campos obligatorios"]);
            break;
        }

        // Comprobamos que el código existe y no es el propio dispositivo
        $stmt = $conexion->prepare(
            "SELECT * FROM dispositivos WHERE codigo_vinculo = ? AND dispositivo_id != ?"
        );
        $stmt->bind_param("ss", $codigo, $dispositivo_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();

        if (!$result) {
            echo json_encode(["error" => "Código no válido o es el tuyo propio"]);
            break;
        }

        // Actualizamos el código de vínculo de este dispositivo al del otro
        $stmt2 = $conexion->prepare(
            "UPDATE dispositivos SET codigo_vinculo = ? WHERE dispositivo_id = ?"
        );
        $stmt2->bind_param("ss", $codigo, $dispositivo_id);

        if ($stmt2->execute()) {
            echo json_encode(["exito" => true]);
        } else {
            echo json_encode(["error" => $stmt2->error]);
        }
        $stmt2->close();
        break;

    case "obtener_dispositivo":
        // Devuelve los datos de un dispositivo por su ID
        $dispositivo_id = $datos["dispositivo_id"] ?? "";

        if ($dispositivo_id === "") {
            echo json_encode(["error" => "Falta dispositivo_id"]);
            break;
        }

        $stmt = $conexion->prepare(
            "SELECT * FROM dispositivos WHERE dispositivo_id = ?"
        );
        $stmt->bind_param("s", $dispositivo_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();

        if ($result) {
            echo json_encode(["exito" => true, "dispositivo" => $result]);
        } else {
            echo json_encode(["error" => "Dispositivo no encontrado"]);
        }
        break;

    case "listar_dispositivos":
        $resultado = $conexion->query("SELECT * FROM dispositivos");
        $dispositivos = [];
        while ($fila = $resultado->fetch_assoc()) {
            $dispositivos[] = $fila;
        }
        echo json_encode($dispositivos);
        break;
    // -------------------------------------------------------
// PLANNER
// -------------------------------------------------------

    case "obtener_semana_planner":
        // Devuelve el contenido de los 7 días de una semana
        // y las tareas de esa semana
        $semana_inicio = $datos["semana_inicio"] ?? "";

        if ($semana_inicio === "") {
            echo json_encode(["error" => "Falta semana_inicio"]);
            break;
        }

        // Calculamos el último día de la semana (domingo)
        $semana_fin = date('Y-m-d', strtotime($semana_inicio . ' +6 days'));

        // Obtenemos los días con contenido
        $stmt = $conexion->prepare(
            "SELECT fecha, contenido FROM planner_dias
         WHERE fecha BETWEEN ? AND ?
         ORDER BY fecha ASC"
        );
        $stmt->bind_param("ss", $semana_inicio, $semana_fin);
        $stmt->execute();
        $result = $stmt->get_result();
        $dias = [];
        while ($fila = $result->fetch_assoc()) {
            $dias[$fila['fecha']] = $fila['contenido'];
        }
        $stmt->close();

        // Obtenemos las tareas de la semana
        $stmt2 = $conexion->prepare(
            "SELECT * FROM planner_tareas
         WHERE semana_inicio = ?
         ORDER BY orden ASC, creado_en ASC"
        );
        $stmt2->bind_param("s", $semana_inicio);
        $stmt2->execute();
        $result2 = $stmt2->get_result();
        $tareas = [];
        while ($fila = $result2->fetch_assoc()) {
            $tareas[] = $fila;
        }
        $stmt2->close();

        echo json_encode([
            "exito" => true,
            "dias" => $dias,
            "tareas" => $tareas,
        ]);
        break;

    case "guardar_dia_planner":
        // Guarda o actualiza el contenido de un día
        $fecha = $datos["fecha"] ?? "";
        $contenido = $datos["contenido"] ?? "";

        if ($fecha === "") {
            echo json_encode(["error" => "Falta la fecha"]);
            break;
        }

        // INSERT OR UPDATE — si ya existe ese día lo actualiza
        $stmt = $conexion->prepare(
            "INSERT INTO planner_dias (fecha, contenido)
         VALUES (?, ?)
         ON DUPLICATE KEY UPDATE contenido = VALUES(contenido)"
        );
        $stmt->bind_param("ss", $fecha, $contenido);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "crear_tarea_planner":
        // Añade una tarea nueva al To Do List de la semana
        $semana_inicio = $datos["semana_inicio"] ?? "";
        $titulo = $datos["titulo"] ?? "";

        if ($semana_inicio === "" || $titulo === "") {
            echo json_encode(["error" => "Faltan campos obligatorios"]);
            break;
        }

        $stmt = $conexion->prepare(
            "INSERT INTO planner_tareas (semana_inicio, titulo)
         VALUES (?, ?)"
        );
        $stmt->bind_param("ss", $semana_inicio, $titulo);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true, "id" => $stmt->insert_id]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "toggle_tarea_planner":
        // Marca o desmarca una tarea como completada
        $id = $datos["id"] ?? null;
        $completado = $datos["completado"] ?? 0;

        if ($id === null) {
            echo json_encode(["error" => "Falta el id"]);
            break;
        }

        $stmt = $conexion->prepare(
            "UPDATE planner_tareas SET completado = ? WHERE id = ?"
        );
        $stmt->bind_param("ii", $completado, $id);

        if ($stmt->execute()) {
            echo json_encode(["exito" => true]);
        } else {
            echo json_encode(["error" => $stmt->error]);
        }
        $stmt->close();
        break;

    case "borrar_tarea_planner":
        // Elimina una tarea del To Do List
        $id = $datos["id"] ?? null;

        if ($id === null) {
            echo json_encode(["error" => "Falta el id"]);
            break;
        }

        $stmt = $conexion->prepare(
            "DELETE FROM planner_tareas WHERE id = ?"
        );
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
