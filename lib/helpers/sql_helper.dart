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
}
