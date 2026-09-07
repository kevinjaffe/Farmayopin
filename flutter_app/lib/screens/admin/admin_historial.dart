import 'package:flutter/material.dart';

class AdminHistorial extends StatelessWidget {
  const AdminHistorial({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Historial',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Historial de ventas — próximamente',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}