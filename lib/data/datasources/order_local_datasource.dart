import 'package:flutter_pos_app/data/db/config_db_local.dart';
import 'package:flutter_pos_app/presentation/order/models/order_model.dart';
import 'package:logger/logger.dart';
import 'package:flutter_pos_app/data/models/request/order_request_model.dart';

import '../../presentation/home/models/order_item.dart';

class OrderLocalDatasource {
  OrderLocalDatasource._init();
  static final ConfigDbLocal instanceDb = ConfigDbLocal();
  static final OrderLocalDatasource instance = OrderLocalDatasource._init();

  final String tableOrders = instanceDb.tableOrders;
  final String tableOrderItems = instanceDb.tableOrderItems;
  //save order
  Future<int> saveOrder(OrderModel order) async {
    var db = await instanceDb.database;
    int id = await db.insert(tableOrders, order.toMapForLocal());

    // var tables = await db.rawQuery('SELECT discount FROM $tableOrderItems');

    bool columnExists =
        await instanceDb.checkIfColumnExists(db, tableOrderItems, 'discount');

    if (!columnExists) {
      instanceDb.addColumn(tableOrderItems, 'discount INTEGER DEFAULT 0');

      db = await instanceDb.database;
    }

    for (var orderItem in order.orders) {
      await db.insert(tableOrderItems, orderItem.toMapForLocal(id));
    }
    return id;
  }

  //get order by isSync = 0
  Future<List<OrderModel>> getOrderByIsSync() async {
    final db = await instanceDb.database;
    final result = await db.query(tableOrders, where: 'is_sync = 0');

    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get order item by id order local
  Future<List<OrderItemModel>> getOrderItemByOrderIdLocal(int idOrder) async {
    final db = await instanceDb.database;
    final result =
        await db.query(tableOrderItems, where: 'id_order = $idOrder');

    return result.map((e) => OrderItem.fromMapLocal(e)).toList();
  }

  //   Future<List<OrderItemModel>> getOrderItemByOrderIdLocal(int idOrder) async {
  //   final db = await instance.database;
  //   final result = await db.query('order_items', where: 'id_order = $idOrder');

  //   return result.map((e) => OrderItem.fromMapLocal(e)).toList();
  // }

  //update isSync order by id
  Future<int> updateIsSyncOrderById(int id) async {
    final db = await instanceDb.database;
    return await db.update(tableOrders, {'is_sync': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  //get all orders
  Future<List<OrderModel>> getAllOrder() async {
    final db = await instanceDb.database;
    final result = await db.query(tableOrders, orderBy: 'id DESC');

    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get all by date
  Future<List<OrderModel>> getByDate(String fromDate, String toDate) async {
    final db = await instanceDb.database;

    final result = await db.rawQuery(
        "SELECT * FROM $tableOrders where transaction_time >= '$fromDate' and transaction_time <= '$toDate' ORDER BY id DESC ");

    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get all by filter
  Future<List<OrderModel>> getByFilter(
      List jenis, List bayar, String fromDate, String toDate) async {
    final db = await instanceDb.database;
    String paymentMethods = bayar.map((method) => "'$method'").join(', ');
    String category = jenis.map((method) => "'$method'").join(', ');

    // Membangun query
    String query = """
      SELECT $tableOrders.* 
      FROM $tableOrders 
      LEFT JOIN $tableOrderItems ON $tableOrders.id = $tableOrderItems.id_order
      LEFT JOIN products ON $tableOrderItems.id_product = products.product_id 
      WHERE 1=1 
    """;

    // Menambahkan kondisi payment method jika tidak kosong
    if (bayar.isNotEmpty) {
      query += " AND $tableOrders.payment_method IN ($paymentMethods) ";
    }

    // Menambahkan kondisi kategori jika tidak kosong
    if (jenis.isNotEmpty) {
      query += " AND products.category IN ($category) ";
    }

    // Menambahkan kondisi tanggal
    query += """
      AND $tableOrders.transaction_time >= ? 
      AND $tableOrders.transaction_time <= ? 
      GROUP BY $tableOrders.id
      ORDER BY $tableOrders.id DESC
    """;

    // Eksekusi query dengan parameter binding untuk tanggal
    final result = await db.rawQuery(query, [fromDate, toDate]);
    Logger().d(result);
    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get all orders tunai
  Future<List<OrderModel>> getOrderTunai() async {
    final db = await instanceDb.database;
    final result = await db.query(tableOrders,
        where: "payment_method = 'Tunai' AND is_sync = 1 AND is_deposit = 0");

    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get order item by id order
  Future<List<OrderItem>> getOrderItemByOrderId(int idOrder) async {
    final db = await instanceDb.database;
    final result = await db.query(tableOrderItems);

    return result.map((e) => OrderItem.fromMap(e)).toList();
  }

  //update isDeposit order by id
  Future<int> updateIsDepositOrderById(int id) async {
    final db = await instanceDb.database;
    return await db.update(tableOrders, {'is_deposit': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteOrderById(List uuid) async {
    final db = await instanceDb.database;
    return await db.delete(tableOrders,
        where: 'id IN (${List.filled(uuid.length, '?').join(',')})',
        whereArgs: uuid);
  }
}
