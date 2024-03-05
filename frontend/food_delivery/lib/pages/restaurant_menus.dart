import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery/components/bottom_navigation_bar.dart';
import 'package:food_delivery/components/custom_menu_app_bar.dart';
import 'package:food_delivery/components/snackbars.dart';
import 'package:food_delivery/main.dart';
import 'package:food_delivery/models/menu_model.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:food_delivery/network/dio_client.dart';
import 'package:intl/intl.dart';

class RestaurantMenus extends StatefulWidget {
  const RestaurantMenus({super.key});

  @override
  State<RestaurantMenus> createState() => _RestaurantMenusState();
}

class _RestaurantMenusState extends State<RestaurantMenus> {
  late int _restaurantId;
  Restaurant? _restaurantDetail;

  final List<Menu> _menus = [];
  bool _isLoading = false;
  int _currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  Future<void> _getRestaurantDetail() async {
    var dioClient = DioClient();

    try {
      var response = await dioClient.dio.get("/restaurants/$_restaurantId");

      var data = response.data["data"];
      if (mounted) {
        setState(() {
          _restaurantDetail = Restaurant.fromJson(data);
        });
      }
    } on DioException catch (_) {
      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(
        showInvalidSnackbar("Unknown error"),
      );
    }
  }

  Future<void> _getRestaurantMenus() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    var dioClient = DioClient();

    try {
      var response = await dioClient.dio.get(
        "/restaurants/$_restaurantId/menus",
        queryParameters: {
          "currentPage": _currentPage,
        },
      );

      var data = response.data["data"] as List;
      if (mounted) {
        setState(() {
          _menus.addAll(data.map((json) => Menu.fromJson(json)).toList());
          _currentPage++;
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

  String _formatTime(String timeString) {
    DateTime time = DateFormat("HH:mm:ss").parse(timeString);
    return DateFormat("HH:mm").format(time);
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
      final restaurantId = ModalRoute.of(context)?.settings.arguments as int;
      _restaurantId = restaurantId;
      _getRestaurantDetail();
      _getRestaurantMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_restaurantDetail == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomMenuAppBar(),
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.network(
                    _restaurantDetail!.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -225,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _restaurantDetail!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 30),
                          ),
                          _ratingAndOpenHours(),
                          const Divider(),
                          const Text(
                            "Address",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _restaurantDetail!.address,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Divider(),
                          const Text(
                            "Contact details",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _restaurantDetail!.email,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            _restaurantDetail!.phoneNumber,
                            style: const TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 200),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final menu = _menus[index];
                  if (index < _menus.length) {
                    return _activeListView(menu);
                  } else if (_isLoading) {
                    return _loadingProgress();
                  } else {
                    return Container();
                  }
                },
                itemCount: _menus.length,
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
      );
    }
  }

  Row _ratingAndOpenHours() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RatingBarIndicator(
          itemBuilder: (BuildContext context, int index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          rating: _restaurantDetail!.rating,
          itemCount: 5,
          direction: Axis.horizontal,
          itemSize: 20,
        ),
        const SizedBox(width: 5),
        Text(
          _restaurantDetail!.rating.toString(),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 10),
        const Text(
          "•",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            SvgPicture.asset(
              "assets/icons/clock.svg",
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 5),
            Text(
              "${_formatTime(_restaurantDetail!.openingTime)} - ${_formatTime(_restaurantDetail!.closingTime)}",
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
      ],
    );
  }

  Center _loadingProgress() => const Center(child: CircularProgressIndicator());

  GestureDetector _activeListView(Menu menu) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                menu.imagePath,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              menu.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              _formatCurrency(menu.price),
            ),
          ],
        ),
      ),
    );
  }
}
