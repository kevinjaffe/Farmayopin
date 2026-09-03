# Farmayopin - Taller de Aplicaciones Moviles

Aplicacion movil para gestionar articulos de farmacia.

## Arquitectura

- **Frontend**: Flutter (Dart)
- **Backend**: PHP 8.3 + Apache (API REST/JSON)
- **Base de datos servidor**: MySQL 8.4
- **Persistencia local**: SQLite (en el dispositivo)
- **Contenerizacion**: Docker Compose

## Estructura

```
DispositivosMoviles/
├── backend/          # API PHP (Docker: php-apache)
├── flutter_app/      # Aplicacion Flutter
├── docker-compose.yml
└── .env.example
```

## Requisitos

- Docker + Docker Compose
- Flutter SDK
- (Opcional) Android Studio / SDK para correr en celular

## Puesta en marcha del backend

```bash
cp .env.example .env      # editar credenciales si es necesario
docker compose up -d --build
```

- API: http://localhost:8080
- phpMyAdmin: http://localhost:8081

### Crear la base de datos

La base de datos NO se crea automaticamente. En phpMyAdmin:

1. Abrir http://localhost:8081 y loguearse
2. Crear la base `farmayopin_db`
3. Entrar a la base y pegar el contenido de
   `backend/database/migrations/001_create_tables.sql` en la pestana SQL

## Correr la app Flutter

```bash
cd flutter_app
flutter pub get
flutter run -d chrome      # navegador
flutter run -d <dispositivo>  # celular Android (requiere Android SDK)
```

## API endpoints principales

| Metodo | Ruta | Acceso |
|--------|------|--------|
| POST | /api/auth/register | publico |
| POST | /api/auth/login | publico |
| GET | /api/products | publico |
| POST | /api/products | admin |
| PUT | /api/products/{id} | admin |
| GET | /api/cart | cliente |
| POST | /api/cart | cliente |
| POST | /api/cart/pay | cliente |
| GET | /api/purchases | publico |
| GET | /api/purchases/product/{id} | admin |
