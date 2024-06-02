import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../shared_component/page_data.dart';

class AllSalesPage extends StatelessWidget {
  const AllSalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: textInApp(text:"All Sales",color: Colors.white),
      ),
      body: pageDataNotFound(index: 0) ,
    );
  }
}
