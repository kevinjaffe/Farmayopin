import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import 'admin_editar_producto.dart';
import 'admin_historial.dart';

class AdminProductoDetalle extends StatefulWidget {
  const AdminProductoDetalle({super.key, required this.producto});

  final Map<String, dynamic> producto;

  @override
  State<AdminProductoDetalle> createState() => _AdminProductoDetalleState();
}

class _AdminProductoDetalleState extends State<AdminProductoDetalle> {
  late Map<String, dynamic> _producto = widget.producto;

  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  String get _nombre => _producto['nombre'] as String;

  int get _stock => (_producto['stock'] ?? 0) as int;

  String? get _foto {
    final foto = _producto['foto'];
    return foto is String && foto.isNotEmpty ? foto : null;
  }

  String? get _subtitulo {
    final s = _producto['subtitulo'];
    return s is String && s.isNotEmpty ? s : null;
  }

  String get _descripcion => (_producto['descripcion'] ?? '') as String;

  Future<void> _editar() async {
    final resultado = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEditarProducto(producto: _producto),
      ),
    );

    if (!mounted) return;

    if (resultado == 'eliminado') {
      Navigator.pop(context);
      return;
    }

    if (resultado is Map<String, dynamic>) {
      setState(() => _producto = resultado);
    }
  }

  void _verHistorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminHistorial(producto: _producto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagen(),
                    const SizedBox(height: 16),
                    const SizedBox(height: 8),
                    Text(
                      _nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        height: 1.2,
                      ),
                    ),
                    if (_subtitulo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _subtitulo!,
                        style: const TextStyle(fontSize: 13, color: textMuted),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      '\$${_formatearPrecio(_producto['precio'])}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.only(bottom: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEDF2F7)),
                        ),
                      ),
                      child: _inventarioCard(),
                    ),
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _descripcion.isEmpty ? 'Sin descripción' : _descripcion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.chevron_left, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Vista administrador',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagen() {
    if (_foto == null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F1E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.sanitizer, size: 80, color: Color(0xFF94A3B8)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 200,
        color: const Color(0xFFF3F1E9),
        child: Image.network(
          '${ApiConstants.baseUrl}/api/productos/foto/$_foto',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.sanitizer, size: 80, color: Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }



  Widget _inventarioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventario',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$_stock Unidades disponibles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _stock == 0 ? const Color(0xFFDC2626) : textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _editar,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryPurple,
                side: const BorderSide(color: primaryPurple, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Editar Datos de Producto',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _verHistorial,
            child: const Text(
              'Ver Historial de Ventas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatearPrecio(dynamic valor) {
  final numero = double.parse(valor.toString());
  return numero == numero.roundToDouble()
      ? numero.toStringAsFixed(0)
      : numero.toStringAsFixed(2);
}