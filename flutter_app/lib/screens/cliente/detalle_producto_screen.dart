import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/utils/formato.dart';

class DetalleProductoScreen extends StatefulWidget {
  const DetalleProductoScreen({super.key, required this.producto});

  final Map<String, dynamic> producto;

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  int _cantidad = 1;

  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  int get _stock => (widget.producto['stock'] ?? 0) as int;
  bool get _enStock => _stock > 0;

  String get _nombre => widget.producto['nombre'] as String;
  String get _descripcion => (widget.producto['descripcion'] ?? '') as String;

  String? get _foto {
    final foto = widget.producto['foto'];
    return foto is String && foto.isNotEmpty ? foto : null;
  }

  void _cambiarCantidad(int delta) {
    setState(() {
      _cantidad = (_cantidad + delta).clamp(1, _enStock ? _stock : 1);
    });
  }

  void _agregarAlCarrito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_cantidad x $_nombre agregado al pedido'),
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagen(),
                    const SizedBox(height: 16),
                    _buildStockBadge(),
                    const SizedBox(height: 8),
                    Text(
                      _nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Código: #${widget.producto['id']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                      child: Text(
                        '\$${formatearPrecio(widget.producto['precio'])}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.chevron_left, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Text(
              'Detalle de Producto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildImagen() {
    if (_foto == null) {
      return Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0E8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.medication, size: 80, color: Color(0xFF94A3B8)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 220,
        color: const Color(0xFFF3F0E8),
        padding: const EdgeInsets.all(12),
        child: Image.network(
          '${ApiConstants.baseUrl}/api/productos/foto/$_foto',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.medication, size: 80, color: Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _enStock ? Icons.check : Icons.close,
            size: 12,
            color: const Color(0xFF7E22CE),
          ),
          const SizedBox(width: 4),
          Text(
            _enStock ? 'EN STOCK' : 'SIN STOCK',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7E22CE),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          _buildQuantitySelector(),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _agregarAlCarrito,
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: const Text('Agregar al Carrito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove, () => _cambiarCantidad(-1)),
          const SizedBox(width: 8),
          Text(
            '$_cantidad',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(width: 8),
          _qtyBtn(Icons.add, () => _cambiarCantidad(1)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icono, VoidCallback onPressed) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icono, size: 16, color: textDark),
        onPressed: onPressed,
      ),
    );
  }
}