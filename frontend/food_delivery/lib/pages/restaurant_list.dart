import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:food_delivery/components/bottom_navigation_bar.dart';
import 'package:food_delivery/main.dart';
import 'package:food_delivery/models/restaurants_model.dart';
import 'package:food_delivery/network/dio_client.dart';
import 'package:intl/intl.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = "";

  bool _currentlyOpened = false;

  final List<String> _sortOptions = ["name", "-name", "rating", "-rating"];
  String _sortedBy = "name";

  final List<Restaurants> _restaurants = [];
  bool _isLoading = false;
  int _currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        _searchQuery = _searchController.text;
        _currentPage = 1;
        _restaurants.clear();
      });
      _getRestaurants();
    });
  }

  Future<void> _showFilterBottomSheet() async {
    bool tempCurrentlyOpened = _currentlyOpened;
    String? tempSortedBy = _sortedBy;

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setModalState,
          ) {
            return Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Filter",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                    const Divider(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Currently opened",
                            style: TextStyle(fontSize: 16),
                          ),
                          Switch(
                            value: tempCurrentlyOpened,
                            activeColor: const Color.fromARGB(255, 4, 202, 138),
                            onChanged: (bool value) {
                              setModalState(() {
                                tempCurrentlyOpened = value;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Sort",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                    const Divider(height: 40),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: _sortOptions.map(
                          (option) {
                            return RadioListTile<String>(
                              title: Text(_getSortLabel(option)),
                              value: option,
                              groupValue: tempSortedBy,
                              onChanged: (String? value) {
                                setModalState(() {
                                  tempSortedBy = value;
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (_currentlyOpened != tempCurrentlyOpened) {
      setState(() {
        _currentlyOpened = tempCurrentlyOpened;
        _currentPage = 1;
        _restaurants.clear();
      });
      _getRestaurants();
    }

    if (_sortedBy != tempSortedBy) {
      setState(() {
        _sortedBy = tempSortedBy!;
        _currentPage = 1;
        _restaurants.clear();
      });
      _getRestaurants();
    }
  }

  String _getSortLabel(String option) {
    switch (option) {
      case "name":
        return "Name ascending";
      case "-name":
        return "Name descending";
      case "rating":
        return "Rating ascending";
      case "-rating":
        return "Rating descending";
      default:
        return "Unknown sort";
    }
  }

  Future<void> _getRestaurants() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    var dioClient = DioClient();

    try {
      var response = await dioClient.dio.get("/restaurants", queryParameters: {
        "currentPage": _currentPage,
        "sort": _sortedBy,
        "time": _currentlyOpened ? _getFormattedCurrentTime() : null,
        "name": _searchQuery.isNotEmpty ? _searchQuery : null,
      });

      var data = response.data["data"] as List;
      if (mounted) {
        setState(() {
          _restaurants
              .addAll(data.map((json) => Restaurants.fromJson(json)).toList());
          _currentPage++;
          _isLoading = false;
        });
      }
    } on DioException catch (_) {
      if (!mounted) return;
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text("Unknown error"),
          backgroundColor: const Color.fromARGB(255, 255, 130, 2),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "Dismiss",
            onPressed: () {
              snackbarKey.currentState?.hideCurrentSnackBar();
            },
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  String _formatTime(String timeString) {
    DateTime time = DateFormat("HH:mm:ss").parse(timeString);
    return DateFormat("HH:mm").format(time);
  }

  String _getFormattedCurrentTime() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat("HH:mm").format(now);
    return formattedTime;
  }

  @override
  void initState() {
    super.initState();
    _getRestaurants();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getRestaurants();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Restaurants",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
            child: Column(
              children: [
                _searchField(),
                const SizedBox(height: 10),
                _filterAndSort(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: ListView.separated(
                controller: _scrollController,
                itemCount: _restaurants.length,
                itemBuilder: (BuildContext context, int index) {
                  final restaurant = _restaurants[index];
                  if (index < _restaurants.length) {
                    return _activeListView(restaurant);
                  } else if (_isLoading) {
                    return _loadingProgress();
                  } else {
                    return Container();
                  }
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Center _loadingProgress() => const Center(child: CircularProgressIndicator());

  Container _activeListView(Restaurants restaurant) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Image.network(
            restaurant.imagePath,
            width: 100,
            height: 100,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/clock.svg",
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${_formatTime(restaurant.openingTime)} - ${_formatTime(restaurant.closingTime)}",
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RatingBarIndicator(
                      itemBuilder: (BuildContext context, int index) =>
                          const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      rating: restaurant.rating,
                      itemCount: 5,
                      direction: Axis.horizontal,
                      itemSize: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      restaurant.rating.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  TextButton _filterAndSort() {
    return TextButton.icon(
      onPressed: _showFilterBottomSheet,
      icon: SvgPicture.asset(
        "assets/icons/filter.svg",
        width: 25,
        height: 25,
      ),
      label: const Text(
        "Filter & sort",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  TextField _searchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            width: 10,
            height: 10,
            "assets/icons/search.svg",
            fit: BoxFit.scaleDown,
          ),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _searchController.clear,
              )
            : null,
        hintText: "Where do you want to eat?",
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
