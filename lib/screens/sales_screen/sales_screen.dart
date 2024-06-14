import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:point_of_sales/helpers/sql_helper.dart';
import 'package:point_of_sales/models/order_item_model.dart';
import 'package:point_of_sales/models/order_model.dart';
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/shared_component/custom_button.dart';
import 'package:point_of_sales/shared_component/custom_textFormField.dart';
import 'package:point_of_sales/shared_component/default_snackbar.dart';
import 'package:point_of_sales/shared_component/drop_down_button.dart';
import 'package:point_of_sales/shared_component/text_in_app.dart';
import 'package:sqflite/sqflite.dart';
import '../../shared_component/page_data.dart';

class SalesScreen extends StatefulWidget {
  final Order? order;
  const SalesScreen({this.order, super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Product>? products;
  List<OrderItem>? selectedOrderItems;
  var discountController = TextEditingController();
  bool addDiscount = false;
  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.rawQuery("""
  Select P.*,C.name as categoryName,C.description as categoryDescription from products P
  Inner JOIN categories C
  On P.categoryId = C.id
  """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products?.add(Product.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      products = [];
      print('Error in get Products $e');
    }
    setState(() {});
  }

  var formKey = GlobalKey<FormState>();
  String? orderLabel;
  @override
  void initState() {
    initPage();
    selectedClientId = widget.order?.clientId;
    if (widget.order != null) {
      // Initialize selectedOrderItems with existing order items
      getExistingOrderItems();
      // Set the discount value from the order
      discountController.text = widget.order!.discount.toString();
    }
    super.initState();
  }

  void initPage() {
    getProducts();
    orderLabel = widget.order == null
        ? '#OR${DateTime.now().millisecondsSinceEpoch}'
        : widget.order?.label;

    setState(() {});
  }

  int? selectedClientId;

  Future<void> getExistingOrderItems() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.database!.rawQuery("""
      SELECT OPI.*, P.* FROM orderProductItems OPI
      INNER JOIN products P ON OPI.productId = P.id
      WHERE OPI.orderId = ?
    """, [widget.order?.id]);
      print("Data >>>>>>>>>>>>>>>>>>>>>>>>>>$data");
      if (data.isNotEmpty) {
        setState(() {
          selectedOrderItems = []; // Clear the existing order items
          for (var item in data) {
            var orderItem = OrderItem.fromJson(item);
            orderItem.product = Product.fromJson(item);
            print("item>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$item");
            print("orderItem>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$orderItem");

            selectedOrderItems?.add(orderItem);
          }
        });
        print(
            "order items==================================${selectedOrderItems!.length}"); // Add the new order items
      } else {
        setState(() {
          selectedOrderItems = []; // Clear the existing order items
        });
      }
    } catch (e) {
      setState(() {
        selectedOrderItems = []; // Clear the existing order items
      });
      print('Error in getExistingOrderItems $e');
      // Show an error message to the user
      defaultSnackBar(
        context: context,
        text: 'Failed to load order items. Please try again.',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: textInApp(
            text: widget.order == null ? 'Add New Sale' : 'Update Sale',
            color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // label
            Container(
              color: Colors.yellow[100],
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: textInApp(
                  text: "Label : $orderLabel",
                  color: Colors.brown.shade300,
                  fontWeight: FontWeight.bold),
            ),
            // select & show and discount
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClientDropDownButton(
                    selectedValue: selectedClientId,
                    onChanged: (value) {
                      selectedClientId = value;
                      setState(() {});
                    },
                  ),
                  Container(
                    color: Colors.grey[300],
                    height: 700,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // show selected products
                        for (var orderItem in selectedOrderItems ?? [])
                          Expanded(
                            child: ListView(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: ListTile(
                                      leading: Image.network(
                                        orderItem.product?.image ?? '',
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.info,
                                          color: Colors.red,
                                        ),
                                      ),
                                      title: textInApp(
                                          text:
                                              '${orderItem.product?.name ?? 'No name'}'),
                                      subtitle: textInApp(
                                          text:
                                              "${orderItem.product!.price}  EGP",
                                          color: Colors.grey),
                                      trailing: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            border: Border.all(
                                                color: Colors.blueGrey),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: textInApp(
                                            text: "${orderItem.productCount}X",
                                            color: Colors.blue.shade900,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        // add product
                        DefaultButton(
                            text: widget.order == null
                                ? "Add Product"
                                : "Edit Product",
                            backgroundColor: Colors.blueGrey,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.grey[100],
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setStateEx) {
                                      return (products?.isEmpty ?? false)
                                          ? Center(
                                              child: pageDataNotFound(index: 3))
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: ListView(
                                                      children: [
                                                        for (var product
                                                            in products!)
                                                          ListTile(
                                                            subtitle: getOrderItem(
                                                                        product
                                                                            .id!) !=
                                                                    null
                                                                ? Row(
                                                                    children: [
                                                                      IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            if (getOrderItem(product.id!)!.productCount ==
                                                                                0) {
                                                                              return;
                                                                            }
                                                                            getOrderItem(product.id!)!.productCount =
                                                                                getOrderItem(product.id!)!.productCount! - 1;

                                                                            setStateEx(() {});
                                                                          },
                                                                          icon:
                                                                              const Icon(Icons.remove)),
                                                                      Text(
                                                                          '${getOrderItem(product.id!)?.productCount}'),
                                                                      IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            if (getOrderItem(product.id!)!.productCount ==
                                                                                getOrderItem(product.id!)!.product!.stock) {
                                                                              return;
                                                                            }
                                                                            getOrderItem(product.id!)!.productCount =
                                                                                getOrderItem(product.id!)!.productCount! + 1;

                                                                            setStateEx(() {});
                                                                          },
                                                                          icon:
                                                                              const Icon(Icons.add)),
                                                                    ],
                                                                  )
                                                                : const SizedBox(),
                                                            leading:
                                                                Image.network(
                                                              product.image ??
                                                                  "",
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  const Icon(
                                                                Icons.info,
                                                                color: Colors
                                                                    .blueGrey,
                                                              ),
                                                            ),
                                                            title: Text(
                                                                product.name ??
                                                                    'No name'),
                                                            trailing:
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      if (getOrderItem(
                                                                              product.id!) !=
                                                                          null) {
                                                                        onRemoveOrderItem(
                                                                            product.id!);
                                                                      } else {
                                                                        onAddOrderItem(
                                                                            product);
                                                                      }
                                                                      setStateEx(
                                                                          () {});
                                                                    },
                                                                    icon: getOrderItem(product.id!) ==
                                                                            null
                                                                        ? const Icon(Icons
                                                                            .add)
                                                                        : const Icon(
                                                                            Icons.delete)),
                                                          )
                                                      ],
                                                    ),
                                                  ),
                                                  DefaultButton(
                                                      text: widget.order == null
                                                          ? 'Select'
                                                          : 'Edit',
                                                      backgroundColor:
                                                          Colors.blueGrey,
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {});
                                                      })
                                                ],
                                              ),
                                            );
                                    },
                                  );
                                },
                              );
                              setState(() {});
                            }),
                        const SizedBox(
                          height: 20,
                        ),
                        textInApp(
                            text: "...................." * 3,
                            color: Colors.grey),
                        // total price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            textInApp(
                                text: "Total : ",
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold),
                            textInApp(
                                text: "$calculateTotalPrice EGP",
                                fontWeight: FontWeight.bold),
                          ],
                        ),
                        textInApp(
                            text: "...................." * 3,
                            color: Colors.grey),
                        const SizedBox(
                          height: 20,
                        ),
                        DefaultButton(
                            text: widget.order == null
                                ? 'Add Discount'
                                : 'Edit Discount',
                            backgroundColor: Colors.blueGrey,
                            onPressed: () {
                              addDiscount = true;
                              setState(() {});

                              // if (formKey.currentState!.validate() &&
                              //     discountController.text.isNotEmpty) {
                              //   addDiscount = false;
                              // }
                            }),
                        const SizedBox(
                          height: 5,
                        ),
                        addDiscount
                            ? Form(
                                key: formKey,
                                child: DefaultTextFormField(
                                    controller: discountController,
                                    validatorText: "Discount",
                                    keyboardType: TextInputType.number,
                                    label: "Discount",
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    // onSaved: (value) {
                                    //   if (formKey.currentState!.validate() &&
                                    //       value!.isNotEmpty) {
                                    //     addDiscount = false;
                                    //   }
                                    // },
                                    prefixIcon: Icons.discount),
                              )
                            : const SizedBox(),
                        textInApp(
                            text: "...................." * 3,
                            color: Colors.grey),
                        // total price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            textInApp(
                                text: "Total After Discount: ",
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold),
                            textInApp(
                                text: "$calculateTotalAfterDiscountPrice EGP",
                                fontWeight: FontWeight.bold),
                          ],
                        ),
                        textInApp(
                            text: "...................." * 3,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 10, left: 15, right: 15),
              child: DefaultButton(
                  text: widget.order == null ? "Confirm" : 'Update',
                  backgroundColor: Colors.green.shade800,
                  onPressed: () async {
                    await onSetOrder();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSetOrder() async {
    try {
      if (selectedOrderItems == null ||
          (selectedOrderItems?.isEmpty ?? false)) {
        defaultSnackBar(
          text: 'You Must Add Order Items First',
          backgroundColor: Colors.red,
          context: context,
        );
        return;
      }
      if (selectedClientId == null) {
        defaultSnackBar(
          text: 'You Must Add Client',
          backgroundColor: Colors.red,
          context: context,
        );
        return;
      }
      var sqlHelper = GetIt.I.get<SqlHelper>();
      if (widget.order == null) {
        // Add new order
        var orderId = await sqlHelper.database!.insert(
          'orders',
          {
            'label': orderLabel,
            'totalPrice': calculateTotalAfterDiscountPrice,
            'discount': calculateDiscountPrice,
            'clientId': selectedClientId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        var batch = sqlHelper.database!.batch();
        for (var orderItem in selectedOrderItems!) {
          batch.insert(
            'orderProductItems',
            {
              'orderId': orderId,
              'productId': orderItem.productId,
              'productCount': orderItem.productCount,
            },
          );
        }
        var result = await batch.commit();

        print('Order items inserted: $result');
      } else {
        // Update existing order
        await sqlHelper.database!.update(
          'orders',
          {
            'totalPrice': calculateTotalAfterDiscountPrice,
            'discount': calculateDiscountPrice,
            'clientId': selectedClientId,
          },
          where: 'id = ?',
          whereArgs: [widget.order!.id],
        );

        print("Order ID for update: ${widget.order!.id}");

        // Get existing order items from the database
        var existingOrderItems = await sqlHelper.database!.query(
          'orderProductItems',
          where: 'orderId = ?',
          whereArgs: [widget.order!.id],
        );

        var existingOrderItemsMap = {
          for (var item in existingOrderItems) item['productId']: item
        };

        var batch = sqlHelper.database!.batch();
        for (var orderItem in selectedOrderItems!) {
          if (existingOrderItemsMap.containsKey(orderItem.productId)) {
            // Update existing order item
            batch.update(
              'orderProductItems',
              {
                'productCount': orderItem.productCount,
              },
              where: 'orderId = ? AND productId = ?',
              whereArgs: [
                widget.order!.id,
                orderItem.productId,
              ],
            );
          } else {
            // Insert new order item
            batch.insert('orderProductItems', {
              'orderId': widget.order!.id,
              'productId': orderItem.productId,
              'productCount': orderItem.productCount,
            });
          }
        }

        // Delete order items that are no longer in selectedOrderItems
        var selectedProductIds =
            selectedOrderItems!.map((item) => item.productId).toSet();
        for (var existingItem in existingOrderItems) {
          if (!selectedProductIds.contains(existingItem['productId'])) {
            batch.delete(
              'orderProductItems',
              where: 'orderId = ? AND productId = ?',
              whereArgs: [
                widget.order!.id,
                existingItem['productId'],
              ],
            );
          }
        }

        var result = await batch.commit();
        print('Order items updated: $result');
      }

      defaultSnackBar(
        text: widget.order == null
            ? 'Order Created Successfully'
            : "Order Updated Successfully",
        backgroundColor: Colors.green,
        context: context,
      );
      Navigator.pop(context, true);
    } catch (e) {
      defaultSnackBar(
        text: widget.order == null
            ? 'Error When Order Created'
            : 'Error When Order Updated',
        backgroundColor: Colors.red,
        context: context,
      );
      print(widget.order == null
          ? 'Error When Order Created $e'
          : 'Error When Order Updated $e');
    }
  }

  OrderItem? getOrderItem(int productId) {
    for (var orderItem in selectedOrderItems ?? []) {
      if (orderItem.productId == productId) {
        return orderItem;
      }
    }
    return null;
  }

  double? get calculateTotalPrice {
    var totalPrice = 0.0;
    for (var orderItem in selectedOrderItems ?? []) {
      totalPrice = totalPrice +
          (orderItem?.productCount ?? 0) * (orderItem?.product?.price ?? 0);
    }
    return totalPrice;
  }

  double? get calculateTotalAfterDiscountPrice {
    var totalAfterDiscountPrice = 0.0;
    totalAfterDiscountPrice = (calculateTotalPrice! - calculateDiscountPrice!);
    return totalAfterDiscountPrice;
  }

  double? get calculateDiscountPrice {
    double discountPrice = 0.0;
    if (discountController.text.isNotEmpty) {
      try {
        discountPrice = double.parse(discountController.text);
      } catch (e) {
        // Handle the error or set discountPrice to 0 if parsing fails
        discountPrice = 0.0;
      }
    }

    return discountPrice;
  }

  void onRemoveOrderItem(int productId) {
    for (var i = 0; i < (selectedOrderItems?.length ?? 0); i++) {
      if (selectedOrderItems![i].productId == productId) {
        selectedOrderItems!.removeAt(i);
      }
    }
  }

  void onAddOrderItem(Product product) {
    var orderItem = OrderItem();
    orderItem.product = product;
    orderItem.productCount = 1;
    orderItem.productId = product.id;
    selectedOrderItems ??= [];
    selectedOrderItems!.add(orderItem);
    setState(() {});
  }
}
