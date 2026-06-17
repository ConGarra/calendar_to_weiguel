<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

include "db.php";

$datos = json_decode(file_get_contents("php://input"), true);

$titulo = $datos["titulo"] ?? "";
$tipo = $datos["tipo"] ?? "otro";
$descripcion = $datos["descripcion"] ?? null;
$creado_por = $datos["creado_por"] ?? null;

if ($titulo === "") {
    echo json_encode(["error" => "Falta el titulo"]);
    exit;
}

$stmt = $conexion->prepare("INSERT INTO notas (titulo, tipo, descripcion, creado_por) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $titulo, $tipo, $descripcion, $creado_por);

if ($stmt->execute()) {
    echo json_encode(["exito" => true, "id" => $stmt->insert_id]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

$stmt->close();
$conexion->close();
?>