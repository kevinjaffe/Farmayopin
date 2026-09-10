<?php

declare(strict_types=1);

namespace App\Controllers;

use PDO;
use App\Traits\AutenticacionTrait;
class VentaController
{
    use AutenticacionTrait;
    public function __construct(private PDO $pdo) {}

    public function index(?int $productoId = null): void
    {
        $sql = 'SELECT ci.id, ci.cantidad, ci.precio_unitario, ci.subtotal,
                       c.fecha, c.total AS total_compra,
                       u.id AS cliente_id, u.nombre AS cliente_nombre,
                       p.id AS producto_id, p.nombre AS producto_nombre,
                       p.foto AS producto_foto, p.precio AS producto_precio
                FROM compra_items ci
                JOIN compras c ON c.id = ci.compra_id
                JOIN usuarios u ON u.id = c.usuario_id
                JOIN productos p ON p.id = ci.producto_id';

        if ($productoId !== null) {
            $sql .= ' WHERE ci.producto_id = ?';
        }

        $sql .= ' ORDER BY c.fecha DESC, ci.id DESC';

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($productoId !== null ? [$productoId] : []);

        $ventas = array_map(static function (array $v) {
            return [
                'id'             => (int) $v['id'],
                'fecha'          => $v['fecha'],
                'cantidad'       => (int) $v['cantidad'],
                'precio_unitario'=> (float) $v['precio_unitario'],
                'subtotal'       => (float) $v['subtotal'],
                'total_compra'   => (float) $v['total_compra'],
                'cliente'        => [
                    'id'     => (int) $v['cliente_id'],
                    'nombre' => $v['cliente_nombre'],
                ],
                'producto'       => [
                    'id'     => (int) $v['producto_id'],
                    'nombre' => $v['producto_nombre'],
                    'foto'   => $v['producto_foto'],
                    'precio' => (float) $v['producto_precio'],
                ],
            ];
        }, $stmt->fetchAll());

        $this->json(['ventas' => $ventas]);
    }

        public function misCompras(): void
    {
        $usuarioId = $this->usuarioIdDesdeToken();
        if ($usuarioId === null) {
            $this->json(['message' => 'Token inválido o expirado'], 401);
            return;
        }

        $stmt = $this->pdo->prepare(
            'SELECT c.id, c.fecha, c.total,
                    ci.producto_id, ci.cantidad, ci.precio_unitario, ci.subtotal,
                    p.nombre AS producto_nombre
             FROM compras c
             JOIN compra_items ci ON ci.compra_id = c.id
             JOIN productos p ON p.id = ci.producto_id
             WHERE c.usuario_id = ?
             ORDER BY c.fecha DESC, c.id DESC, ci.id ASC'
        );
        $stmt->execute([$usuarioId]);

        $pedidos = [];
        foreach ($stmt->fetchAll() as $row) {
            $id = (int) $row['id'];
            if (!isset($pedidos[$id])) {
                $pedidos[$id] = [
                    'id'                 => $id,
                    'fecha'              => $row['fecha'],
                    'total'              => (float) $row['total'],
                    'cantidad_productos' => 0,
                    'items'              => [],
                ];
            }
            $pedidos[$id]['items'][] = [
                'producto_id'     => (int) $row['producto_id'],
                'nombre'          => $row['producto_nombre'],
                'cantidad'        => (int) $row['cantidad'],
                'precio_unitario' => (float) $row['precio_unitario'],
                'subtotal'        => (float) $row['subtotal'],
            ];
            $pedidos[$id]['cantidad_productos'] = count($pedidos[$id]['items']);
        }

        $this->json(['pedidos' => array_values($pedidos)]);
    }

    private function json(array $data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
    }

    
}