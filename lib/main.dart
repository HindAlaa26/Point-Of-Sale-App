import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/screens/home_screen.dart';
import 'helpers/sql_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var sqlHelper = SqlHelper();
  await sqlHelper.createDatabase();
  if (sqlHelper.database != null) {
    GetIt.I.registerSingleton<SqlHelper>(sqlHelper);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(15, 87, 217, 1),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: HomePage(),
    );
  }
}
