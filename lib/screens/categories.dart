import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/screens/category_operations.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../helpers/sql_helper.dart';
import '../models/category_model.dart';
import '../shared_component/my_data.dart';
import '../shared_component/page_data.dart';

class Categories extends StatefulWidget {
  const Categories({
    super.key,
  });

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: textInApp(text: "Categories", color: Colors.white),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoriesOperationScreen(
                        onCategoryAdded: () {
                          // Call getCategories() after adding a new category
                          getCategories();
                        },
                      ),
                    ));
              },
              icon: const Icon(
                Icons.add,
                size: 25,
              ))
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.black, size: 26),
          textTheme: const TextTheme(
            caption: TextStyle(
                color: Color.fromRGBO(15, 87, 217, 1),
                fontSize: 20), // "Rows per page" text style
          ),
        ),
        child: PaginatedDataTable2(
          empty: Center(child: pageDataNotFound(index: 4)),
          border: TableBorder.all(color: Colors.black),
          headingRowColor:
              MaterialStateProperty.all(const Color.fromRGBO(15, 87, 217, 1)),
          minWidth: 700,
          rowsPerPage: 10,
          renderEmptyRowsInTheEnd: false,
          actions: [
            textInApp(
                text: "In Stock",
                color: Colors.orange,
                fontWeight: FontWeight.bold)
          ],
          horizontalMargin: 10,
          headingRowHeight: 60,
          dataRowHeight: 100,
          showFirstLastButtons: true,
          fit: FlexFit.tight,
          header: textInApp(
            text: "Product Name",
          ),
          autoRowsToHeight: true,
          columns: [
            DataColumn(
              label: textInApp(text: 'Id', color: Colors.white),
            ),
            DataColumn(label: textInApp(text: "Name", color: Colors.white)),
            DataColumn(
                label: textInApp(text: "Description", color: Colors.white)),
            DataColumn(label: textInApp(text: "Actions", color: Colors.white)),
          ],
          source: DataSource(
            categories: categories,
            refreshCallback: () async {
              await getCategories();
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}

class DataSource extends DataTableSource {
  List<Category>? categories;
  final Future<void> Function() refreshCallback;

  DataSource({
    this.categories,
    required this.refreshCallback,
  });
  @override
  DataRow? getRow(int index) {
    return DataRow2(
        color: MaterialStateProperty.all(Colors.blue.shade100),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.blue),
        cells: [
          DataCell(
            textInApp(text: "${categories?[index].id}"),
          ),
          DataCell(textInApp(text: "${categories?[index].name}")),
          DataCell(textInApp(text: "${categories?[index].description}")),
          DataCell(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.blueGrey.shade800,
                ),
                onPressed: () async {
                  deleteCategory(categories![index].id!, () async {
                    await refreshCallback();
                  });
                },
              ),
            ],
          )),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categories?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
