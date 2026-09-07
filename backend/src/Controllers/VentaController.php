<?php

declare(strict_types=1);

namespace App\Controllers;

use PDO;

class VentaController
{
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

    private function json(array $data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
    }
}