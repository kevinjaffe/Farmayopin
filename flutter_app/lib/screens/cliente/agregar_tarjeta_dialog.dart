import 'package:flutter/material.dart';

class AgregarTarjetaDialog extends StatefulWidget {
  const AgregarTarjetaDialog({super.key});

  @override
  State<AgregarTarjetaDialog> createState() => _AgregarTarjetaDialogState();
}

class _AgregarTarjetaDialogState extends State<AgregarTarjetaDialog> {
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