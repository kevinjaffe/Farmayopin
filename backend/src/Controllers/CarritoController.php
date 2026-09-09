<?php

declare(strict_types=1);

namespace App\Controllers;

use PDO;

class CarritoController
{
    public function __construct(private PDO $pdo) {}

    public function index(): void
    {
        $usuarioId = $this->usuarioIdDesdeToken();
        if ($usuarioId === null) {
            $this->json(['message' => 'Token inválido o expirado'], 401);
            return;
        }

        $stmt = $this->pdo->prepare(
            'SELECT c.id AS carrito_id, c.producto_id, c.cantidad,
                    p.nombre, p.precio, p.foto, p.stock
             FROM carritos c
             JOIN productos p ON p.id = c.producto_id
             WHERE c.usuario_id = ?
             ORDER BY c.id DESC'
        );
        $stmt->execute([$usuarioId]);

        $items = array_map(static function (array $r) {
            return [
                'id'          => (int) $r['carrito_id'],
                'producto_id' => (int) $r['producto_id'],
                'nombre'      => $r['nombre'],
                'precio'      => (float) $r['precio'],
                'foto'        => $r['foto'],
                'cantidad'    => (int) $r['cantidad'],
                'stock'       => (int) $r['stock'],
                'subtotal'    => round((float) $r['precio'] * (int) $r['cantidad'], 2),
            ];
        }, $stmt->fetchAll());

        $total = array_sum(array_column($items, 'subtotal'));

        $this->json([
            'items'              => $items,
            'total'              => round($total, 2),
            'cantidad_productos' => count($items),
        ]);
    }

    public function store(): void
    {
        $usuarioId = $this->usuarioIdDesdeToken();
        if ($usuarioId === null) {
            $this->json(['message' => 'Token inválido o expirado'], 401);
            return;
        }

        $data = json_decode(file_get_contents('php://input'), true);

        if (!is_array($data)) {
            $this->json(['message' => 'Body inválido'], 400);
            return;
        }

        $productoId = (int) ($data['producto_id'] ?? 0);
        $cantidad   = (int) ($data['cantidad'] ?? 1);

        if ($productoId <= 0 || $cantidad < 1) {
            $this->json(['message' => 'Datos inválidos'], 400);
            return;
        }

        $stmt = $this->pdo->prepare('SELECT id, stock FROM productos WHERE id = ?');
        $stmt->execute([$productoId]);
        $producto = $stmt->fetch();

        if (!$producto) {
            $this->json(['message' => 'Producto no encontrado'], 404);
            return;
        }

        if ((int) $producto['stock'] <= 0) {
            $this->json(['message' => 'El producto no tiene stock'], 400);
            return;
        }

        $stmt = $this->pdo->prepare(
            'INSERT INTO carritos (usuario_id, producto_id, cantidad) VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE cantidad = carritos.cantidad + VALUES(cantidad)'
        );
        $stmt->execute([$usuarioId, $productoId, $cantidad]);

        $this->json(['message' => 'Producto agregado al carrito'], 201);
    }

    public function update(int $id): void
    {
        $usuarioId = $this->usuarioIdDesdeToken();
        if ($usuarioId === null) {
            $this->json(['message' => 'Token inválido o expirado'], 401);
            return;
        }

        $data = json_decode(file_get_contents('php://input'), true);

        if (!is_array($data)) {
            $this->json(['message' => 'Body inválido'], 400);
            return;
        }

        $cantidad = (int) ($data['cantidad'] ?? 0);

        if ($cantidad < 1) {
            $this->json(['message' => 'La cantidad debe ser al menos 1'], 400);
            return;
        }

        $stmt = $this->pdo->prepare(
            'UPDATE carritos SET cantidad = ? WHERE id = ? AND usuario_id = ?'
        );
        $stmt->execute([$cantidad, $id, $usuarioId]);

        if ($stmt->rowCount() === 0) {
            $this->json(['message' => 'Ítem no encontrado en tu carrito'], 404);
            return;
        }

        $this->json(['message' => 'Cantidad actualizada']);
    }

    public function destroy(int $id): void
    {
        $usuarioId = $this->usuarioIdDesdeToken();
        if ($usuarioId === null) {
            $this->json(['message' => 'Token inválido o expirado'], 401);
            return;
        }

        $stmt = $this->pdo->prepare(
            'DELETE FROM carritos WHERE id = ? AND usuario_id = ?'
        );
        $stmt->execute([$id, $usuarioId]);

        if ($stmt->rowCount() === 0) {
            $this->json(['message' => 'Ítem no encontrado en tu carrito'], 404);
            return;
        }

        $this->json(['message' => 'Ítem eliminado del carrito']);
    }

    public function pagar(): void
    {
        $usuarioId = $this->usuarioIdDesdeToken();
        if ($usuarioId === null) {
            $this->json(['message' => 'Token inválido o expirado'], 401);
            return;
        }

        $stmt = $this->pdo->prepare(
            'SELECT c.id, c.producto_id, c.cantidad, p.precio, p.stock
             FROM carritos c
             JOIN productos p ON p.id = c.producto_id
             WHERE c.usuario_id = ?'
        );
        $stmt->execute([$usuarioId]);
        $items = $stmt->fetchAll();

        if (count($items) === 0) {
            $this->json(['message' => 'Tu carrito está vacío'], 400);
            return;
        }

        foreach ($items as $item) {
            if ((int) $item['cantidad'] > (int) $item['stock']) {
                $this->json(['message' => 'Stock insuficiente para un producto del carrito'], 400);
                return;
            }
        }

        $total = 0.0;
        foreach ($items as $item) {
            $total += (float) $item['precio'] * (int) $item['cantidad'];
        }

        $this->pdo->beginTransaction();
        try {
            $stmt = $this->pdo->prepare('INSERT INTO compras (usuario_id, total) VALUES (?, ?)');
            $stmt->execute([$usuarioId, round($total, 2)]);
            $compraId = (int) $this->pdo->lastInsertId();

            $stmt = $this->pdo->prepare(
                'INSERT INTO compra_items (compra_id, producto_id, cantidad, precio_unitario, subtotal)
                 VALUES (?, ?, ?, ?, ?)'
            );
            foreach ($items as $item) {
                $subtotal = round((float) $item['precio'] * (int) $item['cantidad'], 2);
                $stmt->execute([
                    $compraId,
                    (int) $item['producto_id'],
                    (int) $item['cantidad'],
                    $item['precio'],
                    $subtotal,
                ]);
            }

            $stmt = $this->pdo->prepare('UPDATE productos SET stock = stock - ? WHERE id = ?');
            foreach ($items as $item) {
                $stmt->execute([(int) $item['cantidad'], (int) $item['producto_id']]);
            }

            $stmt = $this->pdo->prepare('DELETE FROM carritos WHERE usuario_id = ?');
            $stmt->execute([$usuarioId]);

            $this->pdo->commit();
        } catch (\Throwable) {
            $this->pdo->rollBack();
            $this->json(['message' => 'No se pudo procesar la compra'], 500);
            return;
        }

        $this->json([
            'message'  => 'Compra realizada',
            'compra_id' => $compraId,
            'total'    => round($total, 2),
        ], 201);
    }

    private function usuarioIdDesdeToken(): ?int
    {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        if (!preg_match('/^Bearer\s+(.+)$/i', $header, $m)) {
            return null;
        }

        $token = $m[1];
        $pos = strrpos($token, '.');
        if ($pos === false) {
            return null;
        }

        $payload = substr($token, 0, $pos);
        $firma = substr($token, $pos + 1);

        $secret = $_ENV['JWT_SECRET'] ?? 'change_this_secret_key';
        if (!hash_equals(hash_hmac('sha256', $payload, $secret), $firma)) {
            return null;
        }

        $data = json_decode(base64_decode($payload, true), true);
        if (!is_array($data) || !isset($data['id']) || ($data['exp'] ?? 0) < time()) {
            return null;
        }

        return (int) $data['id'];
    }

    private function json(array $data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
    }
}