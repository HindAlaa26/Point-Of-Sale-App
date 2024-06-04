import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/page_data.dart';

class DefaultTable extends StatelessWidget {
  final List<DataColumn> columns;
  final DataTableSource dataSource;
  final double minWidth;
  final int index;
  const DefaultTable(
      {required this.columns,
      required this.dataSource,
      required this.index,
      this.minWidth = 800,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.black, size: 26),
          textTheme: const TextTheme(
            caption: TextStyle(
                color: Color.fromRGBO(15, 87, 217, 1),
                fontSize: 20), // "Rows per page" text style
          ),
        ),
        child: PaginatedDataTable2(
          empty: Center(child: pageDataNotFound(index: index)),
          border: TableBorder.all(color: Colors.black),
          headingRowColor:
              MaterialStateProperty.all(const Color.fromRGBO(15, 87, 217, 1)),
          minWidth: minWidth,
          rowsPerPage: 10,
          renderEmptyRowsInTheEnd: false,
          horizontalMargin: 10,
          headingRowHeight: 60,
          dataRowHeight: 100,
          showFirstLastButtons: true,
          fit: FlexFit.tight,
          autoRowsToHeight: true,
          columns: columns,
          source: dataSource,
        ),
      ),
    );
  }
}
