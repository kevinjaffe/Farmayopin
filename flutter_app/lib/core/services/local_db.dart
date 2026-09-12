import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class LocalDb {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'farmayopin.db'),
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sesion (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        token TEXT NOT NULL,
        usuario TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE compras_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        total REAL NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE compra_items_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        compra_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (compra_id) REFERENCES compras_local(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE ventas_sync (
        id INTEGER PRIMARY KEY,
        datos TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ventas_sync_meta (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        sincronizado_en TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sesion (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          token TEXT NOT NULL,
          usuario TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ventas_sync (
          id INTEGER PRIMARY KEY,
          datos TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ventas_sync_meta (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          sincronizado_en TEXT NOT NULL
        )
      ''');
    }
  }

  static String fechaLocalAhora() {
    final now = DateTime.now();

    String dos(int v) => v.toString().padLeft(2, '0');

    return '${now.year}-${dos(now.month)}-${dos(now.day)} ${dos(now.hour)}:${dos(now.minute)}:${dos(now.second)}';
  }

  static Future<int> guardarCompraLocal({
    required int serverId,
    required double total,
    required String fecha,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await LocalDb.database;

    final compraId = await db.insert('compras_local', {
      'server_id': serverId,
      'total': total,
      'fecha': fecha,
    });

    for (final item in items) {
      final subtotal = (item['subtotal'] as num?)?.toDouble() ?? 0;
      await db.insert('compra_items_local', {
        'compra_id': compraId,
        'producto_id': (item['producto_id'] as num?)?.toInt() ?? 0,
        'nombre': (item['nombre'] as String?) ?? 'Producto',
        'cantidad': (item['cantidad'] as num?)?.toInt() ?? 1,
        'precio_unitario':
            (item['precio'] as num?)?.toDouble() ?? subtotal,
        'subtotal': subtotal,
      });
    }

    return compraId;
  }

  static Future<List<Map<String, dynamic>>> pedidosLocales() async {
    final db = await LocalDb.database;

    final pedidos = await db.query('compras_local', orderBy: 'id DESC');

    final resultado = <Map<String, dynamic>>[];
    for (final pedido in pedidos) {
      final id = pedido['id'] as int;

      final itemsRows = await db.query(
        'compra_items_local',
        where: 'compra_id = ?',
        whereArgs: [id],
        orderBy: 'id ASC',
      );

      final items = itemsRows.map((r) {
        return <String, dynamic>{
          'producto_id': r['producto_id'] as int,
          'nombre': r['nombre'] as String,
          'cantidad': r['cantidad'] as int,
          'subtotal': (r['subtotal'] as num).toDouble(),
        };
      }).toList();

      resultado.add({
        'id': id,
        'server_id': pedido['server_id'] as int?,
        'total': (pedido['total'] as num).toDouble(),
        'fecha': pedido['fecha'] as String,
        'cantidad_productos': items.length,
        'items': items,
      });
    }

    return resultado;
  }

  static Future<void> sincronizarVentas(
    List<Map<String, dynamic>> ventas,
  ) async {
    final db = await LocalDb.database;

    await db.transaction((txn) async {
      await txn.delete('ventas_sync');
      for (final v in ventas) {
        await txn.insert('ventas_sync', {
          'id': v['id'] as int,
          'datos': jsonEncode(v),
        });
      }
      await txn.insert(
        'ventas_sync_meta',
        {'id': 1, 'sincronizado_en': LocalDb.fechaLocalAhora()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<List<Map<String, dynamic>>> ventasLocales() async {
    final db = await LocalDb.database;

    final rows = await db.query('ventas_sync', orderBy: 'id ASC');

    return rows
        .map((r) =>
            jsonDecode(r['datos'] as String) as Map<String, dynamic>)
        .toList();
  }

  static Future<String?> ultimaSincronizacionVentas() async {
    final db = await LocalDb.database;

    final rows = await db.query('ventas_sync_meta', where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['sincronizado_en'] as String?;
  }

  static Future<void> borrarHistorialLocal() async {
    final db = await LocalDb.database;

    await db.transaction((txn) async {
      await txn.delete('compra_items_local');
      await txn.delete('compras_local');
      await txn.delete('ventas_sync');
      await txn.delete('ventas_sync_meta');
    });
  }
}