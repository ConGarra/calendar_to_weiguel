<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

include "db.php";

$datos = json_decode(file_get_contents("php://input"), true);

$id = $datos["id"] ?? null;
$titulo = $datos["titulo"] ?? "";
$fecha = $datos["fecha"] ?? "";
$hora = $datos["hora"] ?? null;
$recordatorio = $datos["recordatorio_minutos"] ?? null;
$color = $datos["color"] ?? "#E8794A";

if ($id === null || $titulo === "" || $fecha === "") {
    echo json_encode(["error" => "Faltan campos obligatorios (id, titulo, fecha)"]);
    exit;
}

$stmt = $conexion->prepare("UPDATE eventos SET titulo=?, fecha=?, hora=?, recordatorio_minutos=?, color=? WHERE id=?");
$stmt->bind_param("sssisi", $titulo, $fecha, $hora, $recordatorio, $color, $id);

if ($stmt->execute()) {
    echo json_encode(["exito" => true]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

$stmt->close();
$conexion->close();
?>