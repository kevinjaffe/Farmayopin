import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/services/local_db.dart';
import '../../core/services/session_manager.dart';
import '../login_screen.dart';
import 'agregar_tarjeta_dialog.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLabel = Color(0xFF64748B);

  final ApiClient _api = ApiClient();

  Map<String, dynamic> get usuario => widget.usuario;

  String get _rolLabel =>
      usuario['rol'] == 'admin' ? 'ADMINISTRADOR' : 'CLIENTE';

  List<Map<String, dynamic>> _medios = [];

  @override
  void initState() {
    super.initState();
    _cargarMedios();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _cargarMedios() async {
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final res = await _api.get('/api/medios-pago');
      final medios = (res['medios_pago'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (!mounted) return;
      setState(() => _medios = medios);
    } catch (_) {
      // Si falla la carga de medios, la sección queda vacía sin bloquear el perfil.
    }
  }

  Future<void> _agregarMetodo() async {
    final datos = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AgregarTarjetaDialog(),
    );
    if (datos == null) return;

    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final res = await _api.post('/api/medios-pago', body: jsonEncode(datos));
      if (!mounted) return;
      final nuevo = Map<String, dynamic>.from(res['medio'] as Map);
      setState(() => _medios.insert(0, nuevo));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _quitarMetodo(Map<String, dynamic> medio) async {
    final id = medio['id'] as int;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quitar método de pago'),
        content: const Text('¿Querés eliminar este método de pago?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      await _api.delete('/api/medios-pago/$id');
      if (!mounted) return;
      setState(() => _medios.removeWhere((m) => m['id'] == id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    await LocalDb.borrarHistorialLocal();
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mi Perfil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildInfoCard(),
              _buildMediosCard(),
              const SizedBox(height: 32),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 50, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        Text(
          usuario['nombre'] as String,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _rolLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9333EA),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Column(
        children: [
          _infoGroup('NOMBRE COMPLETO', usuario['nombre'] as String),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _infoGroup('CORREO ELECTRÓNICO', usuario['email'] as String),
        ],
      ),
    );
  }

  Widget _buildMediosCard() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MÉTODOS DE PAGO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textLabel,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          if (_medios.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'No tenés métodos de pago guardados',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            )
          else
            ..._medios.map(_filaMedio),
          const SizedBox(height: 6),
          InkWell(
            onTap: _agregarMetodo,
            child: const Text(
              '+ Agregar método de pago',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6A0DAD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaMedio(Map<String, dynamic> medio) {
    final tipo = medio['tipo'] == 'debito' ? 'Débito' : 'Crédito';
    final marca = medio['marca'] as String? ?? '';
    final numero = medio['numero'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.credit_card, size: 20, color: Color(0xFF6A0DAD)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$tipo • $marca •••• $numero',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _quitarMetodo(medio),
            tooltip: 'Quitar método de pago',
            icon: const Icon(Icons.delete_outline,
                size: 18, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _infoGroup(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textLabel,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => _cerrarSesion(context),
        icon: const Icon(Icons.logout, color: Color(0xFFE53935)),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE53935),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEB),
          side: const BorderSide(color: Color(0xFFFFCDD2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}