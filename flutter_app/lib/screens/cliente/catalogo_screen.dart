import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/services/session_manager.dart';
import '../../core/utils/formato.dart';
import 'detalle_producto_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final ApiClient _api = ApiClient();
  final TextEditingController _filtroController = TextEditingController();

  List<Map<String, dynamic>> _productos = [];
  bool _cargando = true;
  String? _error;

  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color textDark = Color(0xFF0F172A);

  List<Map<String, dynamic>> get _productosFiltrados {
    final q = _filtroController.text.toLowerCase().trim();
    if (q.isEmpty) return _productos;
    return _productos
        .where((p) => (p['nombre'] as String).toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _api.dispose();
    _filtroController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final res = await _api.get('/api/productos');
      final productos = (res['productos'] as List<dynamic>)
          .map((p) => Map<String, dynamic>.from(p as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _productos = productos;
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

  void _abrirDetalle(Map<String, dynamic> producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleProductoScreen(producto: producto),
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
            const SizedBox(height: 4),
            _buildSearchBox(),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
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
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _cargarProductos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final productos = _productosFiltrados;

    if (productos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              _productos.isEmpty
                  ? 'No hay productos disponibles aún.'
                  : 'Sin resultados para tu búsqueda',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: productos.length,
      itemBuilder: (_, i) {
        final p = productos[i];
        return _ProductoCard(producto: p, onTap: () => _abrirDetalle(p));
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Medicamentos destacados',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.notifications_none,
                color: Color(0xFF0F172A), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _filtroController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Buscar medicamentos, cremas, etc...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14, color: textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  const _ProductoCard({required this.producto, this.onTap});

  final Map<String, dynamic> producto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDF2F7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imagen(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto['nombre'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (producto['descripcion'] ?? '') as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${formatearPrecio(producto['precio'])}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagen() {
    final foto = producto['foto'];
    if (foto is String && foto.isNotEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        color: const Color(0xFFF1F5F9),
        padding: const EdgeInsets.all(8),
        child: Image.network(
          '${ApiConstants.baseUrl}/api/productos/foto/$foto',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.medication, color: Color(0xFFCBD5E1), size: 32),
          ),
        ),
      );
    }
    return Container(
      height: 120,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.medication, color: Color(0xFFCBD5E1), size: 32),
      ),
    );
  }
}