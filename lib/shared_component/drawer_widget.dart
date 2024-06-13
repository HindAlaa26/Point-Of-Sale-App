import 'package:flutter/material.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';

Widget drawerWidget(BuildContext context) {
  return Drawer(
    backgroundColor: const Color.fromRGBO(7, 60, 154, 1.0),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              "https://media.istockphoto.com/id/1185198184/photo/cashier-at-work.jpg?s=612x612&w=0&k=20&c=C04zFpYJY0k8aA_OImXdzYppbgC_dcsoqWHYekD84MA=",
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.info,
                color: Colors.blueGrey,
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return const CircularProgressIndicator(
                    color: Colors.amber,
                  );
                }
              },
            ),
            const Divider(),
            textInApp(
                color: Colors.white,
                fontSize: 20,
                text:
                    "A Point of Sale (POS) application is a versatile system designed to streamline sales transactions, featuring an intuitive user interface, quick checkout processes, real-time inventory management, and comprehensive customer relationship management. It provides essential accessibility features like adding category,products,clients and make new sales. The POS application includes reliable on-device backup capabilities, allowing for automated and manual backups directly to the device, ensuring data integrity and business continuity without relying on cloud storage."),
            const Divider(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(7, 74, 192, 1.0)),
                onPressed: () {

                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    textInApp(text: "Back Up", color: Colors.white),
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      Icons.backup,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    ),
  );
}
