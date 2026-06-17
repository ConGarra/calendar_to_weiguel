<?php
require_once "config.php";

$conexion = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($conexion->connect_error) {
    die(json_encode(["error" => "Error de conexion: " . $conexion->connect_error]));
}

$conexion->set_charset("utf8mb4");
?>