<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
include "db.php";

$datos = json_decode(file_get_contents("php://input"), true);
$nombre = $datos["nombre"] ?? "";

if ($nombre === "") {
    echo json_encode(["error" => "Falta el nombre"]);
    exit;
}

$stmt = $conexion->prepare("INSERT IGNORE INTO tipos_nota (nombre) VALUES (?)");
$stmt->bind_param("s", $nombre);

if ($stmt->execute()) {
    echo json_encode(["exito" => true]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

$stmt->close();
$conexion->close();
?>