import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  Widget _buildIcon(String assetPath, int index) {
    return SvgPicture.asset(
      assetPath,
      width: 30,
      height: 30,
      colorFilter: currentIndex == index
          ? const ColorFilter.mode(
              Color.fromARGB(255, 4, 202, 138), BlendMode.srcIn)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color.fromARGB(255, 4, 202, 138),
      items: [
        BottomNavigationBarItem(
            icon: _buildIcon("assets/icons/restaurant.svg", 0),
            label: "Restaurants"),
        BottomNavigationBarItem(
            icon: _buildIcon("assets/icons/history.svg", 1),
            label: "Order History"),
        BottomNavigationBarItem(
            icon: _buildIcon("assets/icons/account_circle.svg", 2),
            label: "Account"),
      ],
    );
  }
}
