import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/services/session_manager.dart';
import '../../core/utils/formato.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final ApiClient _api = ApiClient();

  List<Map<String, dynamic>> _items = [];
  double _total = 0;
  bool _cargando = true;
  bool _procesando = false;
  String? _error;

  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _cargarCarrito() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final res = await _api.get('/api/carrito');
      final items = (res['items'] as List<dynamic>)
          .map((i) => Map<String, dynamic>.from(i as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _items = items;
        _total = (res['total'] as num).toDouble();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  Future<void> _cambiarCantidad(Map<String, dynamic> item, int delta) async {
    final nueva = (item['cantidad'] as int) + delta;
    if (nueva < 1 || nueva > (item['stock'] as int)) return;

    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      await _api.put(
        '/api/carrito/${item['id']}',
        body: jsonEncode({'cantidad': nueva}),
      );
      await _cargarCarrito();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _eliminarItem(Map<String, dynamic> item) async {
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      await _api.delete('/api/carrito/${item['id']}');
      await _cargarCarrito();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _pagar() async {
    setState(() => _procesando = true);
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final res = await _api.post('/api/carrito/pagar');
      if (!mounted) return;
      setState(() => _procesando = false);
      await _cargarCarrito();
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Compra realizada!'),
          content: Text('Total: \$${formatearMiles(res['total'])}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            if (_items.isNotEmpty) _buildCheckout(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tu Carrito',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_items.length} Producto${_items.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7E22CE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: primaryPurple),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textMuted, fontSize: 14),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _cargarCarrito,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Agregá productos desde el catálogo',
              style: TextStyle(fontSize: 13, color: textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CarritoItemCard(
        item: _items[i],
        onRestar: () => _cambiarCantidad(_items[i], -1),
        onSumar: () => _cambiarCantidad(_items[i], 1),
        onEliminar: () => _eliminarItem(_items[i]),
      ),
    );
  }

  Widget _buildCheckout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              Text(
                '\$${formatearMiles(_total)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _procesando ? null : _pagar,
              icon: const Icon(Icons.payment, size: 18),
              label: Text(_procesando ? 'Procesando...' : 'Pagar'),
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
        ],
      ),
    );
  }
}

class _CarritoItemCard extends StatelessWidget {
  const _CarritoItemCard({
    required this.item,
    required this.onRestar,
    required this.onSumar,
    required this.onEliminar,
  });

  final Map<String, dynamic> item;
  final VoidCallback onRestar;
  final VoidCallback onSumar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nombre'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Precio unitario: \$${formatearPrecio(item['precio'])}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Color(0xFFEF4444)),
                  onPressed: onEliminar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    _qtyBtn(Icons.remove, onRestar),
                    const SizedBox(width: 8),
                    Text(
                      '${item['cantidad']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _qtyBtn(Icons.add, onSumar),
                  ],
                ),
              ),
              Text(
                '\$${formatearPrecio(item['subtotal'])}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icono, VoidCallback onPressed) {
    return SizedBox(
      width: 26,
      height: 26,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icono, size: 14, color: const Color(0xFF0F172A)),
        onPressed: onPressed,
      ),
    );
  }
}