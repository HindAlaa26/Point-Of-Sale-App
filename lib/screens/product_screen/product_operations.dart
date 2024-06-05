import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/shared_component/default_snackbar.dart';
import 'package:point_of_sales/shared_component/drop_down_button.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import 'package:sqflite/sqflite.dart';
import '../../helpers/sql_helper.dart';
import '../../shared_component/custom_button.dart';
import '../../shared_component/custom_textFormField.dart';

class ProductsOperationScreen extends StatefulWidget {
  final Product? product;
  const ProductsOperationScreen({this.product, super.key});

  @override
  State<ProductsOperationScreen> createState() => _CategoriesOpsState();
}

class _CategoriesOpsState extends State<ProductsOperationScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController imageController;
  int? selectedCategoryId;
  bool? isAvailable;
  bool showImage = false;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.product?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    priceController =
        TextEditingController(text: '${widget.product?.price ?? ''}');
    stockController =
        TextEditingController(text: '${widget.product?.stock ?? ''}');
    imageController = TextEditingController(text: widget.product?.image ?? '');
    selectedCategoryId = widget.product?.categoryId;
    isAvailable = widget.product?.isAvailable;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: textInApp(
            text: widget.product == null ? 'Add New' : 'Edit Product',
            color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DefaultTextFormField(
                  label: 'Product Name',
                  controller: nameController,
                  validatorText: 'Name',
                  prefixIcon: Icons.person,
                ),
                DefaultTextFormField(
                  label: 'Product Description',
                  prefixIcon: Icons.description,
                  controller: descriptionController,
                  validatorText: "Description",
                ),
                DefaultTextFormField(
                    label: 'Product Image Url',
                    prefixIcon: Icons.image,
                    controller: imageController,
                    validatorText: "Image Url",
                    onSaved: (text) {
                      if (text!.isNotEmpty) {
                        showImage = true;
                        setState(() {});
                        print("===========================$showImage");
                      }
                    }),
                showImage
                    ? Image.network(
                        imageController.text ?? "",
                        height: 100,
                        width: 300,
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const CircularProgressIndicator(
                              color: Colors.amber,
                            );
                          }
                        },
                      )
                    : const SizedBox(),
                Row(
                  children: [
                    Expanded(
                      child: DefaultTextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          label: 'Product Price',
                          controller: priceController,
                          prefixIcon: Icons.attach_money_sharp,
                          validatorText: "price"),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: DefaultTextFormField(
                          label: 'Stock',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          prefixIcon: Icons.inventory_outlined,
                          controller: stockController,
                          validatorText: "Stock"),
                    ),
                  ],
                ),
                CategoriesDropDownButton(
                  selectedValue: selectedCategoryId,
                  onChanged: (value) {
                    selectedCategoryId = value;
                    setState(() {});
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textInApp(
                          text: 'Product Available (${isAvailable ?? "?"})'),
                      Switch(
                          value: isAvailable ?? false,
                          activeColor: const Color.fromRGBO(15, 87, 217, 1),
                          inactiveThumbColor: Colors.blueAccent,
                          inactiveTrackColor: Colors.blue.shade200,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
                            });
                          }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                DefaultButton(
                    text: widget.product == null ? 'Submit' : 'Edit',
                    onPressed: () async {
                      await onSubmit();
                    }),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        setState(() {});
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.product == null) {
          //add
          await sqlHelper.database!.insert(
              'products',
              conflictAlgorithm: ConflictAlgorithm.replace,
              {
                'name': nameController.text,
                'description': descriptionController.text,
                'price': double.parse(priceController.text ?? '0.0'),
                'stock': int.parse(stockController.text ?? '0'),
                'image': imageController.text,
                'categoryId': selectedCategoryId,
                'isAvailable': isAvailable ?? false,
              });
        } else {
          // update
          await sqlHelper.database!.update(
              'products',
              {
                'name': nameController.text,
                'description': descriptionController.text,
                'price': double.parse(priceController.text ?? '0.0'),
                'stock': int.parse(stockController.text ?? '0'),
                'image': imageController.text,
                'categoryId': selectedCategoryId,
                'isAvailable': isAvailable ?? false,
              },
              where: 'id =?',
              whereArgs: [widget.product?.id]);
        }

        defaultSnackBar(
            context: context,
            text: widget.product == null
                ? 'product added Successfully'
                : 'product Updated Successfully',
            backgroundColor: Colors.green);
        Navigator.pop(context, true);
      }
    } catch (error) {
      defaultSnackBar(
          context: context,
          text: widget.product == null
              ? "Error when adding product"
              : "Error when updating product",
          backgroundColor: Colors.red);
      print("Error when adding product : $error");
    }
  }
}
