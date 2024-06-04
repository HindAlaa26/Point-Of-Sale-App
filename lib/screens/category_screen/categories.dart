import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/screens/category_screen/category_operations.dart';
import 'package:point_of_sales/shared_component/custom_table.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../../helpers/sql_helper.dart';
import '../../models/category_model.dart';

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

  Future<void> deleteCategory({required Category category}) async {
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
                  textInApp(text: " ${category.name}", color: Colors.blueGrey),
                  textInApp(text: "Category description : "),
                  textInApp(
                      text: " ${category.description}", color: Colors.blueGrey),
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
            .delete("categories", where: 'id = ?', whereArgs: [category.id]);
        getCategories(); // Refresh the categories list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error when deleting category ${category.name}')));
      print('Error when deleting category $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: textInApp(text: "Categories", color: Colors.white),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesOperationScreen(),
                    ));
                if (result ?? false) {
                  getCategories();
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
                if (text == '') {
                  getCategories();
                  return;
                }

                var sqlHelper = GetIt.I.get<SqlHelper>();
                var data = await sqlHelper.database!.rawQuery("""
                      Select * from categories 
                      where name like '%$text%' OR description like '%$text%'
                      """);

                if (data.isNotEmpty) {
                  categories = [];
                  for (var item in data) {
                    categories?.add(Category.fromJson(item));
                  }
                } else {
                  categories = [];
                }
                setState(() {});
              },
            ),
          ),
          DefaultTable(
            index: 4,
            columns: [
              DataColumn(
                label:
                    Center(child: textInApp(text: 'Id', color: Colors.white)),
              ),
              DataColumn(
                  label: Center(
                      child: textInApp(text: "Name", color: Colors.white))),
              DataColumn(
                  label: Center(
                      child:
                          textInApp(text: "Description", color: Colors.white))),
              DataColumn(
                  label: Center(
                      child: textInApp(text: "Actions", color: Colors.white))),
            ],
            dataSource: DataSource(
              categories: categories,
              onDelete: (category) async {
                await deleteCategory(category: category);
              },
              onUpdate: (category) async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => CategoriesOperationScreen(
                              category: category,
                            )));

                if (result ?? false) {
                  getCategories();
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
  List<Category>? categories;
  void Function(Category)? onDelete;
  void Function(Category)? onUpdate;
  DataSource({this.categories, this.onDelete, this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(
        color: MaterialStateProperty.all(Colors.blue.shade100),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.blue),
        cells: [
          DataCell(
            Center(child: textInApp(text: "${categories?[index].id}")),
          ),
          DataCell(
              Center(child: textInApp(text: "${categories?[index].name}"))),
          DataCell(Center(
              child: textInApp(text: "${categories?[index].description}"))),
          DataCell(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  onUpdate!(categories![index]);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.blueGrey.shade800,
                ),
                onPressed: () async {
                  onDelete!(categories![index]);
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
