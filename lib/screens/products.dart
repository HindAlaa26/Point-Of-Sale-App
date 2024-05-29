import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../shared_component/page_data.dart';

class Products extends StatelessWidget {
  const Products({super.key, required this.text, required this.icon, required this.color, required this.heroTag});
  final String text;
  final IconData icon;
  final Color color;
  final int heroTag;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: textInApp(text:"Products",color: Colors.white),
      ),
      body: pageDataNotFound(
        color: color,
        icon: icon,
        text: text,
        heroTag: heroTag,
      ) ,
    );
  }
}