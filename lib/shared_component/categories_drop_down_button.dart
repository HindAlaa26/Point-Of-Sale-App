import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/helpers/sql_helper.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

import '../models/category_model.dart';

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
