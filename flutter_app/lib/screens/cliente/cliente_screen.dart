import 'package:flutter/material.dart';

import '../../core/services/session_manager.dart';
import '../login_screen.dart';

class ClienteScreen extends StatelessWidget {
  const ClienteScreen({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  static const Color primaryPurple = Color(0xFF6A0DAD);

  Future<void> _cerrarSesion(BuildContext context) async {
    await SessionManager.cerrar();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmayopin'),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A0DAD), Color(0xFF9C4FDB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Hola, bienvenido!',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario['nombre'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      usuario['email'] as String,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _AccionTile(
                icono: Icons.shopping_bag_outlined,
                titulo: 'Catálogo',
                subtitulo: 'Ver productos disponibles',
              ),
              const _AccionTile(
                icono: Icons.shopping_cart_outlined,
                titulo: 'Mi Carrito',
                subtitulo: 'Productos seleccionados',
              ),
              const _AccionTile(
                icono: Icons.history,
                titulo: 'Mis Compras',
                subtitulo: 'Historial de pedidos',
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _cerrarSesion(context),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccionTile extends StatelessWidget {
  const _AccionTile({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icono, color: const Color(0xFF6A0DAD), size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}