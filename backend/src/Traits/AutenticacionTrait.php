<?php

declare(strict_types=1);

namespace App\Traits;

trait AutenticacionTrait
{
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