import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../shared_component/page_data.dart';

class Products extends StatelessWidget {
  const Products({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: textInApp(text:"Products",color: Colors.white),
      ),
      body: pageDataNotFound(index: 1) ,
    );
  }
}