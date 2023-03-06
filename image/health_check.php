<?php
// Load WordPress configuration file
require_once('wp-config.php');

// Test database connection
$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
if ($mysqli->connect_errno) {
    echo "Error: Failed to connect to database.";
    exit();
}

// Test WordPress installation
$response = wp_remote_get("http://localhost/", ['timeout' => 60]);
if (is_wp_error($response)) {
    echo "Error: Failed to connect to WordPress site.";
    exit();
}

// Everything seems fine
echo "ok";
