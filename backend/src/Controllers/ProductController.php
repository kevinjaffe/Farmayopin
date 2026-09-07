<?php

declare(strict_types=1);

namespace App\Controllers;

use PDO;

class ProductController
{
    private const TAMANO_MAX_FOTO = 5 * 1024 * 1024;

    public function __construct(private PDO $pdo) {}

    public function index(): void
    {
        $stmt = $this->pdo->query(
            'SELECT id, nombre, precio, detalle, foto, stock FROM productos ORDER BY id DESC'
        );

        $productos = array_map(static function (array $p) {
            return [
                'id'          => (int) $p['id'],
                'nombre'      => $p['nombre'],
                'precio'      => (float) $p['precio'],
                'descripcion' => $p['detalle'],
                'foto'        => $p['foto'],
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

        $precio    = round((float) $precio, 2);
        $fotoNombre = $this->guardarFoto($data['foto'] ?? null);

        $stmt = $this->pdo->prepare(
            'INSERT INTO productos (nombre, precio, detalle, foto, stock) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([$nombre, $precio, $descripcion, $fotoNombre, (int) $stock]);

        $this->json([
            'message' => 'Producto creado',
            'producto' => [
                'id'          => (int) $this->pdo->lastInsertId(),
                'nombre'      => $nombre,
                'precio'      => $precio,
                'descripcion' => $descripcion,
                'foto'        => $fotoNombre,
                'stock'       => (int) $stock,
            ],
        ], 201);
    }

    public function foto(string $nombre): void
    {
        $nombre = basename($nombre);
        if ($nombre === '' || $nombre === '.' || $nombre === '..') {
            $this->json(['message' => 'Archivo inválido'], 400);
            return;
        }

        $ruta = __DIR__ . '/../Imagenes/' . $nombre;

        if (!is_file($ruta)) {
            $this->json(['message' => 'Imagen no encontrada'], 404);
            return;
        }

        $ext = strtolower(pathinfo($ruta, PATHINFO_EXTENSION));
        $mimes = [
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png'  => 'image/png',
            'webp' => 'image/webp',
        ];

        header('Content-Type: ' . ($mimes[$ext] ?? 'application/octet-stream'));
        header('Content-Length: ' . (string) filesize($ruta));
        readfile($ruta);
    }

    private function guardarFoto(mixed $foto): ?string
    {
        if (!is_string($foto) || $foto === '') {
            return null;
        }

        if (!preg_match('#^data:image/[a-z0-9.+-]+;base64,(.+)$#s', $foto, $m)) {
            return null;
        }

        $bin = base64_decode($m[1], true);
        if ($bin === false || $bin === '' || strlen($bin) > self::TAMANO_MAX_FOTO) {
            return null;
        }

        // Detecta el formato real por sus bytes (evita subir cosas que no son imágenes)
        $ext = match (true) {
            str_starts_with($bin, "\x89PNG\r\n\x1a\n")          => 'png',
            str_starts_with($bin, "\xFF\xD8\xFF")               => 'jpg',
            str_starts_with($bin, 'RIFF') && substr($bin, 8, 4) === 'WEBP' => 'webp',
            default                                             => null,
        };

        if ($ext === null) {
            return null;
        }

        $dir = __DIR__ . '/../Imagenes';
        if (!is_dir($dir)) {
            @mkdir($dir, 0775, true);
        }

        $nombreArchivo = 'prod_' . date('Ymd_His') . '_' . bin2hex(random_bytes(4)) . '.' . $ext;

        if (@file_put_contents($dir . '/' . $nombreArchivo, $bin) === false) {
            return null;
        }

        return $nombreArchivo;
    }

    private function json(array $data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
    }
}