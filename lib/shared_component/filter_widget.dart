import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

Widget filterData(
    {required String text, required TextEditingController controller}) {
  return Row(
    children: [
      textInApp(text: text, fontSize: 20),
      const SizedBox(
        width: 30,
      ),
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
