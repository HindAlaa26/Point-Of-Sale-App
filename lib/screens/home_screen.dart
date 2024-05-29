import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/screens/clients.dart';
import 'package:point_of_sales/screens/products.dart';
import 'package:point_of_sales/shared_component/home_header_widgets.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import '../helpers/sql_helper.dart';
import 'all_sales.dart';
import 'categories.dart';
import 'new_sale.dart';

class HomePage extends StatefulWidget {
   HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 List<String> cardTexts = ["All sales","Products","clients","New sale","Categories"];

 List<IconData> cardIcons = [
   Icons.storage_outlined,
   Icons.inventory,
   Icons.group,
   Icons.shopping_basket,
   Icons.category,
 ];

 List<Color> cardCircleIconColor = [
   Colors.deepOrangeAccent,
   Colors.pink,
   Colors.cyan,
   Colors.green,
   Colors.orange,
 ];
 List<Widget> screens = [];

 bool isLoading = true;
 bool result = false;

 @override
  void initState()
 {
   init();
   createScreens();
   super.initState();
 }
 void createScreens() {
 screens = [
 AllSalesPage(color: cardCircleIconColor[0], text: cardTexts[0], icon: cardIcons[0], heroTag: 0,),
 Products(color: cardCircleIconColor[1] ,text: cardTexts[1],icon: cardIcons[1],heroTag: 1,),
 Clients(color:  cardCircleIconColor[2],text: cardTexts[2],icon: cardIcons[2],heroTag: 2,),
 NewSale(color:  cardCircleIconColor[3],text: cardTexts[3],icon: cardIcons[3],heroTag: 3,),
 Categories(color:cardCircleIconColor[4],text: cardTexts[4],icon: cardIcons[4],heroTag: 4,),
 ];
 }
 void init()async
 {
   result = await GetIt.I.get<SqlHelper>().createTable();
   setState(() {
     isLoading = false;
   });
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: const Drawer(),
     appBar: AppBar(),
     body: Column(
       children: [
         Container(
           padding: const EdgeInsets.only(left: 20,top: 20,bottom: 20),
           width: double.infinity,
           height: 275,
           color:const Color.fromRGBO(15, 87, 217, 1),
           child: Column(
              children: [
                Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          textInApp(text: "POS App",color: Colors.white,fontSize: 30),
                        ],
                      ),
                    ),
                   isLoading ? Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(
                        color: Colors.cyan,
                      ),
                    ):
                     Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: CircleAvatar(
                        backgroundColor: result ? Colors.green : Colors.red,
                        radius: 10,
                        child: Icon(result ? Icons.check : Icons.close,color: Colors.white, size: 10,) ,
                      ),
                    ),
                  ],
                ),
                homeHeader(text1: "ExCharge rate",text2: "1 USD = 50 Egp "),
                homeHeader(text1: "Today's sales ",text2: "1 USD = 1200 Egp "),
              ],
           ),
         ),
         Expanded(
           child: GridView.builder
             (
               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount
                 (
                 crossAxisCount: 2,
                 mainAxisSpacing: 10,
                 crossAxisSpacing: 10,
               ),
               padding: const EdgeInsets.only(left: 20,right: 15,top: 30),
               itemBuilder: (context, index) => homeCard(
                 context: context,
                 heroTag: index,
                 page: screens[index],
                 text: cardTexts[index] ,
                 icon: cardIcons[index] ,
                 iconColor:cardCircleIconColor[index] ,
               ),
               itemCount: 5,
           ),
         ),
         const SizedBox(height: 20,),
       ],
     ),
    );
  }
}
