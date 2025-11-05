import 'package:flutter/material.dart';
import 'pages/Home.dart';
// import 'pages/InventoryPage.dart';
// import 'services/api_service.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '庫存系統',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeNavigator(),
    );
  }
}






