import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/helpers/sql_helper.dart';
import 'package:point_of_sales/models/client_model.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class CategoriesDropDownButton extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChanged;
  const CategoriesDropDownButton(
      {super.key, this.selectedValue, this.onChanged});

  @override
  State<CategoriesDropDownButton> createState() =>
      _CategoriesDropDownButtonState();
}

class _CategoriesDropDownButtonState extends State<CategoriesDropDownButton> {
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  List<Category>? categories;
  getCategories() async {
    categories = [];
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.query('categories');

      if (data.isNotEmpty) {
        for (var item in data) {
          categories ??= [];
          categories?.add(Category.fromJson(item));
        }
      } else {
        categories = [];
      }
      setState(() {});
    } catch (e) {
      print('Error in get Categories $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return categories == null
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          )
        : (categories?.isEmpty ?? false)
            ? Center(
                child: textInApp(text: 'No Categories Found'),
              )
            : Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 20, bottom: 10, right: 13),
                        child: DropdownButton(
                            value: widget.selectedValue,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: textInApp(text: 'Select Category'),
                            items: [
                              for (var category in categories!)
                                DropdownMenuItem(
                                  value: category.id,
                                  child: textInApp(
                                      text:
                                          category.name ?? 'No category Name'),
                                ),
                            ],
                            onChanged: widget.onChanged),
                      ),
                    ),
                  ),
                ],
              );
  }
}

class ClientDropDownButton extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChanged;
  const ClientDropDownButton({super.key, this.selectedValue, this.onChanged});

  @override
  State<ClientDropDownButton> createState() => _ClientDropDownButtonState();
}

class _ClientDropDownButtonState extends State<ClientDropDownButton> {
  @override
  void initState() {
    getClients();
    super.initState();
  }

  List<Client>? clients;
  getClients() async {
    clients = [];
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.query('clients');

      if (data.isNotEmpty) {
        for (var item in data) {
          clients ??= [];
          clients?.add(Client.fromJson(item));
        }
      } else {
        clients = [];
      }
      print("client Data=================$data");
      setState(() {});
    } catch (e) {
      print('Error in get clients $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return clients == null
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          )
        : (clients?.isEmpty ?? false)
            ? Center(
                child: textInApp(text: 'No client Found'),
              )
            : Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 20, bottom: 10, right: 13),
                        child: DropdownButton(
                            value: widget.selectedValue,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: textInApp(text: 'Select client'),
                            items: [
                              for (var client in clients!)
                                DropdownMenuItem(
                                  value: client.id,
                                  child: textInApp(
                                      text: client.name ?? 'No client Name'),
                                ),
                            ],
                            onChanged: widget.onChanged),
                      ),
                    ),
                  ),
                ],
              );
  }
}

class ProductDropDownButton extends StatefulWidget {
  late int? selectedValue;
  final void Function(int?)? onChanged;
  ProductDropDownButton({super.key, this.selectedValue, this.onChanged});

  @override
  State<ProductDropDownButton> createState() => _ProductDropDownButtonState();
}

class _ProductDropDownButtonState extends State<ProductDropDownButton> {
  @override
  void initState() {
    getProducts();
    super.initState();
  }

  List<Product>? products;
  getProducts() async {
    products = [];
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.rawQuery("""
  Select P.*,C.name as categoryName,C.description as categoryDescription from products P
  Inner JOIN categories C
  On P.categoryId = C.id
  """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products?.add(Product.fromJson(item));
        }
      } else {
        products = [];
      }
      print("Product Data=================$data");
      setState(() {});
    } catch (e) {
      print('Error in get Products $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return products == null
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          )
        : (products?.isEmpty ?? false)
            ? Center(
                child: textInApp(text: 'No products Found'),
              )
            : Container(
                width: 130,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButton(
                    padding: const EdgeInsets.all(10),
                    value: widget.selectedValue,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: textInApp(text: 'sort by'),
                    items: [
                      DropdownMenuItem(
                        value: 3,
                        child: textInApp(text: "price"),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: textInApp(text: "stock"),
                      ),
                    ],
                    onChanged: widget.onChanged),
              );
  }
}

class SalesDropDownButton extends StatefulWidget {
  late int? selectedValue;
  final void Function(int?)? onChanged;
  SalesDropDownButton({super.key, this.selectedValue, this.onChanged});

  @override
  State<SalesDropDownButton> createState() => _SalesDropDownButtonState();
}

class _SalesDropDownButtonState extends State<SalesDropDownButton> {
  List<Order>? orders;
  @override
  void initState() {
    getOrders();
    super.initState();
  }

  void getOrders() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.rawQuery("""
  Select O.*,C.name as clientName,C.phone as clientPhone from orders O
  Inner JOIN clients C
  On O.clientId = C.id
  """);
      print("Data>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$data");
      if (data.isNotEmpty) {
        orders = [];
        for (var item in data) {
          orders?.add(Order.fromJson(item));
        }
      } else {
        orders = [];
      }
    } catch (e) {
      orders = [];
      print('Error in get Orders $e');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return orders == null
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          )
        : (orders?.isEmpty ?? false)
            ? Center(
                child: textInApp(text: 'No orders Found'),
              )
            : Container(
                width: 130,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButton(
                    padding: const EdgeInsets.all(10),
                    value: widget.selectedValue,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: textInApp(text: 'sort by'),
                    items: [
                      DropdownMenuItem(
                        value: 2,
                        child: textInApp(
                            text: "Total Price",
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: textInApp(
                            text: "Discount", fontWeight: FontWeight.bold),
                      ),
                    ],
                    onChanged: widget.onChanged),
              );
  }
}

class CategoriesSortDropDownButton extends StatefulWidget {
  late int? selectedValue;
  final void Function(int?)? onChanged;
  CategoriesSortDropDownButton({super.key, this.selectedValue, this.onChanged});

  @override
  State<CategoriesSortDropDownButton> createState() =>
      _CategoriesSortDropDownButtonState();
}

class _CategoriesSortDropDownButtonState
    extends State<CategoriesSortDropDownButton> {
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  List<Category>? categories;
  getCategories() async {
    categories = [];
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.query('categories');

      if (data.isNotEmpty) {
        for (var item in data) {
          categories ??= [];
          categories?.add(Category.fromJson(item));
        }
      } else {
        categories = [];
      }
      print("category Data=================$data");
      setState(() {});
    } catch (e) {
      print('Error in get Categories $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return categories == null
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          )
        : (categories?.isEmpty ?? false)
            ? Center(
                child: textInApp(text: 'No category Found'),
              )
            : Container(
                width: 130,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButton(
                    padding: const EdgeInsets.all(10),
                    value: widget.selectedValue,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: textInApp(text: 'sort by'),
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: textInApp(
                            text: "name",
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                    onChanged: widget.onChanged),
              );
  }
}

class ClientsSortDropDownButton extends StatefulWidget {
  late int? selectedValue;
  final void Function(int?)? onChanged;
  ClientsSortDropDownButton({super.key, this.selectedValue, this.onChanged});

  @override
  State<ClientsSortDropDownButton> createState() =>
      _ClientsSortDropDownButtonState();
}

class _ClientsSortDropDownButtonState extends State<ClientsSortDropDownButton> {
  @override
  void initState() {
    getClients();
    super.initState();
  }

  List<Client>? clients;
  getClients() async {
    clients = [];
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.query('clients');

      if (data.isNotEmpty) {
        for (var item in data) {
          clients ??= [];
          clients?.add(Client.fromJson(item));
        }
      } else {
        clients = [];
      }
      print("client Data=================$data");
      setState(() {});
    } catch (e) {
      print('Error in get clients $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return clients == null
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          )
        : (clients?.isEmpty ?? false)
            ? Center(
                child: textInApp(text: 'No client Found'),
              )
            : Container(
                width: 130,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButton(
                    padding: const EdgeInsets.all(10),
                    value: widget.selectedValue,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: textInApp(text: 'sort by'),
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: textInApp(
                            text: "name",
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                    onChanged: widget.onChanged),
              );
  }
}
