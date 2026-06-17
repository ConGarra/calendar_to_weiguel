<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

include "db.php";

$datos = json_decode(file_get_contents("php://input"), true);

$titulo = $datos["titulo"] ?? "";
$fecha = $datos["fecha"] ?? "";
$hora = $datos["hora"] ?? null;
$recordatorio = $datos["recordatorio_minutos"] ?? null;
$creado_por = $datos["creado_por"] ?? null;
$color = $datos["color"] ?? "#E8794A";

if ($titulo === "" || $fecha === "") {
    echo json_encode(["error" => "Faltan campos obligatorios (titulo, fecha)"]);
    exit;
}

$stmt = $conexion->prepare("INSERT INTO eventos (titulo, fecha, hora, recordatorio_minutos, creado_por, color) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssss", $titulo, $fecha, $hora, $recordatorio, $creado_por, $color);

if ($stmt->execute()) {
    echo json_encode(["exito" => true, "id" => $stmt->insert_id]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

$stmt->close();
$conexion->close();
?>