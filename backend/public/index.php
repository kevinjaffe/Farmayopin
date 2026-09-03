<?php

declare(strict_types=1);

use Dotenv\Dotenv;

require __DIR__ . '/../vendor/autoload.php';

Dotenv::createImmutable(__DIR__ . '/..')->safeLoad();

require __DIR__ . '/../config/cors.php';

// Conexion a la base de datos (Punto de partida para el equipo)
$pdo = new PDO(
    sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        $_ENV['DB_HOST'] ?? 'db',
        $_ENV['DB_PORT'] ?? '3306',
        $_ENV['DB_NAME'] ?? 'farmayopin_db',
    ),
    $_ENV['DB_USER'] ?? 'root',
    $_ENV['DB_PASS'] ?? '',
    [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]
);

// Endpoint de prueba para verificar que la API responde
header('Content-Type: application/json');
echo json_encode(['message' => 'Farmayopin API funcionando. Empiecen a programar!']);
