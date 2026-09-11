<?php

declare(strict_types=1);

namespace App\Controllers;

use PDO;
use App\Traits\AutenticacionTrait;

class MediosPagoController
{
    use AutenticacionTrait;

    public function __construct(private PDO $pdo) {}

    public function index(): void
    {
        $usuarioId = $this->usuarioIdDesdeToken();
        if ($usuarioId === null) {
            $this->json(['message' => 'Token inválido o expirado'], 401);
            return;
        }

        $stmt = $this->pdo->prepare(
            'SELECT id, tipo, marca, numero_tarjeta, titular, vencimiento
             FROM medios_pago
             WHERE usuario_id = ?
             ORDER BY id DESC'
        );
        $stmt->execute([$usuarioId]);

        $medios = array_map(static function (array $m) {
            return [
                'id'          => (int) $m['id'],
                'tipo'        => $m['tipo'],
                'marca'       => $m['marca'],
                'numero'      => $m['numero_tarjeta'],
                'titular'     => $m['titular'],
                'vencimiento' => $m['vencimiento'],
            ];
        }, $stmt->fetchAll());

        $this->json(['medios_pago' => $medios]);
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

        $tipo        = in_array($data['tipo'] ?? '', ['credito', 'debito'], true) ? $data['tipo'] : '';
        $marca       = trim((string) ($data['marca'] ?? ''));
        $numero      = preg_replace('/\D+/', '', (string) ($data['numero'] ?? ''));
        $titular     = trim((string) ($data['titular'] ?? ''));
        $vencimiento = trim((string) ($data['vencimiento'] ?? ''));

        if (
            $tipo === '' || $marca === '' || strlen($numero) < 13 ||
            $titular === '' || !preg_match('#^(0[1-9]|1[0-2])/\d{2}$#', $vencimiento)
        ) {
            $this->json(['message' => 'Datos de tarjeta inválidos'], 400);
            return;
        }

        $ultimos4 = substr($numero, -4);

        $stmt = $this->pdo->prepare(
            'INSERT INTO medios_pago (usuario_id, tipo, marca, numero_tarjeta, titular, vencimiento)
             VALUES (?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([$usuarioId, $tipo, $marca, $ultimos4, $titular, $vencimiento]);

        $this->json([
            'message' => 'Método de pago agregado',
            'medio'   => [
                'id'          => (int) $this->pdo->lastInsertId(),
                'tipo'        => $tipo,
                'marca'       => $marca,
                'numero'      => $ultimos4,
                'titular'     => $titular,
                'vencimiento' => $vencimiento,
            ],
        ], 201);
    }

    public function destroy(int $id): void
    {
        $usuarioId = $this->usuarioIdDesdeToken();
        if ($usuarioId === null) {
            $this->json(['message' => 'Token inválido o expirado'], 401);
            return;
        }

        $stmt = $this->pdo->prepare('DELETE FROM medios_pago WHERE id = ? AND usuario_id = ?');
        $stmt->execute([$id, $usuarioId]);

        if ($stmt->rowCount() === 0) {
            $this->json(['message' => 'Método de pago no encontrado'], 404);
            return;
        }

        $this->json(['message' => 'Método de pago eliminado']);
    }
}