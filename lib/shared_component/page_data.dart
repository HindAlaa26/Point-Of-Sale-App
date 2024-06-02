import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/my_data.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

Widget pageDataNotFound({
  required int index,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: index,
          child: CircleAvatar(
            backgroundColor: cardCircleIconColor[index].withOpacity(0.3),
            radius: 100,
            child: Icon(
              cardIcons[index],
              size: 70,
              color: cardCircleIconColor[index],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          children: [
            textInApp(
                text: cardTexts[index],
                fontWeight: FontWeight.bold,
                fontSize: 50,
                color: Colors.grey),
            textInApp(
                text: "(No Data)",
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.grey),
          ],
        )
      ],
    ),
  );
}
