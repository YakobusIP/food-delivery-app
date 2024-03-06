import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:food_delivery/components/bottom_navigation_bar.dart';
import 'package:food_delivery/services/storage_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final SecureStorageService _storageService = SecureStorageService();

  void _logout() async {
    await _storageService.deleteAll();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil("login", (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account",
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
          GestureDetector(
            onTap: _logout,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.logout, size: 30),
                  SizedBox(width: 10),
                  Text(
                    "Logout",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          const Divider()
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
