import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/arguments/menu_detail_arguments.dart';
import 'package:food_delivery/components/bottom_navigation_bar.dart';
import 'package:food_delivery/components/custom_menu_app_bar.dart';
import 'package:food_delivery/components/snackbars.dart';
import 'package:food_delivery/main.dart';
import 'package:food_delivery/models/menu_model.dart';
import 'package:food_delivery/network/dio_client.dart';
import 'package:intl/intl.dart';

class MenuDetail extends StatefulWidget {
  const MenuDetail({super.key});

  @override
  State<MenuDetail> createState() => _MenuDetailState();
}

class _MenuDetailState extends State<MenuDetail> {
  late int _restaurantId;
  late int _menuId;
  Menu? _menuDetail;

  int _quantity = 1;

  Future<void> _getMenuDetail() async {
    var dioClient = DioClient();

    try {
      var response =
          await dioClient.dio.get("/restaurants/$_restaurantId/menus/$_menuId");

      var data = response.data["data"];
      if (mounted) {
        setState(() {
          _menuDetail = Menu.fromJson(data);
        });
      }
    } on DioException catch (_) {
      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(
        showInvalidSnackbar("Unknown error"),
      );
    }
  }

  Future<void> _addToCart() async {
    var dioClient = DioClient();

    try {
      var response = await dioClient.dio.post("/orders/customers", data: {
        "restaurant_id": _restaurantId,
        "menu_id": _menuId,
        "quantity": _quantity
      });

      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(
        showValidSnackbar(response.data["message"] as String),
      );

      Navigator.of(context).pop();
    } on DioException catch (_) {
      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(
        showInvalidSnackbar("Unknown error"),
      );
    }
  }

  String _formatCurrency(int number) {
    NumberFormat currency = NumberFormat.simpleCurrency(
      locale: "en_US",
      name: "IDR",
      decimalDigits: 0,
    );
    return currency.format(number);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as MenuDetailArguments;
      _restaurantId = arguments.restaurantId;
      _menuId = arguments.menuId;
      _getMenuDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_menuDetail == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomMenuAppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    _menuDetail!.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _menuDetail!.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 30),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _menuDetail!.category,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Text(_menuDetail!.description),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      _priceTag(),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_quantity > 1) {
                                  _quantity--;
                                }
                              });
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 4, 202, 138),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            _quantity.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 4, 202, 138),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            _addToCartButton(),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
      );
    }
  }

  Row _priceTag() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Price:",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        Text(
          _formatCurrency(_menuDetail!.price),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        )
      ],
    );
  }

  Padding _addToCartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextButton(
        onPressed: _addToCart,
        style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: const Color.fromARGB(255, 4, 202, 138),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(
          "Add to cart - ${_formatCurrency(_menuDetail!.price * _quantity)}",
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
