import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

Widget homeHeader({
  required String text1,
  required String text2,
})
{
  return  Container(
    margin: const EdgeInsets.only(right:10,top: 10,bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
      color: Colors.white38,
    ),
    child: Row(
      children: [
        Expanded(
            flex: 5,
            child: textInApp(text: text1,color: Colors.white,fontSize: 25)),
        const Spacer(),
        Expanded(
            flex: 4,
            child: textInApp(text: text2,color: Colors.white,fontSize: 17)),
      ],
    ),
  );
}

Widget homeCard({
  required String text,
  required IconData icon,
  required Color iconColor,
  required Widget page,
  required BuildContext context,
  required int heroTag,
})
{
  return InkWell(
    onTap: ()
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page,));

    },
    child: Container(
      width: 170,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5)
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: heroTag,
            child: CircleAvatar(backgroundColor: iconColor.withOpacity(0.3), radius: 40,
              child:  Icon(icon,size: 35,color: iconColor,),
            ),
          ),
          const SizedBox(height: 20,),
          textInApp(text: text, fontWeight: FontWeight.bold)
        ],
      ),
    ),
  );
}