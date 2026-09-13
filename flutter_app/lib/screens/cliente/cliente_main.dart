import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/services/session_manager.dart';
import 'catalogo_screen.dart';
import 'perfil_screen.dart';
import 'carrito_screen.dart';
import 'historial_screen.dart';

class ClienteMain extends StatefulWidget {
  const ClienteMain({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  State<ClienteMain> createState() => _ClienteMainState();
}

class _ClienteMainState extends State<ClienteMain> {
  int _indice = 0;
  int _indiceAnterior = 0;
  int _cantidadCarrito = 0;

  final ApiClient _api = ApiClient();

  static const Color primaryPurple = Color(0xFF6A0DAD);

  @override
  void initState() {
    super.initState();
    _cargarCantidadCarrito();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _cargarCantidadCarrito() async {
    try {
      final token = await SessionManager.token();
      if (token != null) _api.setToken(token);
      final res = await _api.get('/api/carrito');
      final items = (res['items'] as List<dynamic>? ?? []);
      final total = items.fold<int>(
        0,
        (acc, e) => acc + (((e as Map)['cantidad'] as num?)?.toInt() ?? 0),
      );
      if (!mounted) return;
      if (total != _cantidadCarrito) {
        setState(() => _cantidadCarrito = total);
      }
    } catch (_) {
      // Sin conexión: se mantiene el último valor conocido.
    }
  }

  void _cambiarTab(int nuevoIndice) {
    if (nuevoIndice == _indice) return;
    _cargarCantidadCarrito();
    setState(() {
      _indiceAnterior = _indice;
      _indice = nuevoIndice;
    });
  }

  Widget _paginaConKey(int indice) {
    switch (indice) {
      case 1:
        return KeyedSubtree(
          key: const ValueKey<int>(1),
          child: CarritoScreen(usuario: widget.usuario),
        );
      case 2:
        return KeyedSubtree(
          key: const ValueKey<int>(2),
          child: HistorialScreen(usuario: widget.usuario),
        );
      case 3:
        return KeyedSubtree(
          key: const ValueKey<int>(3),
          child: PerfilScreen(usuario: widget.usuario),
        );
      default:
        return KeyedSubtree(
          key: const ValueKey<int>(0),
          child: CatalogoScreen(
            usuario: widget.usuario,
            onCarritoCambio: _cargarCantidadCarrito,
          ),
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
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  fit: StackFit.expand,
                  children: [
                    ...previousChildren,
                    ?currentChild,
                  ],
                ),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: _offsetTransicion(child, animation),
                    child: child,
                  );
                },
                child: _paginaConKey(_indice),
              ),
            ),
            _buildNavBar(),
          ],
        ),
      ),
    );
  }

  Animation<Offset> _offsetTransicion(
      Widget child, Animation<double> animation) {
    final bool entrante =
        (child.key as ValueKey<int>).value == _indice;
    if (!entrante) {
      return Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(animation);
    }
    final double direccion = _indice > _indiceAnterior ? 1.0 : -1.0;
    return Tween<Offset>(
      begin: Offset(direccion, 0),
      end: Offset.zero,
    ).animate(animation);
  }

  Widget _buildNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(0, Icons.local_mall_outlined, 'Productos'),
          _item(1, Icons.shopping_cart_outlined, 'Carrito'),
          _item(2, Icons.history, 'Historial'),
          _item(3, Icons.person, 'Perfil'),
        ],
      ),
    );
  }

  Widget _item(int indice, IconData icono, String label) {
    final bool activo = indice == _indice;
    final Color color = activo ? primaryPurple : const Color(0xFF94A3B8);
    return InkWell(
      onTap: () => _cambiarTab(indice),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconoConBadge(indice, icono, color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconoConBadge(int indice, IconData icono, Color color) {
    final Widget iconoWidget = Icon(icono, color: color, size: 24);

    if (indice != 1 || _cantidadCarrito <= 0) {
      return iconoWidget;
    }

    final String texto = _cantidadCarrito > 99 ? '99+' : '$_cantidadCarrito';

    return SizedBox(
      width: 32,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 4, top: 2, child: iconoWidget),
          Positioned(
            right: 0,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}