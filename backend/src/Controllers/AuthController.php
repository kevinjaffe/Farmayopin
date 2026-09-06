<?php

declare(strict_types=1);

namespace App\Controllers;

use PDO;

class AuthController
{
    public function __construct(private PDO $pdo) {}

    public function register(): void
    {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!is_array($data)) {
            $this->json(['message' => 'Body inválido'], 400);
            return;
        }

        $nombre   = trim($data['nombre'] ?? '');
        $email    = trim($data['email'] ?? '');
        $password = $data['password'] ?? '';

        if ($nombre === '' || $email === '' || $password === '') {
            $this->json(['message' => 'Todos los campos son obligatorios'], 400);
            return;
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $this->json(['message' => 'Email inválido'], 400);
            return;
        }

        if (strlen($password) < 6) {
            $this->json(['message' => 'La contraseña debe tener al menos 6 caracteres'], 400);
            return;
        }

        $stmt = $this->pdo->prepare('SELECT id FROM usuarios WHERE email = ?');
        $stmt->execute([$email]);

        if ($stmt->fetch()) {
            $this->json(['message' => 'El email ya está registrado'], 409);
            return;
        }

        $hash = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $this->pdo->prepare(
            'INSERT INTO usuarios (nombre, email, password, rol) VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([$nombre, $email, $hash, 'cliente']);

        $this->json([
            'message' => 'Usuario registrado',
            'usuario' => [
                'id'     => (int) $this->pdo->lastInsertId(),
                'nombre' => $nombre,
                'email'  => $email,
                'rol'    => 'cliente',
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