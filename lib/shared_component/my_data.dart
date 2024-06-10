import 'package:flutter/material.dart';
import 'package:point_of_sales/screens/sales_screen/all_sales.dart';
import 'package:point_of_sales/screens/category_screen/categories.dart';
import 'package:point_of_sales/screens/client_screens/clients.dart';
import 'package:point_of_sales/screens/product_screen/products.dart';
import 'package:point_of_sales/screens/sales_screen/sales_screen.dart';

List<String> cardTexts = [
  "All sales",
  "Products",
  "clients",
  "New sale",
  "Categories"
];

List<IconData> cardIcons = [
  Icons.storage_outlined,
  Icons.inventory,
  Icons.group,
  Icons.shopping_basket,
  Icons.category,
];

List<Color> cardCircleIconColor = [
  Colors.deepOrangeAccent,
  Colors.pink,
  Colors.cyan,
  Colors.green,
  Colors.orange,
];
List<Widget> screens = [
  const AllSalesPage(),
  const Products(),
  const Clients(),
  const SalesScreen(),
  const Categories()
];

bool isLoading = true;
bool result = false;
