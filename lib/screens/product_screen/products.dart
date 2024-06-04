import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/helpers/sql_helper.dart';
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/screens/product_screen/product_operations.dart';
import 'package:point_of_sales/shared_component/custom_table.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../../shared_component/page_data.dart';

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
      setState(() {});
    } catch (e) {
      print('Error in get Products $e');
    }
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
          //Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                // if (text == '') {
                //   getProducts();
                //   return;
                // }
                //
                // var sqlHelper = GetIt.I.get<SqlHelper>();
                // var data = await sqlHelper.database!.rawQuery("""
                //       Select * from categories
                //       where name like '%$text%' OR description like '%$text%'
                //       """);
                //
                // if (data.isNotEmpty) {
                //   product = [];
                //   for (var item in data) {
                //     products?.add(product.fromJson(item));
                //   }
                // } else {
                //   categories = [];
                // }
                // setState(() {});
              },
            ),
          ),
          DefaultTable(
            index: 1,
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
                  label: Center(
                      child: textInApp(
                text: "Price",
                color: Colors.white,
              ))),
              DataColumn(
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
              onDelete: (category) async {
                // await deleteCategory(category: category);
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
          DataCell(Center(child: Image.network(products?[index].image ?? " "))),
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
