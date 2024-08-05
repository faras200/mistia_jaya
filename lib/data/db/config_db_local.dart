import 'package:sqflite/sqflite.dart';

class ConfigDbLocal {
  ConfigDbLocal();

  final String tableProducts = 'products';
  final String tableOrders = 'orders';
  final String tableOrderItems = 'order_items';
  final String tableDeposits = 'deposits';
  static Database? _database;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        name TEXT,
        harga INTEGER,
        berat INTEGER,
        image TEXT,
        discount INTEGER,
        category TEXT,
        is_best_seller INTEGER,
        is_sync INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableOrders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        qris TEXT,
        nominal INTEGER,
        bayar INTEGER,
        payment_method TEXT,
        total_item INTEGER,
        id_kasir INTEGER,
        nama_kasir TEXT,
        transaction_time TEXT,
        is_deposit INTEGER DEFAULT 0,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrderItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('pos11.db');

    return _database!;
  }

  // ignore: non_constant_identifier_names
  Future<dynamic> addColumn(String TableName, String ColumneName) async {
    var dbClient = await database;
    var count = await dbClient
        .execute("ALTER TABLE $TableName ADD COLUMN $ColumneName;");
    // print(await dbClient.query(TABLE_CUSTOMER));
    return count;
  }

  Future<bool> checkIfColumnExists(
      Database db, String tableName, String columnName) async {
    // Getting the table info
    final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');

    // Checking if the column exists by looking for it in the table info
    for (var column in tableInfo) {
      if (column['name'] == columnName) {
        return true; // Column exists
      }
    }
    return false; // Column does not exist
  }
}
