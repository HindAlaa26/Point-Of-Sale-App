import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../shared_component/page_data.dart';

class Clients extends StatelessWidget {
  const Clients({super.key,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: textInApp(text:"Clients",color: Colors.white),
      ),
      body: pageDataNotFound(index: 2) ,
    );
  }
}