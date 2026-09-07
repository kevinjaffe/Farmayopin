<?php

declare(strict_types=1);

namespace App\Controllers;

use PDO;

class ProductController
{
    public function __construct(private PDO $pdo) {}

    public function index(): void
    {
        $stmt = $this->pdo->query(
            'SELECT id, nombre, precio, detalle, stock FROM productos ORDER BY id DESC'
        );

        $productos = array_map(static function (array $p) {
            return [
                'id'          => (int) $p['id'],
                'nombre'      => $p['nombre'],
                'precio'      => (float) $p['precio'],
                'descripcion' => $p['detalle'],
                'stock'       => (int) $p['stock'],
            ];
        }, $stmt->fetchAll());

        $this->json(['productos' => $productos]);
    }

    public function store(): void
    {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!is_array($data)) {
            $this->json(['message' => 'Body inválido'], 400);
            return;
        }

        $nombre      = trim($data['nombre'] ?? '');
        $descripcion = trim($data['descripcion'] ?? '');
        $precio      = $data['precio'] ?? null;
        $stock       = $data['stock'] ?? 0;

        if ($nombre === '') {
            $this->json(['message' => 'El nombre del producto es obligatorio'], 400);
            return;
        }

        if (!is_numeric($precio) || (float) $precio < 0) {
            $this->json(['message' => 'Precio inválido'], 400);
            return;
        }

        $precio = round((float) $precio, 2);

        $stmt = $this->pdo->prepare(
            'INSERT INTO productos (nombre, precio, detalle, stock) VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([$nombre, $precio, $descripcion, (int) $stock]);

        $this->json([
            'message' => 'Producto creado',
            'producto' => [
                'id'          => (int) $this->pdo->lastInsertId(),
                'nombre'      => $nombre,
                'precio'      => $precio,
                'descripcion' => $descripcion,
                'stock'       => (int) $stock,
            ],
        ], 201);
    }

    private function json(array $data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
    }
}