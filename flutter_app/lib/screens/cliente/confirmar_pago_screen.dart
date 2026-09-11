import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/services/session_manager.dart';
import '../../core/utils/formato.dart';

class ConfirmarPagoScreen extends StatefulWidget {
  const ConfirmarPagoScreen({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  State<ConfirmarPagoScreen> createState() => _ConfirmarPagoScreenState();
}

class _ConfirmarPagoScreenState extends State<ConfirmarPagoScreen> {
  static const Color violeta = Color(0xFF7E22CE);
  static const Color violetaOscuro = Color(0xFF6B21A8);
  static const Color texto = Color(0xFF0F172A);

  final ApiClient _api = ApiClient();

  List<Map<String, dynamic>> _items = [];
  double _total = 0;
  List<Map<String, dynamic>> _medios = [];
  int? _medioSeleccionado;
  bool _cargando = true;
  bool _procesando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _cargarTodo() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);

      final res = await _api.get('/api/carrito');
      final items = (res['items'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final mediosRes = await _api.get('/api/medios-pago');
      final medios = (mediosRes['medios_pago'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      if (!mounted) return;
      setState(() {
        _items = items;
        _total = (res['total'] as num?)?.toDouble() ?? 0;
        _medios = medios;
        if (medios.isNotEmpty &&
            !medios.any((m) => m['id'] == _medioSeleccionado)) {
          _medioSeleccionado = medios.first['id'] as int;
        }
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

  Future<void> _confirmarPago() async {
    if (_medioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná o agregá un método de pago')),
      );
      return;
    }
    setState(() => _procesando = true);
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final res = await _api.post('/api/carrito/pagar');
      if (!mounted) return;
      setState(() => _procesando = false);
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Compra realizada!'),
          content: Text('Pago confirmado por \$${formatearMiles(res['total'])}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _agregarTarjeta() async {
    final datos = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AgregarTarjetaDialog(),
    );
    if (datos == null) return;

    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final res = await _api.post('/api/medios-pago', body: jsonEncode(datos));
      if (!mounted) return;
      final nuevo = Map<String, dynamic>.from(res['medio'] as Map);
      setState(() {
        _medios.insert(0, nuevo);
        _medioSeleccionado = nuevo['id'] as int;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _contenido()),
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        children: [
          InkWell(
            onTap: _procesando ? null : () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 14, color: texto),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Confirmar Pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: texto)),
        ],
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: violeta));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _cargarTodo,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('Tu carrito está vacío', style: TextStyle(color: Color(0xFF64748B))),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      children: [
        _cardResumen(),
        const SizedBox(height: 16),
        _cardMetodoPago(),
      ],
    );
  }

  Widget _cardResumen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2F7)),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen del pedido', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: texto)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Column(
              children: _items.map((item) {
                final nombre = item['nombre'] as String? ?? '';
                final cantidad = item['cantidad'] as int? ?? 1;
                final subtotal = (item['subtotal'] as num?)?.toDouble() ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${cantidad}x $nombre',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8)),
                        ),
                      ),
                      Text(
                        '\$${formatearMiles(subtotal)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: texto),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Importe Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: texto)),
              Text('\$${formatearMiles(_total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: violeta)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardMetodoPago() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Método de Pago', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: texto)),
          const SizedBox(height: 12),
          if (_medios.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'No tenés métodos de pago guardados',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            )
          else
            ..._medios.map((medio) => _tarjetaMedio(medio)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: _agregarTarjeta,
              child: const Text('Agregar método de pago', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: violeta)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaMedio(Map<String, dynamic> medio) {
    final seleccionada = medio['id'] == _medioSeleccionado;
    final tipo = medio['tipo'] == 'debito' ? 'Tarjeta de Débito' : 'Tarjeta de Crédito';
    final marca = medio['marca'] as String? ?? '';
    final numero = medio['numero'] as String? ?? '';
    final sigla = marca.length >= 4 ? marca.substring(0, 4).toUpperCase() : marca.toUpperCase();

    return InkWell(
      onTap: () => setState(() => _medioSeleccionado = medio['id'] as int),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: violeta, borderRadius: BorderRadius.circular(4)),
              child: Text(sigla, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tipo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: texto)),
                  const SizedBox(height: 2),
                  Text(
                    '$marca terminado en **** $numero',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: seleccionada ? violeta : Colors.transparent,
                border: Border.all(color: seleccionada ? violeta : const Color(0xFFCBD5E1), width: 1.5),
              ),
              child: seleccionada
                  ? const Center(child: Icon(Icons.circle, size: 6, color: Colors.white))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _procesando ? null : _confirmarPago,
              icon: const Icon(Icons.check, size: 18),
              label: Text(_procesando ? 'Procesando...' : 'Confirmar Pago'),
              style: ElevatedButton.styleFrom(
                backgroundColor: violetaOscuro,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          TextButton(
            onPressed: _procesando ? null : () => Navigator.of(context).pop(),
            child: const Text('Volver al carrito', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }
}

class _AgregarTarjetaDialog extends StatefulWidget {
  const _AgregarTarjetaDialog();

  @override
  State<_AgregarTarjetaDialog> createState() => _AgregarTarjetaDialogState();
}

class _AgregarTarjetaDialogState extends State<_AgregarTarjetaDialog> {
  static const List<String> _marcas = ['Visa', 'Mastercard', 'Otra'];

  final _formKey = GlobalKey<FormState>();
  final _numeroCtrl = TextEditingController();
  final _titularCtrl = TextEditingController();
  final _vencCtrl = TextEditingController();

  String _tipo = 'credito';
  String _marca = 'Visa';

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _titularCtrl.dispose();
    _vencCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'tipo': _tipo,
      'marca': _marca,
      'numero': _numeroCtrl.text.replaceAll(' ', ''),
      'titular': _titularCtrl.text,
      'vencimiento': _vencCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar método de pago'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'credito', label: Text('Crédito')),
                  ButtonSegment(value: 'debito', label: Text('Débito')),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) => setState(() => _tipo = s.first),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _marca,
                decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()),
                items: _marcas.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _marca = v ?? 'Visa'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numeroCtrl,
                keyboardType: TextInputType.number,
                maxLength: 19,
                decoration: const InputDecoration(labelText: 'Número de tarjeta', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.replaceAll(' ', '').length < 13) ? 'Ingresá un número válido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titularCtrl,
                decoration: const InputDecoration(labelText: 'Titular', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresá el titular' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vencCtrl,
                decoration: const InputDecoration(labelText: 'Vencimiento (MM/AA)', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || !RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v.trim()))
                        ? 'Formato MM/AA'
                        : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _guardar,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6B21A8)),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}