<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

include "db.php";

$datos = json_decode(file_get_contents("php://input"), true);
$id = $datos["id"] ?? null;

if ($id === null) {
    echo json_encode(["error" => "Falta el id"]);
    exit;
}

$stmt = $conexion->prepare("DELETE FROM eventos WHERE id=?");
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["exito" => true]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

$stmt->close();
$conexion->close();
?>