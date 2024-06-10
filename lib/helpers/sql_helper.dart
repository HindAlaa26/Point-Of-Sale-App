import 'package:sqflite/sqflite.dart';

class SqlHelper {
  Database? database;
  Future<void> registerForeignKeys() async {
    await database!.rawQuery('PRAGMA foreign_keys = on');
    var result = await database!.rawQuery('PRAGMA foreign_keys');

    print(result);
  }

  Future<bool> createTable() async {
    try {
      await registerForeignKeys();
      var batch = database!.batch();
      batch.execute("""
      Create table If not exists categories(
      id integer primary key,
      name text,
      description text
      )""");
      batch.execute("""
      Create table If not exists products(
      id integer primary key,
      name text,
      description text,
      price double,
      stock integer,
      isAvailable boolean,
      image text,
      categoryId integer,
      foreign key(categoryId) references categories(id)
      ON Delete restrict
      )""");
      batch.execute("""
      Create table If not exists clients(
      id integer primary key,
      name text,
      email text,
      phone text,
      address text
      )""");
      batch.execute("""
      Create table If not exists orders(
      id integer primary key,
      label text,
      totalPrice real,
      discount real,
      clientId integer ,
      foreign key(clientId) references clients(id)
      ON Delete restrict
      )""");
      batch.execute("""
      Create table If not exists orderProductItems(
      orderId Integer,
      productCount Integer,
      productId Integer,
      foreign key(productId) references products(id)
      ON Delete restrict
      )""");
      var result = await batch.commit();
      print("table created");
      print("table created Result : $result");
      return true;
    } catch (e) {
      print('Error when creating table ${e.toString()}');
      return false;
    }
  }

  Future<void> createDatabase() async {
    database = await openDatabase(
      'POS.db',
      version: 1,
      onCreate: (db, version) {
        print("database created");
      },
      onOpen: (db) {
        print("database opened");
      },
    );
  }

  Future<double> getTodaySales() async {
    final db = database;
    // final today = DateTime.now();
    // final startOfDay =
    //     DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    // final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
    //     .millisecondsSinceEpoch;
    // 'SELECT SUM(totalPrice) as totalSales FROM orders WHERE timestamp BETWEEN ? AND ?',
    // [startOfDay, endOfDay],
    final result =
        await db?.rawQuery('SELECT SUM(totalPrice) as totalSales FROM orders ');

    if (result!.isNotEmpty) {
      return result.first['totalSales'] as double? ?? 0.0;
    } else {
      return 0.0;
    }
  }
}
