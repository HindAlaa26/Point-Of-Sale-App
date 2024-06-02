import 'package:flutter/material.dart';

Widget textInApp(
    {required String text,
    Color color = Colors.black,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.normal}) {
  return Text(text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ));
}
