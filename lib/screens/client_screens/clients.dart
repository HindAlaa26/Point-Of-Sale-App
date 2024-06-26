import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/shared_component/custom_table.dart';
import 'package:point_of_sales/shared_component/default_snackbar.dart';
import 'package:point_of_sales/shared_component/drop_down_button.dart';
import 'package:point_of_sales/shared_component/filter_widget.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../../helpers/sql_helper.dart';
import '../../models/client_model.dart';
import 'client_operations.dart';

class Clients extends StatefulWidget {
  const Clients({
    super.key,
  });

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  @override
  void initState() {
    getClients();
    super.initState();
  }

  List<Client>? clients;
  getClients() async {
    clients = [];
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.query('clients');

      if (data.isNotEmpty) {
        for (var item in data) {
          clients ??= [];
          clients?.add(Client.fromJson(item));
        }
      } else {
        clients = [];
      }
      print("client Data=================$data");
      setState(() {});
    } catch (e) {
      print('Error in get clients $e');
    }
  }

  bool sortAscend = false;
  int? sortColumnIndex;

  Future<void> deleteClient({required Client client}) async {
    try {
      var dialogResult = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  textInApp(
                      text: "Confirm",
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textInApp(text: "client Name : "),
                  textInApp(text: " ${client.name}", color: Colors.blueGrey),
                  textInApp(text: "client email : "),
                  textInApp(text: " ${client.email}", color: Colors.blueGrey),
                  textInApp(text: "client phone : "),
                  textInApp(text: " ${client.phone}", color: Colors.blueGrey),
                  textInApp(text: "client address : "),
                  textInApp(text: " ${client.address}", color: Colors.blueGrey),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        await sqlHelper.database!
            .delete("clients", where: 'id = ?', whereArgs: [client.id]);
        getClients(); // Refresh the categories list
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text('client deleted Successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error when deleting client ${client.name}')));
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  textInApp(
                      text: "Error",
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textInApp(
                      text:
                          "${client.name} is found in all sales screen, please delete this client from all sales screen first",
                      color: Colors.blue.shade700),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          });
      print('Error when deleting client $e');
    }
  }

  var nameController = TextEditingController();

  Future<void> filterByName() async {
    String? name = nameController.text;
    if (name.isEmpty) {
      defaultSnackBar(
          text: 'Please enter a valid name',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.database!.rawQuery("""
                         Select * from clients 
                      where name == ?                       
                        """, [name]);

    if (data.isNotEmpty) {
      clients = [];
      for (var item in data) {
        clients?.add(Client.fromJson(item));
      }
    } else {
      clients = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: textInApp(text: "Clients", color: Colors.white),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientsOperationScreen(),
                    ));
                if (result ?? false) {
                  getClients();
                }
              },
              icon: const Icon(
                Icons.add,
                size: 25,
              ))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 5, bottom: 10, right: 10),
            child: Row(
              children: [
                //Search
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        label: textInApp(text: "Search"),
                        enabledBorder: const OutlineInputBorder(),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color.fromRGBO(15, 87, 217, 1)),
                        ),
                        prefixIcon: const Icon(Icons.search)),
                    onChanged: (text) async {
                      if (text == '') {
                        getClients();
                        return;
                      }

                      var sqlHelper = GetIt.I.get<SqlHelper>();
                      var data = await sqlHelper.database!.rawQuery("""
                      Select * from clients 
                      where name like '%$text%' OR email like '%$text%'
                      OR phone like '%$text%'
                      OR address like '%$text%'
                      """);

                      if (data.isNotEmpty) {
                        clients = [];
                        for (var item in data) {
                          clients?.add(Client.fromJson(item));
                        }
                      } else {
                        clients = [];
                      }
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                //sort
                ClientsSortDropDownButton(
                  selectedValue: sortColumnIndex,
                  onChanged: (int? value) {
                    sortColumnIndex = value;
                    sortAscend = true;
                    print("value===================$value");
                    setState(() {});
                  },
                ),
                //filter
                MaterialButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  textInApp(
                                      text: "Filter According To :",
                                      fontSize: 25,
                                      color: Colors.blueGrey),
                                ],
                              ),
                              filterData(
                                  text: "Name",
                                  controller: nameController,
                                  keyboardType: TextInputType.name,
                                  isNumeric: false),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey),
                                  onPressed: () {
                                    if (nameController.text.isNotEmpty) {
                                      filterByName();
                                      nameController.clear();
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: textInApp(
                                      text: "Apply Filters",
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  padding: const EdgeInsets.only(top: 1),
                  minWidth: 0,
                  child: const Icon(
                    Icons.filter_list_sharp,
                    color: Colors.blueGrey,
                    size: 35,
                  ),
                ),
              ],
            ),
          ),
          DefaultTable(
            index: 2,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscend,
            columns: [
              DataColumn(
                label:
                    Center(child: textInApp(text: 'Id', color: Colors.white)),
              ),
              DataColumn(
                  onSort: (columnIndex, ascending) {
                    if (sortColumnIndex == 1) {
                      sortAscend = ascending;
                      sortColumnIndex = 1;
                      setState(() {});

                      if (ascending) {
                        clients!.sort((a, b) => a.name!.compareTo(b.name!));
                      } else {
                        clients!.sort((b, a) => a.name!.compareTo(b.name!));
                      }
                    }
                  },
                  label: Center(
                      child: textInApp(text: "Name", color: Colors.white))),
              DataColumn(
                  label: Center(
                      child: textInApp(text: "Email", color: Colors.white))),
              DataColumn(
                  label: Center(
                      child: textInApp(text: "Phone", color: Colors.white))),
              DataColumn(
                  label: Center(
                      child: textInApp(text: "Address", color: Colors.white))),
              DataColumn(
                  label: Center(
                      child: textInApp(text: "Actions", color: Colors.white))),
            ],
            minWidth: 1500,
            dataSource: ClientDataSource(
              clients: clients,
              onDelete: (client) async {
                await deleteClient(client: client);
              },
              onUpdate: (client) async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => ClientsOperationScreen(
                              client: client,
                            )));

                if (result ?? false) {
                  getClients();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ClientDataSource extends DataTableSource {
  List<Client>? clients;
  void Function(Client)? onDelete;
  void Function(Client)? onUpdate;
  ClientDataSource({this.clients, this.onDelete, this.onUpdate});
  @override
  DataRow? getRow(int index) {
    return DataRow2(
        color: MaterialStateProperty.all(Colors.blue.shade100),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.blue),
        cells: [
          DataCell(
            Center(child: textInApp(text: "${clients?[index].id}")),
          ),
          DataCell(Center(child: textInApp(text: "${clients?[index].name}"))),
          DataCell(Center(child: textInApp(text: "${clients?[index].email}"))),
          DataCell(Center(child: textInApp(text: "${clients?[index].phone}"))),
          DataCell(
              Center(child: textInApp(text: "${clients?[index].address}"))),
          DataCell(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  onUpdate!(clients![index]);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.blueGrey.shade800,
                ),
                onPressed: () async {
                  onDelete!(clients![index]);
                },
              ),
            ],
          )),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => clients?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
