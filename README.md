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
farmayopin/
├── backend/               # API PHP (Docker: php-apache)
│   ├── public/            # DocumentRoot (index.php)
│   └── database/migrations/  # Esquema SQL
├── flutter_app/           # Aplicacion Flutter
├── docker-compose.yml
└── .env                   # Credenciales (versionado, no hay que crearlo)
```

## Requisitos

- Git
- Docker + Docker Compose
- Flutter SDK
- (Opcional) Android Studio / Android SDK para correr en celular o emulador

## Puesta en marcha del backend

```bash
docker compose up -d --build
```

- API: http://localhost:8080
- phpMyAdmin: http://localhost:8081

### Crear la base de datos

La base de datos NO se crea automaticamente. En phpMyAdmin:

1. Abrir http://localhost:8081 y loguearse
2. Crear la base `farmayopin_db`
3. Entrar a la base y pegar el contenido de
   `backend/database/migrations/farmayopin_db.sql` en la pestana SQL

## Correr la app Flutter

```bash
cd flutter_app
flutter pub get
flutter run -d chrome      # navegador
flutter run -d <dispositivo>  # celular Android (requiere Android SDK)
```

### Configurar la URL del backend

Si el backend corre en otra PC o lo ejecutas desde un dispositivo físico, pasa la IP del servidor:

```bash
flutter run --dart-define=API_BASE_URL=http://<IP_del_servidor>:8080
```

- **Misma PC**: no hace falta pasar nada. En web/escritorio usa `localhost:8080`;
  en Android emulador usa `10.0.2.2:8080` automaticamente (IP que llega al host).
- **Otra PC / celular físico**: usa la IP local del servidor donde corre Docker
  (`ipconfig` en Windows, `ip addr` en Linux, ej: `http://192.168.1.100:8080`).
- Regla de prioridad: si pasas `--dart-define=API_BASE_URL`, esa gana siempre.

Condiciones para celular físico / backend en otra PC:

- Misma red local (mismo WiFi).
- Abrir el puerto 8080 en el firewall de la PC del backend (una vez, como admin):

```powershell
New-NetFirewallRule -DisplayName "Farmayopin API 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow -Profile Private,Public
```

Para builds de producción:
```bash
flutter build apk --dart-define=API_BASE_URL=http://<IP_del_servidor>:8080
flutter build web --dart-define=API_BASE_URL=http://<IP_del_servidor>:8080
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