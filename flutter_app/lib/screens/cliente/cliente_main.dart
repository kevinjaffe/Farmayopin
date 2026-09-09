import 'package:flutter/material.dart';

import 'catalogo_screen.dart';
import 'perfil_screen.dart';
import 'carrito_screen.dart';

class ClienteMain extends StatefulWidget {
  const ClienteMain({super.key, required this.usuario});

  final Map<String, dynamic> usuario;

  @override
  State<ClienteMain> createState() => _ClienteMainState();
}

class _ClienteMainState extends State<ClienteMain> {
  int _indice = 0;
  int _indiceAnterior = 0;

  static const Color primaryPurple = Color(0xFF6A0DAD);

  void _cambiarTab(int nuevoIndice) {
    if (nuevoIndice == _indice) return;
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
          child: const _TabPlaceholder(titulo: 'Historial'),
        );
        case 3:
        return KeyedSubtree(
          key: const ValueKey<int>(3),
          child: PerfilScreen(usuario: widget.usuario),
        );
      default:
        return KeyedSubtree(
          key: const ValueKey<int>(0),
          child: CatalogoScreen(usuario: widget.usuario),
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
            Icon(icono, color: color, size: 24),
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
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction,
                  size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(
                '$titulo — próximamente',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}