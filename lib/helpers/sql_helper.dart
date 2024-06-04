import 'package:sqflite/sqflite.dart';

class SqlHelper {
  Database? database;
  Future<bool> createTable() async {
    try {
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
      var result = await batch.commit();
      print("table created");
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
