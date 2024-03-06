import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_delivery/components/bottom_navigation_bar.dart';
import 'package:food_delivery/components/snackbars.dart';
import 'package:food_delivery/main.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/network/dio_client.dart';
import 'package:intl/intl.dart';

class StatusOptions {
  final String text;
  final String value;

  StatusOptions({required this.text, required this.value});
}

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  bool _isLoading = false;

  final List<StatusOptions> _statusOptions = [
    StatusOptions(text: "Pending", value: "PENDING"),
    StatusOptions(text: "Order Placed", value: "PLACED"),
    StatusOptions(text: "In Kitchen", value: "IN_KITCHEN"),
    StatusOptions(text: "Out for Delivery", value: "OUT_FOR_DELIVERY"),
    StatusOptions(text: "Delivered", value: "DELIVERED")
  ];

  final ValueNotifier<String> _status = ValueNotifier<String>("PENDING");
  List<Order> _orders = [];

  Future<void> _getOrderHistory() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    var dioClient = DioClient();

    try {
      var response = await dioClient.dio.get(
        "/customers/orders",
        queryParameters: {
          "status": _status.value,
        },
      );

      var data = response.data["data"] as List;
      if (mounted) {
        setState(() {
          _orders = data.map((json) => Order.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } on DioException catch (_) {
      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(
        showInvalidSnackbar("Unknown error"),
      );
    }
  }

  Future<void> _checkoutOrder(int id) async {
    var dioClient = DioClient();

    try {
      var response = await dioClient.dio.post(
        "/customers/orders/checkout",
        data: {"order_id": id},
      );

      var message = response.data["message"];
      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(showValidSnackbar(message));
      _status.value = "PLACED";
    } on DioException catch (_) {
      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(
        showInvalidSnackbar("Unknown error"),
      );
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case "PENDING":
        return "Pending";
      case "PLACED":
        return "Placed";
      case "IN_KITCHEN":
        return "In Kitchen";
      case "OUT_FOR_DELIVERY":
        return "Out for Delivery";
      case "DELIVERED":
        return "Delivered";
      default:
        return "Pending";
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
      _getOrderHistory();
    });

    _status.addListener(() {
      _getOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(
              color: Color.fromARGB(255, 4, 202, 138),
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        shape: const Border(
            bottom: BorderSide(color: Color.fromARGB(40, 0, 0, 0))),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 75,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusOptions.length,
              itemBuilder: (BuildContext context, int index) {
                final StatusOptions option = _statusOptions[index];
                return _statusButton(option);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 10);
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final Order order = _orders[index];
                    if (index < _orders.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FadeInImage.assetNetwork(
                                  placeholder:
                                      "assets/images/fallback_image.png",
                                  image: order.restaurant.imagePath!,
                                  width: 50,
                                  height: 50,
                                ),
                                const SizedBox(width: 10),
                                _restaurantNameAndRating(order)
                              ],
                            ),
                            const SizedBox(height: 10),
                            _orderAndStatusBox(order),
                            _orderItemsSection(order),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total price:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(order.totalPrice),
                                )
                              ],
                            ),
                            _status.value == "PENDING"
                                ? const SizedBox(height: 20)
                                : Container(height: 0, width: 0),
                            _status.value == "PENDING"
                                ? TextButton(
                                    onPressed: () => _checkoutOrder(order.id),
                                    style: TextButton.styleFrom(
                                        minimumSize: const Size.fromHeight(40),
                                        backgroundColor: const Color.fromARGB(
                                            255, 4, 202, 138),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    child: const Text(
                                      "Checkout",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  )
                                : Container(height: 0, width: 0),
                          ],
                        ),
                      );
                    } else if (_isLoading) {
                      return _loadingProgress();
                    } else {
                      return Container();
                    }
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemCount: _orders.length),
            ),
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Row _orderAndStatusBox(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Orders",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 130, 2),
            border: Border.all(
              color: const Color.fromARGB(255, 255, 130, 2),
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Text(
            _formatStatus(order.status),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Column _orderItemsSection(Order order) {
    return Column(
      children: order.orderItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/images/fallback_image.png",
                      image: item.menuItem.imagePath!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.menuItem.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        (_formatCurrency(
                          item.menuItem.price,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
              Text(item.quantity.toString()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Expanded _restaurantNameAndRating(Order order) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.restaurant.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RatingBarIndicator(
                itemBuilder: (BuildContext context, int index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                rating: order.restaurant.rating,
                itemCount: 5,
                direction: Axis.horizontal,
                itemSize: 20,
              ),
              const SizedBox(width: 5),
              Text(
                order.restaurant.rating.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          )
        ],
      ),
    );
  }

  TextButton _statusButton(StatusOptions option) {
    return TextButton(
      onPressed: () => _status.value = option.value,
      style: TextButton.styleFrom(
        backgroundColor: _status.value == option.value
            ? const Color.fromARGB(255, 4, 202, 138)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
            color: _status.value == option.value
                ? const Color.fromARGB(255, 4, 202, 138)
                : Colors.black,
            width: 1),
      ),
      child: Text(
        option.text,
        style: TextStyle(
            color: _status.value == option.value ? Colors.white : Colors.black),
      ),
    );
  }

  Center _loadingProgress() => const Center(child: CircularProgressIndicator());
}
