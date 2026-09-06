import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'farmayopin.db'),
      version: 2,
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
  }
}