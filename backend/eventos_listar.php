<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

include "db.php";

$resultado = $conexion->query("SELECT * FROM eventos ORDER BY fecha, hora");

$eventos = [];
while ($fila = $resultado->fetch_assoc()) {
    $eventos[] = $fila;
}

echo json_encode($eventos);

$conexion->close();
?>