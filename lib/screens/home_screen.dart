import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/shared_component/home_header_widgets.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../helpers/sql_helper.dart';
import '../shared_component/my_data.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    init();
    fetchData();

    super.initState();
  }

  void init() async {
    result = await GetIt.I.get<SqlHelper>().createTable();
    await GetIt.I.get<SqlHelper>().insertInitialData();
    await fetchExChargeRateData();
    setState(() {
      isLoading = false;
    });
  }

  double todaySales = 0.0;
  Future<void> fetchData() async {
    todaySales = await GetIt.I.get<SqlHelper>().getTodaySales();
    setState(() {});
  }

  double exchangeRate = 0.0;
  Future<void> fetchExChargeRateData() async {
    exchangeRate = await GetIt.I.get<SqlHelper>().getExchangeRate('USD', 'EGP');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            children: [
              Container(
                  color: const Color.fromRGBO(15, 87, 217, 1),
                  width: double.infinity,
                  child: ListTile(
                    leading: textInApp(
                        text: "Database BackUp",
                        color: Colors.white,
                        fontSize: 25),
                    trailing: const Icon(
                      Icons.backup,
                      color: Colors.white,
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
              Container(
                  color: const Color.fromRGBO(7, 60, 154, 1.0),
                  width: double.infinity,
                  child: ListTile(
                    leading: textInApp(
                        text: "About us", color: Colors.white, fontSize: 30),
                    trailing: const Icon(
                      Icons.group,
                      color: Colors.white,
                    ),
                  )),
            ],
          ),
        ),
      ),
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
            width: double.infinity,
            height: 290,
            color: const Color.fromRGBO(15, 87, 217, 1),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          textInApp(
                              text: "POS App",
                              color: Colors.white,
                              fontSize: 30),
                        ],
                      ),
                    ),
                    isLoading
                        ? Transform.scale(
                            scale: 0.5,
                            child: const CircularProgressIndicator(
                              color: Colors.cyan,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: CircleAvatar(
                              backgroundColor:
                                  result ? Colors.green : Colors.red,
                              radius: 10,
                              child: Icon(
                                result ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                  ],
                ),
                homeHeader(
                  text1: "ExCharge rate",
                  text2: "1 USD = $exchangeRate EGP ",
                ),
                homeHeader(
                    text1: "Today's sales ",
                    text2: "$todaySales Egp ",
                    needFunction: true,
                    onPressed: () {
                      fetchData();
                    }),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              padding: const EdgeInsets.only(left: 20, right: 15, top: 30),
              itemBuilder: (context, index) => homeCard(
                context: context,
                heroTag: index,
                page: screens[index],
                text: cardTexts[index],
                icon: cardIcons[index],
                iconColor: cardCircleIconColor[index],
              ),
              itemCount: 5,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
