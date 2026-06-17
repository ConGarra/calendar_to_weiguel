<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");

include "db.php";

$resultado = $conexion->query("SELECT * FROM notas ORDER BY creado_en DESC");

$notas = [];
while ($fila = $resultado->fetch_assoc()) {
    $notas[] = $fila;
}

echo json_encode($notas);

$conexion->close();
?>