import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/shared_component/default_snackbar.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import 'package:sqflite/sqflite.dart';
import '../../helpers/sql_helper.dart';
import '../../models/category_model.dart';
import '../../shared_component/custom_button.dart';
import '../../shared_component/custom_textFormField.dart';

class CategoriesOperationScreen extends StatefulWidget {
  final Category? category;
  const CategoriesOperationScreen({this.category, super.key});

  @override
  State<CategoriesOperationScreen> createState() => _CategoriesOpsState();
}

class _CategoriesOpsState extends State<CategoriesOperationScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  var formKey = GlobalKey<FormState>();
  @override
  void initState() {
    nameController = TextEditingController(text: widget.category?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: textInApp(
            text: widget.category == null ? 'Add New' : 'Edit Category',
            color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              DefaultTextFormField(
                label: 'Name',
                controller: nameController,
                validatorText: 'Name',
                prefixIcon: Icons.person,
              ),
              const SizedBox(
                height: 40,
              ),
              DefaultTextFormField(
                label: 'Description',
                prefixIcon: Icons.description,
                controller: descriptionController,
                validatorText: "Description",
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(
                height: 50,
              ),
              DefaultButton(
                  text: widget.category == null ? 'Submit' : 'Edit',
                  onPressed: () async {
                    await onSubmit();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.category == null) {
          //add
          await sqlHelper.database!.insert(
              'categories',
              conflictAlgorithm: ConflictAlgorithm.replace,
              {
                'name': nameController.text,
                'description': descriptionController.text,
              });
        } else {
          // update
          await sqlHelper.database!.update(
              'categories',
              {
                'name': nameController.text,
                'description': descriptionController.text,
              },
              where: 'id =?',
              whereArgs: [widget.category?.id]);
        }

        defaultSnackBar(
            context: context,
            text: widget.category == null
                ? 'Category added Successfully'
                : 'Category Updated Successfully',
            backgroundColor: Colors.green);
        Navigator.pop(context, true);
      }
    } catch (error) {
      defaultSnackBar(
          context: context,
          text: widget.category == null
              ? "Error when adding category"
              : "Error when updating category",
          backgroundColor: Colors.red);
      print("Error when adding category : $error");
    }
  }
}
