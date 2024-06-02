import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

class DefaultButton extends StatelessWidget {
  void Function()? onPressed;
  final String text;

  DefaultButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(15, 87, 217, 1),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          fixedSize: const Size(double.maxFinite, 60),
        ),
        child: textInApp(
            text: text, color: Colors.white, fontWeight: FontWeight.bold));
  }
}
