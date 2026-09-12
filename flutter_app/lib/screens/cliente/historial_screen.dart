import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/services/local_db.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/utils/formato.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  static const _naranjaMorado = Color(0xFF8B5CF6);
  static const _moradoOscuro = Color(0xFF7E22CE);
  static const _texto = Color(0xFF0F172A);
  static const _gris = Color(0xFF94A3B8);

  final ApiClient _api = ApiClient();

  List<Map<String, dynamic>> _pedidos = [];
  bool _cargando = true;
  bool _modoOffline = false;
  String? _error;
  final Set<int> _expandidos = {};

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _cargarHistorial({bool refrescando = false}) async {
    if (!refrescando) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final datos = await _api.get('/api/mis-compras');
      final items = (datos['pedidos'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _pedidos = items;
        _modoOffline = false;
        if (items.isNotEmpty) {
          _expandidos
            ..clear()
            ..add(_pedidos.first['id'] as int);
        }
        _cargando = false;
      });
    } on ApiNetworkException {
      if (!mounted) return;
      final locales = await LocalDb.pedidosLocales();
      if (!mounted) return;
      if (locales.isEmpty) {
        setState(() {
          _pedidos = [];
          _modoOffline = false;
          _error =
              'No hay conexión a internet y todavía no tenés compras guardadas en este dispositivo.';
          _cargando = false;
        });
      } else {
        setState(() {
          _pedidos = locales;
          _modoOffline = true;
          _error = null;
          _expandidos
            ..clear()
            ..add(_pedidos.first['id'] as int);
          _cargando = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _modoOffline = false;
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  String _formatearFecha(String fecha) {
    if (fecha.length < 10) return fecha;
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    final partes = fecha.split(' ').first.split('-');
    if (partes.length != 3) return fecha;
    final anio = partes[0];
    final mes = int.tryParse(partes[1]) ?? 1;
    final dia = int.tryParse(partes[2]) ?? 1;
    return '$dia ${meses[mes - 1]}, $anio';
  }

  void _alternarExpandido(int id) {
    setState(() {
      if (_expandidos.contains(id)) {
        _expandidos.remove(id);
      } else {
        _expandidos.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Compras',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_pedidos.length} Pedidos',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7E22CE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_modoOffline)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, size: 16, color: Color(0xFFB45309)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sin conexión: mostrando tus compras guardadas en el dispositivo.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _cargarHistorial,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pedidos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.receipt_long, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'Todavía no hiciste compras',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              SizedBox(height: 4),
              Text(
                'Andá al carrito y pagá tu primer pedido',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF8B5CF6),
      onRefresh: () => _cargarHistorial(refrescando: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _pedidos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final pedido = _pedidos[index];
          final id = pedido['id'] as int;
          return _PedidoCard(
            pedido: pedido,
            fecha: _formatearFecha(pedido['fecha'] as String? ?? ''),
            expandido: _expandidos.contains(id),
            onTap: () => _alternarExpandido(id),
          );
        },
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({
    required this.pedido,
    required this.fecha,
    required this.expandido,
    required this.onTap,
  });

  final Map<String, dynamic> pedido;
  final String fecha;
  final bool expandido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final items = (pedido['items'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final total = (pedido['total'] as num?)?.toDouble() ?? 0;
    final cantidad = pedido['cantidad_productos'] as int? ?? items.length;
    final primerNombre = items.isNotEmpty ? items.first['nombre'] as String : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: expandido ? const Color(0xFF8B5CF6) : const Color(0xFFEDF2F7),
            width: expandido ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x05000000), blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #FP-${(pedido['id'] as int).toString().padLeft(4, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  fecha,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            if (expandido) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF1F5F9)),
                    bottom: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
                child: Column(
                  children: items.map((item) {
                    final nombre = item['nombre'] as String? ?? '';
                    final cantidad = item['cantidad'] as int? ?? 1;
                    final subtotal = (item['subtotal'] as num?)?.toDouble() ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '${cantidad}x',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF7E22CE),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    nombre,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatearPrecio(subtotal),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total de Compra',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    formatearPrecio(total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '$cantidad Producto${cantidad != 1 ? 's' : ''} • $primerNombre',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Text(
                    formatearPrecio(total),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}