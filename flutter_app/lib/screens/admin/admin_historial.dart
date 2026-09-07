import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/services/session_manager.dart';

class AdminHistorial extends StatefulWidget {
  const AdminHistorial({super.key, this.usuario, this.producto});

  final Map<String, dynamic>? usuario;

  /// Si viene el producto, muestra SOLO las ventas de ese producto
  /// (entrando desde "Ver Historial de Ventas" del perfil del producto).
  final Map<String, dynamic>? producto;

  @override
  State<AdminHistorial> createState() => _AdminHistorialState();
}

class _AdminHistorialState extends State<AdminHistorial> {
  final ApiClient _api = ApiClient();

  List<Map<String, dynamic>> _ventas = [];
  bool _cargando = true;
  String? _error;

  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  bool get _esDeProducto => widget.producto != null;

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _cargarVentas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);

      final ruta = _esDeProducto
          ? '/api/ventas/producto/${widget.producto!['id']}'
          : '/api/ventas';

      final res = await _api.get(ruta);
      final ventas = (res['ventas'] as List<dynamic>)
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();

      if (!mounted) return;
      setState(() {
        _ventas = ventas;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
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
          if (_esDeProducto) ...[
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
          ],
          const Text(
            'Historial de Ventas',
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
              onPressed: _cargarVentas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_ventas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              _esDeProducto
                  ? 'Este producto aún no tiene ventas.'
                  : 'Aún no hay ventas registradas.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        if (_esDeProducto) ...[
          _ProductoResumen(producto: widget.producto!),
          const SizedBox(height: 16),
        ],
        ..._ventas.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VentaCard(
                venta: v,
                mostrarProducto: _esDeProducto == false,
              ),
            )),
      ],
    );
  }
}

class _ProductoResumen extends StatelessWidget {
  const _ProductoResumen({required this.producto, this.tamanoImagen = 52});

  final Map<String, dynamic> producto;
  final double tamanoImagen;

  @override
  Widget build(BuildContext context) {
    final foto = producto['foto'];
    final Widget imagen;
    if (foto is String && foto.isNotEmpty) {
      imagen = Image.network(
        '${ApiConstants.baseUrl}/api/productos/foto/$foto',
        fit: BoxFit.cover,
        width: tamanoImagen,
        height: tamanoImagen,
        errorBuilder: (_, _, _) => _iconoProducto(),
      );
    } else {
      imagen = _iconoProducto();
    }

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imagen,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto['nombre'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${_formatearMiles(producto['precio'] ?? 0)}  •  Código: #${producto['id']}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconoProducto() {
    return Container(
      width: tamanoImagen,
      height: tamanoImagen,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.sanitizer, color: Color(0xFF94A3B8), size: 28),
    );
  }
}

class _VentaCard extends StatelessWidget {
  const _VentaCard({required this.venta, required this.mostrarProducto});

  final Map<String, dynamic> venta;
  final bool mostrarProducto;

  @override
  Widget build(BuildContext context) {
    final producto = venta['producto'] as Map<String, dynamic>;
    final cliente = venta['cliente'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mostrarProducto) ...[
            _ProductoResumen(producto: producto, tamanoImagen: 44),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatearFecha(venta['fecha'] as String),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${venta['cantidad']} u.',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Cliente: ',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  children: [
                    TextSpan(
                      text: cliente['nombre'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${_formatearMiles(venta['subtotal'] ?? 0)}',
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
}

String _formatearFecha(String fecha) {
  final meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  final d = DateTime.parse(fecha);
  return '${d.day} ${meses[d.month - 1]} ${d.year}';
}

String _formatearMiles(dynamic valor) {
  final numero = double.parse(valor.toString());
  final texto = numero == numero.roundToDouble()
      ? numero.toStringAsFixed(0)
      : numero.toStringAsFixed(2);

  final partes = texto.split('.');
  final entero = partes[0];
  final buffer = StringBuffer();
  final chars = entero.split('').toList();

  for (var i = 0; i < chars.length; i++) {
    buffer.write(chars[i]);
    final restante = chars.length - 1 - i;
    if (restante > 0 && restante % 3 == 0) buffer.write('.');
  }

  return partes.length > 1 ? '$buffer.${partes[1]}' : buffer.toString();
}