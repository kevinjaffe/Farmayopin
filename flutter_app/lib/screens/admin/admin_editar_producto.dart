import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/services/session_manager.dart';

class AdminEditarProducto extends StatefulWidget {
  const AdminEditarProducto({super.key, required this.producto});

  final Map<String, dynamic> producto;

  @override
  State<AdminEditarProducto> createState() => _AdminEditarProductoState();
}

class _AdminEditarProductoState extends State<AdminEditarProducto> {
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;
  late final TextEditingController _stockController;

  final ApiClient _api = ApiClient();
  final ImagePicker _picker = ImagePicker();

  int get _productoId => widget.producto['id'] as int;
  String? get _fotoActual => widget.producto['foto'] as String?;

  Uint8List? _bytesImagenNueva;
  String _mimeImagen = 'image/jpeg';
  String? _nombreImagenNueva;
  bool _cargando = false;

  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLabel = Color(0xFF1E293B);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreController = TextEditingController(text: p['nombre'] as String);
    _descripcionController =
        TextEditingController(text: (p['descripcion'] ?? '') as String);
    _precioController =
        TextEditingController(text: _formatoNumero(p['precio']));
    _stockController = TextEditingController(text: '${p['stock'] ?? 0}');
  }

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
      _bytesImagenNueva = bytes;
      _nombreImagenNueva = xfile.name;
      _mimeImagen = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
    });
  }

  String get _nombreFoto {
    if (_nombreImagenNueva != null) return _nombreImagenNueva!;
    if (_fotoActual != null && _fotoActual!.isNotEmpty) return _fotoActual!;
    return 'Sin foto';
  }

  Future<void> _guardarCambios() async {
    final nombre = _nombreController.text.trim();
    final precio = double.tryParse(_precioController.text.trim());

    if (nombre.isEmpty) {
      _mostrarAviso('Ingresa el nombre del producto');
      return;
    }
    if (precio == null || precio < 0) {
      _mostrarAviso('Ingresa un precio válido');
      return;
    }

    setState(() => _cargando = true);
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);

      final datos = <String, dynamic>{
        'nombre': nombre,
        'descripcion': _descripcionController.text.trim(),
        'precio': precio,
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        if (_bytesImagenNueva != null)
          'foto': 'data:$_mimeImagen;base64,${base64Encode(_bytesImagenNueva!)}',
      };

      final res =
          await _api.put('/api/productos/$_productoId', body: jsonEncode(datos));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado')),
      );
      Navigator.pop(context, res['producto']);
    } catch (e) {
      if (mounted) _mostrarAviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarProducto() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text(
          '¿Seguro que querés eliminar este producto?\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _cargando = true);
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);

      await _api.delete('/api/productos/$_productoId');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado')),
      );
      Navigator.pop(context, 'eliminado');
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
            'Editar Producto',
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
          decoration: _inputDecoration('Nombre del producto'),
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
          decoration: _inputDecoration('Descripción del producto', alignTop: true),
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              _fotoBox(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nombreFoto,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: _subirFoto,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera, size: 18, color: primaryPurple),
                          SizedBox(width: 4),
                          Text(
                            'Cambiar foto',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fotoBox() {
    final Widget imagen;
    if (_bytesImagenNueva != null) {
      imagen = Image.memory(_bytesImagenNueva!, fit: BoxFit.cover);
    } else if (_fotoActual != null && _fotoActual!.isNotEmpty) {
      imagen = Image.network(
        '${ApiConstants.baseUrl}/api/productos/foto/$_fotoActual',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _iconoFoto(),
      );
    } else {
      imagen = _iconoFoto();
    }

    return Container(
      width: 64,
      height: 64,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: imagen,
    );
  }

  Widget _iconoFoto() {
    return const Icon(Icons.sanitizer, color: Color(0xFFCBD5E1), size: 32);
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(color: Color(0xFFF8F9FA)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _cargando ? null : _guardarCambios,
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
                _cargando ? 'Guardando...' : 'Guardar Cambios',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _cargando ? null : _eliminarProducto,
            child: const Text(
              'Eliminar Producto',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
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

String _formatoNumero(dynamic valor) {
  final numero = double.parse(valor.toString());
  return numero == numero.roundToDouble()
      ? numero.toStringAsFixed(0)
      : numero.toStringAsFixed(2);
}