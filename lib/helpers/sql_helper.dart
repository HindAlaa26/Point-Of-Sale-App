import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      batch.execute("""
      Create table If not exists exChargeRate(
      id integer primary key,
      currencyFrom TEXT,
      currencyTo TEXT,
      rate REAL
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
    final result =
        await db?.rawQuery('SELECT SUM(totalPrice) as totalSales FROM orders ');

    if (result!.isNotEmpty) {
      return result.first['totalSales'] as double? ?? 0.0;
    } else {
      return 0.0;
    }
  }

  Future<double> getExchangeRate(String from, String to) async {
    try {
      final result = await database?.query(
        'exChargeRate',
        where: 'currencyFrom = ? AND currencyTo = ?',
        whereArgs: [from, to],
      );
      if (result != null && result.isNotEmpty) {
        return result.first['rate'] as double;
      } else {
        return 1.0; // Default to 1.0 if no rate is found
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
      return 1.0; // Default to 1.0 in case of error
    }
  }

  // Insert static data into exchangeRates table
  Future<void> insertInitialData() async {
    final db = database;
    await db?.insert('exChargeRate', {
      'currencyFrom': 'USD',
      'currencyTo': 'EGP',
      'rate': 50.0,
    });
  }

  Future<void> backupDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      const databaseName = 'POS.db';
      final databaseFilePath = join(databasePath, databaseName);
      print("databaseFilePath>>>>>>>>>>>>>>>>>>>>>>$databaseFilePath");
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final backupDirectory = join(documentsDirectory.path, 'database_backups');
      print("backupDirectory>>>>>>>>>>>>>>>>>>>>>>$backupDirectory");
      await Directory(backupDirectory).create(recursive: true);

      final backupFilePath = join(backupDirectory, databaseName);
      await File(databaseFilePath).copy(backupFilePath);

      print('Database backup created at: $backupFilePath');
    } catch (e) {
      print('Error creating database backup: $e');
    }
  }

  Future<void> restoreFromBackup() async {
    try {
      final databasePath = await getDatabasesPath();
      const databaseName = 'POS.db';
      final databaseFilePath = join(databasePath, databaseName);

      final documentsDirectory = await getApplicationDocumentsDirectory();
      final backupDirectory = join(documentsDirectory.path, 'database_backups');
      final backupFilePath = join(backupDirectory, databaseName);

      if (await File(backupFilePath).exists()) {
        await File(backupFilePath).copy(databaseFilePath);
        await createDatabase();
        print('Database restored from backup');
      } else {
        print('Backup file not found: $backupFilePath');
      }
    } catch (e) {
      print('Error restoring database from backup: $e');
    }
  }
}
