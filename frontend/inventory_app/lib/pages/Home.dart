import 'package:flutter/material.dart';


import 'DeliveryPage.dart';
import 'InventoryPage.dart';
import 'LeftoverPage .dart';
import 'SchedulePage.dart';


class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const InventoryPage(),
    const DeliveryPage(),
    const LeftoverPage(),
    const SchedulePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 28,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: '庫存管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: '隔日提貨',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: '當日剩料',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '自動排程',
          ),
        ],
      ),
    );
  }
}