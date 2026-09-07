import 'package:flutter/material.dart';

import '../../core/services/session_manager.dart';
import '../login_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key, required this.usuario});

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
        title: const Text('Panel de Administrador'),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardUsuario(
                nombre: usuario['nombre'] as String,
                email: usuario['email'] as String,
                rol: 'admin',
              ),
              const SizedBox(height: 24),
              const _AccionTile(
                icono: Icons.inventory_2_outlined,
                titulo: 'Gestionar Productos',
                subtitulo: 'Alta, baja y modificación',
              ),
              const _AccionTile(
                icono: Icons.receipt_long_outlined,
                titulo: 'Ver Compras',
                subtitulo: 'Historial de ventas',
              ),
              const _AccionTile(
                icono: Icons.group_outlined,
                titulo: 'Usuarios',
                subtitulo: 'Administrar cuentas',
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

class _CardUsuario extends StatelessWidget {
  const _CardUsuario({
    required this.nombre,
    required this.email,
    required this.rol,
  });

  final String nombre;
  final String email;
  final String rol;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            '¡Hola!',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              rol.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
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