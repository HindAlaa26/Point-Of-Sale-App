import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/screens/category_screen/category_operations.dart';
import 'package:point_of_sales/shared_component/custom_table.dart';
import 'package:point_of_sales/shared_component/default_snackbar.dart';
import 'package:point_of_sales/shared_component/drop_down_button.dart';
import 'package:point_of_sales/shared_component/filter_widget.dart';
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
      print("category Data=================$data");
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
        // await sqlHelper.database!.delete("products",
        //     where: 'categoryId = ?', whereArgs: [category.id]);
        getCategories(); // Refresh the categories list
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text('category deleted Successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error when deleting category ${category.name}')));
      await showDialog(
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
                      text: "Error",
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textInApp(
                      text:
                          "There is some products related to this category, please delete these products first",
                      color: Colors.blue.shade700),
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
                  child: const Text('Ok'),
                ),
              ],
            );
          });
      print('Error when deleting category $e');
    }
  }

  bool sortAscend = false;
  int? sortColumnIndex;

  var nameController = TextEditingController();

  Future<void> filterByName() async {
    String? name = nameController.text;
    if (name.isEmpty) {
      defaultSnackBar(
          text: 'Please enter a valid name',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                          Select * from categories 
                      where name == ?                   
                        """, [name]);

    if (data.isNotEmpty) {
      categories = [];
      for (var item in data) {
        categories?.add(Category.fromJson(item));
      }
    } else {
      categories = [];
    }
    setState(() {});
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
          Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 5, bottom: 10, right: 10),
            child: Row(
              children: [
                //Search
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
                const SizedBox(
                  width: 10,
                ),
                // sort
                CategoriesSortDropDownButton(
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
                              filterData(
                                  text: "Name",
                                  controller: nameController,
                                  keyboardType: TextInputType.name,
                                  isNumeric: false),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey),
                                  onPressed: () {
                                    if (nameController.text.isNotEmpty) {
                                      filterByName();
                                      nameController.clear();
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
                  padding: const EdgeInsets.only(top: 1),
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
            index: 4,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscend,
            columns: [
              DataColumn(
                label:
                    Center(child: textInApp(text: 'Id', color: Colors.white)),
              ),
              DataColumn(
                  onSort: (columnIndex, ascending) {
                    if (sortColumnIndex == 1) {
                      sortAscend = ascending;
                      sortColumnIndex = 1;
                      setState(() {});

                      if (ascending) {
                        categories!.sort((a, b) => a.name!.compareTo(b.name!));
                      } else {
                        categories!.sort((b, a) => a.name!.compareTo(b.name!));
                      }
                    }
                  },
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
