<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
include "db.php";

$resultado = $conexion->query("SELECT * FROM tipos_nota ORDER BY nombre ASC");
$tipos = [];
while ($fila = $resultado->fetch_assoc()) {
    $tipos[] = $fila;
}
echo json_encode($tipos);
$conexion->close();
?>