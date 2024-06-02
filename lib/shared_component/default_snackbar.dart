import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> defaultSnackBar(
    {required BuildContext context,
    required String text,
    required Color backgroundColor}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      content: textInApp(text: text, color: Colors.white),
      elevation: 5,
      duration: const Duration(seconds: 1),
    ),
  );
}
