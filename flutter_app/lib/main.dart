import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmayopin')),
      body: const Center(child: Text('Bienvenido a Farmayopin')),
    );
  }
}
