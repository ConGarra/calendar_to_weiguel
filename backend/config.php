<?php
// -------------------------------------------------------
// Configuracion de base de datos
// En localhost: usa los valores por defecto.
// En produccion: define estas variables de entorno en el servidor
// (p.ej. en el panel de hosting, en .htaccess o en el servidor web)
// y este archivo las tomara automaticamente sin cambiar codigo.
// -------------------------------------------------------

define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_USER', getenv('DB_USER') ?: 'weiguel_user');
define('DB_PASS', getenv('DB_PASS') ?: 'weiguel1234');
define('DB_NAME', getenv('DB_NAME') ?: 'calendar_weiguel');
