<?php
// Flag to skip loading all wordpress:
define("HEALTH_CHECK", true);
// Load WordPress configuration file
require_once('wp-config.php');

// Test database connection
$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
if ($mysqli->connect_errno) {
    echo "Error: Failed to connect to database.";
    exit();
}

// Test WordPress installation via cURL targeting 127.0.0.1 explicitly
$ch = curl_init("http://127.0.0.1/");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, true);       // We need headers to check status code
curl_setopt($ch, CURLOPT_NOBODY, true);       // Body is not needed, just headers
curl_setopt($ch, CURLOPT_TIMEOUT, 10);        // 10 second timeout
// curl_setopt($ch, CURLOPT_PORT, 80);      // Uncomment and change if your server runs on a custom port like 8080

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curl_error = curl_error($ch);
curl_close($ch);

if ($response === false || $http_code === 0) {
    echo "Error: Failed to connect to local web server via cURL. Details: $curl_error";
    exit();
}

if ($http_code >= 400) {
    echo "Error: Invalid response status: $http_code (Plugin or server error likely)";
    exit();
}

// Everything seems fine
echo "ok";
