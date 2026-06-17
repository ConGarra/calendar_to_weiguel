<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

include "db.php";

$datos = json_decode(file_get_contents("php://input"), true);

$id = $datos["id"] ?? null;
$titulo = $datos["titulo"] ?? "";
$tipo = $datos["tipo"] ?? "otro";
$descripcion = $datos["descripcion"] ?? null;
$completado = $datos["completado"] ?? 0;
$puntuacion = isset($datos["puntuacion"]) ? (int)$datos["puntuacion"] : null;

if ($id === null || $titulo === "") {
    echo json_encode(["error" => "Faltan campos obligatorios"]);
    exit;
}

$stmt = $conexion->prepare("UPDATE notas SET titulo=?, tipo=?, descripcion=?, completado=?, puntuacion=? WHERE id=?");
$stmt->bind_param("sssiii", $titulo, $tipo, $descripcion, $completado, $puntuacion, $id);

if ($stmt->execute()) {
    echo json_encode(["exito" => true]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

$stmt->close();
$conexion->close();
?>