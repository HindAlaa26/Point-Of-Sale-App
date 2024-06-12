import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/helpers/sql_helper.dart';
import 'package:point_of_sales/screens/sales_screen/sales_screen.dart';
import 'package:point_of_sales/shared_component/custom_table.dart';
import 'package:point_of_sales/shared_component/default_snackbar.dart';
import 'package:point_of_sales/shared_component/drop_down_button.dart';
import 'package:point_of_sales/shared_component/filter_widget.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../../models/order_model.dart';

class AllSalesPage extends StatefulWidget {
  const AllSalesPage({super.key});

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  List<Order>? orders;
  @override
  void initState() {
    getOrders();
    super.initState();
  }

  bool sortAscend = false;
  int? sortColumnIndex;
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

  Future<void> deleteOrder({required Order order}) async {
    try {
      var dialogResult = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  textInApp(
                      text: "Confirm",
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textInApp(text: "Order label : "),
                  textInApp(text: " ${order.label}", color: Colors.blueGrey),
                  textInApp(text: "Order Total Price : "),
                  textInApp(
                      text: " ${order.totalPrice}", color: Colors.blueGrey),
                  Row(
                    children: [
                      textInApp(text: "Order Discount : "),
                      textInApp(
                          text: " ${order.discount}", color: Colors.blueGrey),
                    ],
                  ),
                  Row(
                    children: [
                      textInApp(text: "Order Client Name : "),
                      textInApp(
                          text: " ${order.clientName}", color: Colors.blueGrey),
                    ],
                  ),
                  textInApp(text: "Order Client Phone : "),
                  textInApp(
                      text: " ${order.clientPhone}", color: Colors.blueGrey),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();

        // Start a transaction to ensure both deletions are performed atomically
        await sqlHelper.database!.transaction((txn) async {
          await txn.delete("orders", where: 'id = ?', whereArgs: [order.id]);
          await txn.delete("orderProductItems",
              where: 'orderId = ?', whereArgs: [order.id]);
        });
        // await sqlHelper.database!
        //     .delete("orders", where: 'id = ?', whereArgs: [order.id]);
        // await sqlHelper.database!.delete("orderProductItems",
        //     where: 'orderId = ?', whereArgs: [order.id]);
        getOrders();

        defaultSnackBar(
            context: context,
            text: 'order deleted Successfully',
            backgroundColor: Colors.green);
      }
    } catch (e) {
      defaultSnackBar(
          context: context,
          text: 'Error when deleting order ${order.label}',
          backgroundColor: Colors.red);
      print('Error when deleting order $e');
    }
  }

  ///////////////////////////////////////////////////////////

  var totalPriceGreaterThanController = TextEditingController();
  var totalPriceLessThanController = TextEditingController();
  var totalPriceEqualToController = TextEditingController();

  Future<void> filterByTotalPriceGreaterThan() async {
    double? totalPrice = double.tryParse(totalPriceGreaterThanController.text);
    if (totalPrice == null) {
      defaultSnackBar(
          text: 'Please enter a valid Total Price',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                       Select O.*,C.name as clientName,C.phone as clientPhone from orders O
                          Inner JOIN clients C
                          On O.clientId = C.id                       
                            where O.totalPrice > ?                         
                        """, [totalPrice]);

    if (data.isNotEmpty) {
      orders = [];
      for (var item in data) {
        orders?.add(Order.fromJson(item));
      }
    } else {
      orders = [];
    }
    setState(() {});
  }

  Future<void> filterByTotalPriceLessThan() async {
    double? totalPrice = double.tryParse(totalPriceLessThanController.text);
    if (totalPrice == null) {
      defaultSnackBar(
          text: 'Please enter a valid Total Price',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                        Select O.*,C.name as clientName,C.phone as clientPhone from orders O
                          Inner JOIN clients C
                          On O.clientId = C.id                       
                            where O.totalPrice < ?                                                                      
                        """, [totalPrice]);

    if (data.isNotEmpty) {
      orders = [];
      for (var item in data) {
        orders?.add(Order.fromJson(item));
      }
    } else {
      orders = [];
    }
    setState(() {});
  }

  Future<void> filterByTotalPriceEqualToThan() async {
    double? totalPrice = double.tryParse(totalPriceEqualToController.text);
    if (totalPrice == null) {
      defaultSnackBar(
          text: 'Please enter a valid Total Price',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                        Select O.*,C.name as clientName,C.phone as clientPhone from orders O
                          Inner JOIN clients C
                          On O.clientId = C.id                      
                            where O.totalPrice == ?                 
                            """, [totalPrice]);

    if (data.isNotEmpty) {
      orders = [];
      for (var item in data) {
        orders?.add(Order.fromJson(item));
      }
    } else {
      orders = [];
    }
    setState(() {});
  }

  var discountGreaterThanController = TextEditingController();
  var discountLessThanController = TextEditingController();
  var discountEqualToController = TextEditingController();

  Future<void> filterByDiscountGreaterThan() async {
    double? discount = double.tryParse(discountGreaterThanController.text);
    if (discount == null) {
      defaultSnackBar(
          text: 'Please enter a valid Discount number',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                         Select O.*,C.name as clientName,C.phone as clientPhone from orders O
                          Inner JOIN clients C
                          On O.clientId = C.id
                        where O.discount > ?
                        """, [discount]);

    if (data.isNotEmpty) {
      orders = [];
      for (var item in data) {
        orders?.add(Order.fromJson(item));
      }
    } else {
      orders = [];
    }
    setState(() {});
  }

  Future<void> filterByDiscountLessThan() async {
    double? discount = double.tryParse(discountLessThanController.text);
    if (discount == null) {
      defaultSnackBar(
          text: 'Please enter a valid discount number',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                         Select O.*,C.name as clientName,C.phone as clientPhone from orders O
                          Inner JOIN clients C
                          On O.clientId = C.id
                        where O.discount < ?
                        """, [discount]);

    if (data.isNotEmpty) {
      orders = [];
      for (var item in data) {
        orders?.add(Order.fromJson(item));
      }
    } else {
      orders = [];
    }
    setState(() {});
  }

  Future<void> filterByDiscountEqualToThan() async {
    double? discount = double.tryParse(discountEqualToController.text);
    if (discount == null) {
      defaultSnackBar(
          text: 'Please enter a valid discount number',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                         Select O.*,C.name as clientName,C.phone as clientPhone from orders O
                          Inner JOIN clients C
                          On O.clientId = C.id
                        where O.discount == ?
                        """, [discount]);

    if (data.isNotEmpty) {
      orders = [];
      for (var item in data) {
        orders?.add(Order.fromJson(item));
      }
    } else {
      orders = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: textInApp(text: "All Sales", color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //search
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        label: textInApp(text: "Search"),
                        enabledBorder: const OutlineInputBorder(),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color.fromRGBO(15, 87, 217, 1)),
                        ),
                        prefixIcon: const Icon(Icons.search)),
                    onChanged: (text) async {
                      if (text == '') {
                        getOrders();
                        return;
                      }
                      var sqlHelper = GetIt.I.get<SqlHelper>();
                      var data = await sqlHelper.database!.rawQuery("""
                            
                          Select O.*,C.name as clientName,C.phone as clientPhone from orders O
                          Inner JOIN clients C
                          On O.clientId = C.id
                       
                            where O.label like '%$text%' OR O.totalPrice like '%$text%' OR O.discount like '%$text%'
                            OR clientName like '%$text%'
                            OR clientPhone like '%$text%'
                 
                            """);

                      if (data.isNotEmpty) {
                        orders = [];
                        for (var item in data) {
                          orders?.add(Order.fromJson(item));
                        }
                      } else {
                        orders = [];
                      }
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                //sort
                SalesDropDownButton(
                  selectedValue: sortColumnIndex,
                  onChanged: (int? value) {
                    sortColumnIndex = value;
                    sortAscend = true;
                    print("value===================$value");
                    setState(() {});
                  },
                ),
                //filter
                MaterialButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  textInApp(
                                      text: "Filter According To :",
                                      fontSize: 25,
                                      color: Colors.blueGrey),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // total price Greater than
                                      filterData(
                                          text: "Total Price Greater than",
                                          controller:
                                              totalPriceGreaterThanController,
                                          isNumeric: true),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // total price less than
                                      filterData(
                                          text: "Total Price Less than",
                                          controller:
                                              totalPriceLessThanController,
                                          isNumeric: true),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // total price equal
                                      filterData(
                                          text: "Total Price Equal than",
                                          controller:
                                              totalPriceEqualToController,
                                          isNumeric: true),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      //////////////////////discount///////////////////////
                                      // discount Greater than
                                      filterData(
                                          text: "Discount Greater than",
                                          controller:
                                              discountGreaterThanController,
                                          isNumeric: true),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // discount less than
                                      filterData(
                                          text: "Discount Less than",
                                          controller:
                                              discountLessThanController,
                                          isNumeric: true),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // discount equal
                                      filterData(
                                          text: "Discount Equal than",
                                          controller: discountEqualToController,
                                          isNumeric: true),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey),
                                  onPressed: () {
                                    if (totalPriceGreaterThanController
                                        .text.isNotEmpty) {
                                      filterByTotalPriceGreaterThan();
                                      totalPriceGreaterThanController.clear();
                                      Navigator.pop(context);
                                    } else if (totalPriceLessThanController
                                        .text.isNotEmpty) {
                                      filterByTotalPriceLessThan();
                                      totalPriceLessThanController.clear();
                                      Navigator.pop(context);
                                    } else if (totalPriceEqualToController
                                        .text.isNotEmpty) {
                                      filterByTotalPriceEqualToThan();
                                      totalPriceEqualToController.clear();
                                      Navigator.pop(context);
                                    }
                                    ///////// discount //////////////////
                                    else if (discountGreaterThanController
                                        .text.isNotEmpty) {
                                      filterByDiscountGreaterThan();
                                      discountGreaterThanController.clear();
                                      Navigator.pop(context);
                                    } else if (discountLessThanController
                                        .text.isNotEmpty) {
                                      filterByDiscountLessThan();
                                      discountLessThanController.clear();
                                      Navigator.pop(context);
                                    } else if (discountEqualToController
                                        .text.isNotEmpty) {
                                      filterByDiscountEqualToThan();
                                      discountEqualToController.clear();
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: textInApp(
                                      text: "Apply Filters",
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  padding: const EdgeInsets.only(top: 5),
                  minWidth: 0,
                  child: const Icon(
                    Icons.filter_list_sharp,
                    color: Colors.blueGrey,
                    size: 35,
                  ),
                ),
              ],
            ),
          ),
          DefaultTable(
            index: 0,
            minWidth: 1500,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscend,
            columns: [
              DataColumn(
                  label: Center(
                      child: textInApp(text: 'Id', color: Colors.white))),
              DataColumn(
                  label: Center(
                      child: textInApp(text: 'Label', color: Colors.white))),
              DataColumn(
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    if (sortColumnIndex == 2) {
                      sortAscend = ascending;
                      sortColumnIndex = 2;
                      setState(() {});

                      if (ascending) {
                        orders!.sort((a, b) =>
                            a.totalPrice!.compareTo(b.totalPrice as num));
                      } else {
                        orders!.sort((b, a) =>
                            a.totalPrice!.compareTo(b.totalPrice as num));
                      }
                    }
                  },
                  label: Center(
                      child:
                          textInApp(text: 'Total Price', color: Colors.white))),
              DataColumn(
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    if (sortColumnIndex == 3) {
                      sortAscend = ascending;
                      sortColumnIndex = 3;
                      setState(() {});

                      if (ascending) {
                        orders!.sort(
                            (a, b) => a.discount!.compareTo(b.discount as num));
                      } else {
                        orders!.sort(
                            (b, a) => a.discount!.compareTo(b.discount as num));
                      }
                    }
                  },
                  label: Center(
                      child: textInApp(text: 'Discount', color: Colors.white))),
              DataColumn(
                  label: Center(
                      child:
                          textInApp(text: 'client Name', color: Colors.white))),
              DataColumn(
                  label: Center(
                      child: textInApp(
                          text: 'client Phone', color: Colors.white))),
              DataColumn(
                  label: Center(
                      child: textInApp(text: 'Actions', color: Colors.white))),
            ],
            dataSource: OrdersDataSource(
                orders: orders,
                onShow: (order) async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => SalesScreen(
                                order: order,
                              )));

                  if (result ?? false) {
                    getOrders();
                  }
                },
                onDelete: (order) async {
                  await deleteOrder(order: order);
                }),
          ),
        ],
      ),
    );
  }
}

class OrdersDataSource extends DataTableSource {
  List<Order>? orders;
  void Function(Order)? onShow;
  void Function(Order)? onDelete;
  OrdersDataSource(
      {required this.orders, required this.onShow, required this.onDelete});
  @override
  DataRow? getRow(int index) {
    return DataRow2(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.blue),
        cells: [
          DataCell(Center(child: textInApp(text: '${orders?[index].id}'))),
          DataCell(Center(child: textInApp(text: '${orders?[index].label}'))),
          DataCell(
              Center(child: textInApp(text: '${orders?[index].totalPrice}'))),
          DataCell(
              Center(child: textInApp(text: '${orders?[index].discount}'))),
          DataCell(
              Center(child: textInApp(text: '${orders?[index].clientName}'))),
          DataCell(
              Center(child: textInApp(text: '${orders?[index].clientPhone}'))),
          DataCell(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  onShow!(orders![index]);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.blueGrey.shade900,
                ),
                onPressed: () {
                  onDelete!(orders![index]);
                },
              ),
            ],
          )),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => orders?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
