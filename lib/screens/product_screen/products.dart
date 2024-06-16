import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/helpers/sql_helper.dart';
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/screens/product_screen/product_operations.dart';
import 'package:point_of_sales/shared_component/custom_table.dart';
import 'package:point_of_sales/shared_component/default_snackbar.dart';
import 'package:point_of_sales/shared_component/drop_down_button.dart';
import 'package:point_of_sales/shared_component/filter_widget.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  void initState() {
    getProducts();
    super.initState();
  }

  bool sortAscend = false;
  int? sortColumnIndex;
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
        print("No products found.");
      }
      // print("Product Data=================$data");
      setState(() {});
    } catch (e) {
      print('Error in get Products $e');
    }
  }

  Future<void> deleteProduct({required Product product}) async {
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
                  textInApp(text: "Category Name : "),
                  textInApp(text: " ${product.name}", color: Colors.blueGrey),
                  textInApp(text: "Category description : "),
                  textInApp(
                      text: " ${product.description}", color: Colors.blueGrey),
                  Row(
                    children: [
                      textInApp(text: "Category price : "),
                      textInApp(
                          text: " ${product.price}", color: Colors.blueGrey),
                    ],
                  ),
                  Row(
                    children: [
                      textInApp(text: "Category stock : "),
                      textInApp(
                          text: " ${product.stock}", color: Colors.blueGrey),
                    ],
                  ),
                  Row(
                    children: [
                      textInApp(text: "Category isAvailable : "),
                      textInApp(
                          text: " ${product.isAvailable}",
                          color: Colors.blueGrey),
                    ],
                  ),
                  textInApp(text: "Category image : "),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.network(
                        height: 100,
                        width: 100,
                        product.image ?? "",
                        errorBuilder: (context, error, stackTrace) => Column(
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                            textInApp(
                                text: "Invalid Image", color: Colors.blueGrey)
                          ],
                        ),
                      ),
                    ],
                  ),
                  textInApp(text: "Category Name : "),
                  textInApp(
                      text: " ${product.categoryName}", color: Colors.blueGrey),
                  textInApp(text: "Category Description:"),
                  textInApp(
                      text: " ${product.categoryDescription}",
                      color: Colors.blueGrey),
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
        await sqlHelper.database!
            .delete("products", where: 'id = ?', whereArgs: [product.id]);
        getProducts(); // Refresh the categories list
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text('product deleted Successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error when deleting product ${product.name}')));
      print('Error when deleting product $e');
    }
  }

  var priceGreaterThanController = TextEditingController();
  var priceLessThanController = TextEditingController();
  var priceEqualToController = TextEditingController();

  Future<void> filterByPriceGreaterThan() async {
    double? price = double.tryParse(priceGreaterThanController.text);
    if (price == null) {
      defaultSnackBar(
          text: 'Please enter a valid price',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                        Select P.*,C.name as categoryName,C.description as categoryDescription from products P
                  Inner JOIN categories C
                  On P.categoryId = C.id
                        where P.price > ?
                        """, [price]);

    if (data.isNotEmpty) {
      products = [];
      for (var item in data) {
        products?.add(Product.fromJson(item));
      }
    } else {
      products = [];
    }
    setState(() {});
  }

  Future<void> filterByPriceLessThan() async {
    double? price = double.tryParse(priceLessThanController.text);
    if (price == null) {
      defaultSnackBar(
          text: 'Please enter a valid price',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                        Select P.*,C.name as categoryName,C.description as categoryDescription from products P
                  Inner JOIN categories C
                  On P.categoryId = C.id
                        where P.price < ?
                        """, [price]);

    if (data.isNotEmpty) {
      products = [];
      for (var item in data) {
        products?.add(Product.fromJson(item));
      }
    } else {
      products = [];
    }
    setState(() {});
  }

  Future<void> filterByPriceEqualToThan() async {
    double? price = double.tryParse(priceEqualToController.text);
    if (price == null) {
      defaultSnackBar(
          text: 'Please enter a valid price',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                        Select P.*,C.name as categoryName,C.description as categoryDescription from products P
                  Inner JOIN categories C
                  On P.categoryId = C.id
                        where P.price == ?
                        """, [price]);

    if (data.isNotEmpty) {
      products = [];
      for (var item in data) {
        products?.add(Product.fromJson(item));
      }
    } else {
      products = [];
    }
    setState(() {});
  }

  var stockGreaterThanController = TextEditingController();
  var stockLessThanController = TextEditingController();
  var stockEqualToController = TextEditingController();

  Future<void> filterByStockGreaterThan() async {
    double? stock = double.tryParse(stockGreaterThanController.text);
    if (stock == null) {
      defaultSnackBar(
          text: 'Please enter a valid stock number',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                        Select P.*,C.name as categoryName,C.description as categoryDescription from products P
                  Inner JOIN categories C
                  On P.categoryId = C.id
                        where P.stock > ?
                        """, [stock]);

    if (data.isNotEmpty) {
      products = [];
      for (var item in data) {
        products?.add(Product.fromJson(item));
      }
    } else {
      products = [];
    }
    setState(() {});
  }

  Future<void> filterByStockLessThan() async {
    double? stock = double.tryParse(stockLessThanController.text);
    if (stock == null) {
      defaultSnackBar(
          text: 'Please enter a valid stock number',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                        Select P.*,C.name as categoryName,C.description as categoryDescription from products P
                  Inner JOIN categories C
                  On P.categoryId = C.id
                        where P.stock < ?
                        """, [stock]);

    if (data.isNotEmpty) {
      products = [];
      for (var item in data) {
        products?.add(Product.fromJson(item));
      }
    } else {
      products = [];
    }
    setState(() {});
  }

  Future<void> filterByStockEqualToThan() async {
    double? stock = double.tryParse(stockEqualToController.text);
    if (stock == null) {
      defaultSnackBar(
          text: 'Please enter a valid stock number',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                        Select P.*,C.name as categoryName,C.description as categoryDescription from products P
                  Inner JOIN categories C
                  On P.categoryId = C.id
                        where P.stock == ?
                        """, [stock]);

    if (data.isNotEmpty) {
      products = [];
      for (var item in data) {
        products?.add(Product.fromJson(item));
      }
    } else {
      products = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: textInApp(text: "Products", color: Colors.white),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsOperationScreen(),
                    ));
                if (result ?? false) {
                  getProducts();
                }
              },
              icon: const Icon(
                Icons.add,
                size: 25,
              ))
        ],
      ),
      body: Column(
        children: [
          // sort && filters
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Search
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
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
                        getProducts();
                        return;
                      }
                      // Convert 'true' and 'false' text to appropriate integer values for SQLite
                      String booleanCondition = "";
                      if (text.toLowerCase() == 'true') {
                        booleanCondition = "OR P.isAvailable = 1";
                      } else if (text.toLowerCase() == 'false') {
                        booleanCondition = "OR P.isAvailable = 0";
                      }
                      var sqlHelper = GetIt.I.get<SqlHelper>();
                      var data = await sqlHelper.database!.rawQuery("""
                        Select P.*,C.name as categoryName,C.description as categoryDescription from products P
                  Inner JOIN categories C
                  On P.categoryId = C.id
                        where P.name like '%$text%' OR P.description like '%$text%' OR P.price like '%$text%'
                        OR P.stock like '%$text%'
                        $booleanCondition
                        OR categoryName like '%$text%'
                        OR categoryDescription like '%$text%'
                        """);

                      if (data.isNotEmpty) {
                        products = [];
                        for (var item in data) {
                          products?.add(Product.fromJson(item));
                        }
                      } else {
                        products = [];
                      }
                      setState(() {});
                    },
                  ),
                ),
              ),
              //sort
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    ProductDropDownButton(
                      selectedValue: sortColumnIndex,
                      onChanged: (int? value) {
                        sortColumnIndex = value;
                        sortAscend = true;
                        print("value===================$value");
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              //filters
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
                                    // price Greater than
                                    filterData(
                                        text: "Price Greater than",
                                        controller: priceGreaterThanController,
                                        isNumeric: true),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    // price less than
                                    filterData(
                                        text: "Price Less than",
                                        controller: priceLessThanController,
                                        isNumeric: true),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    // price equal
                                    filterData(
                                        text: "Price Equal to",
                                        controller: priceEqualToController,
                                        isNumeric: true),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    //////////////////////stock///////////////////////
                                    // stock Greater than
                                    filterData(
                                        text: "Stock Greater than",
                                        controller: stockGreaterThanController,
                                        isNumeric: true),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    // stock less than
                                    filterData(
                                        text: "Stock Less than",
                                        controller: stockLessThanController,
                                        isNumeric: true),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    // stock equal
                                    filterData(
                                        text: "Stock Equal to",
                                        controller: stockEqualToController,
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
                                  if (priceGreaterThanController
                                      .text.isNotEmpty) {
                                    filterByPriceGreaterThan();
                                    priceGreaterThanController.clear();
                                    Navigator.pop(context);
                                  } else if (priceLessThanController
                                      .text.isNotEmpty) {
                                    filterByPriceLessThan();
                                    priceLessThanController.clear();
                                    Navigator.pop(context);
                                  } else if (priceEqualToController
                                      .text.isNotEmpty) {
                                    filterByPriceEqualToThan();
                                    priceEqualToController.clear();
                                    Navigator.pop(context);
                                  }
                                  ///////// stock //////////////////
                                  else if (stockGreaterThanController
                                      .text.isNotEmpty) {
                                    filterByStockGreaterThan();
                                    stockGreaterThanController.clear();
                                    Navigator.pop(context);
                                  } else if (stockLessThanController
                                      .text.isNotEmpty) {
                                    filterByStockLessThan();
                                    stockLessThanController.clear();
                                    Navigator.pop(context);
                                  } else if (stockEqualToController
                                      .text.isNotEmpty) {
                                    filterByStockEqualToThan();
                                    stockEqualToController.clear();
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                child: textInApp(
                                    text: "Apply Filters", color: Colors.white),
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
                padding: const EdgeInsets.only(top: 30),
                minWidth: 0,
                child: const Icon(
                  Icons.filter_list_sharp,
                  color: Colors.blueGrey,
                  size: 35,
                ),
              ),
            ],
          ),

          DefaultTable(
            index: 1,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscend,
            columns: [
              DataColumn(
                  label: Center(
                      child: textInApp(
                text: "Id",
                color: Colors.white,
              ))),
              DataColumn(
                  label: Center(
                      child: textInApp(
                text: "Name",
                color: Colors.white,
              ))),
              DataColumn(
                  label: Center(
                      child: textInApp(
                text: "Description",
                color: Colors.white,
              ))),
              DataColumn(
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    if (sortColumnIndex == 3) {
                      sortAscend = ascending;
                      sortColumnIndex = 3;
                      setState(() {});

                      if (ascending) {
                        products!
                            .sort((a, b) => a.price!.compareTo(b.price as num));
                      } else {
                        products!
                            .sort((b, a) => a.price!.compareTo(b.price as num));
                      }
                    }
                  },
                  label: Center(
                      child: textInApp(
                    text: "Price",
                    color: Colors.white,
                  ))),
              DataColumn(
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    if (sortColumnIndex == 4) {
                      sortAscend = ascending;
                      sortColumnIndex = 4;
                      setState(() {});

                      if (ascending) {
                        products!
                            .sort((a, b) => a.stock!.compareTo(b.stock as num));
                      } else {
                        products!
                            .sort((b, a) => a.stock!.compareTo(b.stock as num));
                      }
                    }
                  },
                  label: Center(
                      child: textInApp(
                    text: "Stock",
                    color: Colors.white,
                  ))),
              DataColumn(
                  label: Center(
                      child: textInApp(
                text: "isAvailable",
                color: Colors.white,
              ))),
              DataColumn(
                  label: Center(
                      child: textInApp(
                text: "image",
                color: Colors.white,
              ))),
              DataColumn(
                  label: Center(
                      child: textInApp(
                text: "Cat Name",
                color: Colors.white,
              ))),
              DataColumn(
                  label: Center(
                      child: textInApp(
                text: "Cat Description",
                color: Colors.white,
              ))),
              DataColumn(
                  label: Center(
                      child: textInApp(
                text: "Actions",
                color: Colors.white,
              ))),
            ],
            minWidth: 2000,
            dataSource: DataSource(
              products: products,
              onDelete: (product) async {
                await deleteProduct(product: product);
              },
              onUpdate: (product) async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => ProductsOperationScreen(
                              product: product,
                            )));

                if (result ?? false) {
                  getProducts();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DataSource extends DataTableSource {
  List<Product>? products;
  void Function(Product)? onDelete;
  void Function(Product)? onUpdate;
  DataSource({this.products, this.onDelete, this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(
        color: MaterialStateProperty.all(Colors.blue.shade100),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.blue),
        cells: [
          DataCell(
            Center(child: textInApp(text: "${products?[index].id}")),
          ),
          DataCell(Center(child: textInApp(text: "${products?[index].name}"))),
          DataCell(Center(
              child: textInApp(text: "${products?[index].description}"))),
          DataCell(Center(child: textInApp(text: "${products?[index].price}"))),
          DataCell(Center(child: textInApp(text: "${products?[index].stock}"))),
          DataCell(Center(
              child: textInApp(text: "${products?[index].isAvailable}"))),
          DataCell(Center(
              child: Image.network(
            products?[index].image ?? " ",
            height: 75,
            width: 100,
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                textInApp(text: "Invalid Image", color: Colors.blueGrey)
              ],
            ),
          ))),
          DataCell(Center(
              child: textInApp(text: "${products?[index].categoryName}"))),
          DataCell(Center(
              child:
                  textInApp(text: "${products?[index].categoryDescription}"))),
          DataCell(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  onUpdate!(products![index]);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.blueGrey.shade800,
                ),
                onPressed: () async {
                  onDelete!(products![index]);
                },
              ),
            ],
          )),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
