import 'package:flutter/material.dart';

import 'admin_historial.dart';
import 'admin_perfil.dart';
import 'admin_productos.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  int _indice = 0;

  static const Color primaryPurple = Color(0xFF6A0DAD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _indice,
                children: [
                  AdminProductos(usuario: widget.usuario),
                  AdminHistorial(usuario: widget.usuario),
                  AdminPerfil(usuario: widget.usuario),
                ],
              ),
            ),
            _buildNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(0, Icons.local_mall_outlined, 'Productos'),
          _item(1, Icons.history, 'Historial'),
          _item(2, Icons.person, 'Perfil'),
        ],
      ),
    );
  }

  Widget _item(int indice, IconData icono, String label) {
    final bool activo = indice == _indice;
    final Color color = activo ? primaryPurple : const Color(0xFF94A3B8);
    return InkWell(
      onTap: () => setState(() => _indice = indice),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}