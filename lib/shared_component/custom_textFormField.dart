import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

class DefaultTextFormField extends StatelessWidget {
  const DefaultTextFormField({
    super.key,
    required this.controller,
    required this.validatorText,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.onSaved,
    required this.prefixIcon,
  });
  final TextEditingController controller;
  final String validatorText;
  final String label;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData prefixIcon;
  final void Function(String?)? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  InputBorder get textFieldBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        onFieldSubmitted: onSaved,
        inputFormatters: inputFormatters,
        validator: (value) {
          if (value!.isEmpty) {
            return '$validatorText must not be empty';
          }
          return null;
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
