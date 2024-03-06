import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color.fromARGB(255, 4, 202, 138),
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.of(context).pushNamed("restaurant-list");
          case 1:
            Navigator.of(context).pushNamed("order-history");
          default:
            Navigator.of(context).pushNamed("account");
        }
      },
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.local_restaurant,
              color: currentIndex == 0
                  ? const Color.fromARGB(255, 4, 202, 138)
                  : Colors.black,
              size: 30,
            ),
            label: "Restaurants"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              color: currentIndex == 1
                  ? const Color.fromARGB(255, 4, 202, 138)
                  : Colors.black,
              size: 30,
            ),
            label: "Order History"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              color: currentIndex == 2
                  ? const Color.fromARGB(255, 4, 202, 138)
                  : Colors.black,
              size: 30,
            ),
            label: "Account"),
      ],
    );
  }
}
