import 'package:flutter/material.dart';

import 'core/network/api_client.dart';

void main() {
  runApp(const FarmayopinApp());
}

class FarmayopinApp extends StatelessWidget {
  const FarmayopinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmayopin',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32))),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _api = ApiClient();
  String _resultado = 'Sin probar aun';
  bool _cargando = false;

  Future<void> _probarConexion() async {
    setState(() {
      _cargando = true;
      _resultado = 'Conectando...';
    });

    try {
      final data = await _api.get('/');
      setState(() {
        _resultado = 'OK: $data';
      });
    } catch (e) {
      setState(() {
        _resultado = 'Error: $e';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmayopin')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: _cargando ? null : _probarConexion,
              child: Text(_cargando ? 'Conectando...' : 'Probar conexion con el backend'),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _resultado,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}