<?php

declare(strict_types=1);

use App\Controllers\AuthController;
use Dotenv\Dotenv;
use App\Controllers\ProductController;

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

// Ruteo
$method = $_SERVER['REQUEST_METHOD'];
$path = '/' . trim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '', '/');

if ($path === '/api/auth/register' && $method === 'POST') {
    (new AuthController($pdo))->register();
    exit;
}

if ($path === '/api/auth/login' && $method === 'POST') {
    (new AuthController($pdo))->login();
    exit;
}
if ($path === '/api/productos' && $method === 'GET') {
    (new ProductController($pdo))->index();
    exit;
}

if ($path === '/api/productos' && $method === 'POST') {
    (new ProductController($pdo))->store();
    exit;
}

// Endpoint de prueba
header('Content-Type: application/json');
echo json_encode(['message' => 'Farmayopin API funcionando. Empiecen a programar!']);