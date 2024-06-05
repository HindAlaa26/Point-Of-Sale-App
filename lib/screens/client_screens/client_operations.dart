import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/models/client_model.dart';
import 'package:point_of_sales/shared_component/default_snackbar.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import 'package:sqflite/sqflite.dart';
import '../../helpers/sql_helper.dart';
import '../../shared_component/custom_button.dart';
import '../../shared_component/custom_textFormField.dart';

class ClientsOperationScreen extends StatefulWidget {
  final Client? client;
  const ClientsOperationScreen({this.client, super.key});

  @override
  State<ClientsOperationScreen> createState() => _ClientsOperationScreenState();
}

class _ClientsOperationScreenState extends State<ClientsOperationScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  var formKey = GlobalKey<FormState>();
  @override
  void initState() {
    nameController = TextEditingController(text: widget.client?.name ?? '');
    emailController = TextEditingController(text: widget.client?.email ?? '');
    phoneController = TextEditingController(text: widget.client?.phone ?? '');
    addressController =
        TextEditingController(text: widget.client?.address ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: textInApp(
            text: widget.client == null ? 'Add New' : 'Edit Client',
            color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DefaultTextFormField(
                  label: 'Client Name',
                  controller: nameController,
                  validatorText: 'Name',
                  prefixIcon: Icons.person,
                ),
                DefaultTextFormField(
                  label: 'Client Email',
                  prefixIcon: Icons.email,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validatorText: "Email",
                ),
                DefaultTextFormField(
                  label: 'Client Phone',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: phoneController,
                  validatorText: "Client Phone",
                  maxLength: 11,
                ),
                DefaultTextFormField(
                  label: 'Client Address',
                  prefixIcon: Icons.home,
                  controller: addressController,
                  validatorText: "Client Address",
                ),
                const SizedBox(
                  height: 50,
                ),
                DefaultButton(
                    text: widget.client == null ? 'Submit' : 'Edit',
                    onPressed: () async {
                      await onSubmit();
                    }),
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
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.client == null) {
          //add
          await sqlHelper.database!
              .insert('clients', conflictAlgorithm: ConflictAlgorithm.replace, {
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'address': addressController.text,
          });
        } else {
          // update
          await sqlHelper.database!.update(
              'clients',
              {
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'address': addressController.text,
              },
              where: 'id =?',
              whereArgs: [widget.client?.id]);
        }

        defaultSnackBar(
            context: context,
            text: widget.client == null
                ? 'Client added Successfully'
                : 'Client Updated Successfully',
            backgroundColor: Colors.green);
        Navigator.pop(context, true);
      }
    } catch (error) {
      defaultSnackBar(
          context: context,
          text: widget.client == null
              ? "Error when adding Client"
              : "Error when updating Client",
          backgroundColor: Colors.red);
      print("Error when adding Client : $error");
    }
  }
}
