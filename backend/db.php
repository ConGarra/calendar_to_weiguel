<?php
require_once "config.php";

mysqli_report(MYSQLI_REPORT_OFF); // Evita que PHP emita HTML antes del JSON si MySQL falla

$conexion = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($conexion->connect_error) {
    die(json_encode(["error" => "Error de conexion: " . $conexion->connect_error]));
}

$conexion->set_charset("utf8mb4");
?>