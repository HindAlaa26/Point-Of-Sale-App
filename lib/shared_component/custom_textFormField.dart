import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

class DefaultTextFormField extends StatelessWidget {
  const DefaultTextFormField({
    super.key,
    required this.controller,
    required this.validatorText,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    required this.prefixIcon,
  });
  final TextEditingController controller;
  final String validatorText;
  final String label;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData prefixIcon;
  InputBorder get textFieldBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return '$validatorText must not be empty';
          }
        },
        style: const TextStyle(
          fontSize: 20,
        ),
        cursorColor: Colors.blue,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: InputDecoration(
            label: textInApp(text: label, color: Colors.blueGrey.shade700),
            enabledBorder: textFieldBorder,
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.blueGrey,
            ),
            errorBorder: textFieldBorder.copyWith(
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: textFieldBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red)),
            focusedBorder: textFieldBorder.copyWith(
                borderSide: BorderSide(color: Colors.blue.shade900))),
        maxLines: null,
      ),
    );
  }
}
