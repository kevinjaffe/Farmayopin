import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'local_db.dart';

class SessionManager {
  static Future<void> guardar(String token, Map<String, dynamic> usuario) async {
    final db = await LocalDb.database;
    await db.insert(
      'sesion',
      {'id': 1, 'token': token, 'usuario': jsonEncode(usuario)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> token() async {
    final db = await LocalDb.database;
    final rows = await db.query('sesion', where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['token'] as String?;
  }

  static Future<Map<String, dynamic>?> usuario() async {
    final db = await LocalDb.database;
    final rows = await db.query('sesion', where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['usuario'] as String) as Map<String, dynamic>;
  }

  static Future<void> cerrar() async {
    final db = await LocalDb.database;
    await db.delete('sesion', where: 'id = 1');
  }
}