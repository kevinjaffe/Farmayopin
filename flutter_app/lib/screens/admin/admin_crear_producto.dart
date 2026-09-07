import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_client.dart';
import '../../core/services/session_manager.dart';

class AdminCrearProducto extends StatefulWidget {
  const AdminCrearProducto({super.key});

  @override
  State<AdminCrearProducto> createState() => _AdminCrearProductoState();
}

class _AdminCrearProductoState extends State<AdminCrearProducto> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  final ApiClient _api = ApiClient();
  final ImagePicker _picker = ImagePicker();
  bool _cargando = false;

  Uint8List? _bytesImagen;
  String _mimeImagen = 'image/jpeg';

  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLabel = Color(0xFF1E293B);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void dispose() {
    _api.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _subirFoto() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();
    final ext = xfile.name.toLowerCase().split('.').last;
    setState(() {
      _bytesImagen = bytes;
      _mimeImagen = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
    });
  }

  Future<void> _guardarProducto() async {
    if (_nombreController.text.trim().isEmpty) {
      _mostrarAviso('Ingresa el nombre del producto');
      return;
    }

    final precio = double.tryParse(_precioController.text.trim());
    if (precio == null || precio < 0) {
      _mostrarAviso('Ingresa un precio válido');
      return;
    }

    if (_bytesImagen != null && _bytesImagen!.length > 5 * 1024 * 1024) {
      _mostrarAviso('La imagen no puede superar los 5MB');
      return;
    }

    setState(() => _cargando = true);
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);

      final datos = <String, dynamic>{
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio': precio,
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        if (_bytesImagen != null)
          'foto': 'data:$_mimeImagen;base64,${base64Encode(_bytesImagen!)}',
      };

      await _api.post('/api/productos', body: jsonEncode(datos));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Producto "${_nombreController.text.trim()}" creado'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _mostrarAviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
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
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCampoNombre(),
                    const SizedBox(height: 16),
                    _buildCampoDescripcion(),
                    const SizedBox(height: 16),
                    _buildFilaPrecioStock(),
                    const SizedBox(height: 16),
                    _buildCampoFoto(),
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
            'Crear Producto',
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

  Widget _campoLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textLabel,
      ),
    );
  }

  Widget _buildCampoNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _campoLabel('Nombre del Producto'),
        const SizedBox(height: 8),
        TextField(
          controller: _nombreController,
          decoration: _inputDecoration('Dermaglós Crema Hidratante'),
        ),
      ],
    );
  }

  Widget _buildCampoDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _campoLabel('Descripción'),
        const SizedBox(height: 8),
        TextField(
          controller: _descripcionController,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.top,
          decoration: _inputDecoration(
            'Fórmula única para pieles sensibles...',
            alignTop: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFilaPrecioStock() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _campoLabel('Precio (\$)'),
              const SizedBox(height: 8),
              TextField(
                controller: _precioController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration('650'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _campoLabel('Cantidad en Stock'),
              const SizedBox(height: 8),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('8'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampoFoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _campoLabel('Foto del Producto'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _subirFoto,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryPurple, width: 1.5),
            ),
            child: _bytesImagen == null ? _vistaElegir() : _vistaPrevia(),
          ),
        ),
      ],
    );
  }

  Widget _vistaElegir() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_camera, color: primaryPurple, size: 32),
        SizedBox(height: 6),
        Text(
          'Subir o tomar foto',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: primaryPurple,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Solo formatos JPG, PNG de hasta 5MB',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _vistaPrevia() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_bytesImagen!, fit: BoxFit.contain),
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Cambiar',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(color: Color(0xFFF8F9FA)),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _cargando ? null : _guardarProducto,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: primaryPurple.withValues(alpha: 0.2),
          ),
          child: Text(
            _cargando ? 'Guardando...' : 'Guardar Producto',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {bool alignTop = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryPurple, width: 1.5),
      ),
    );
  }
}