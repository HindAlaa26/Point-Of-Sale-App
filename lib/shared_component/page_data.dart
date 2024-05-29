import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

Widget pageDataNotFound({
   required String text,
   required IconData icon,
   required Color color,
   required int heroTag,
})
{
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: heroTag,
          child: CircleAvatar(backgroundColor: color.withOpacity(0.3), radius: 100,
            child:   Icon( icon,size: 70,color: color,),
          ),
        ),
        const SizedBox(height: 20,),
        textInApp(text: text, fontWeight: FontWeight.bold,fontSize: 50,color: Colors.grey)
      ],
    ),
  );
}