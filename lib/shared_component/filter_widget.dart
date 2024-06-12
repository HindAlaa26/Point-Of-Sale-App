import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

Widget filterData({
  required String text,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.number,
  List<TextInputFormatter>? inputFormatters,
  bool isNumeric = false,
}) {
  if (isNumeric) {
    keyboardType = TextInputType.number;
    inputFormatters ??= [FilteringTextInputFormatter.digitsOnly];
  }
  return Row(
    children: [
      textInApp(text: text, fontSize: 20),
      const SizedBox(
        width: 30,
      ),
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            fillColor: Colors.blueGrey.shade200,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
      const SizedBox(
        width: 50,
      ),
    ],
  );
}
