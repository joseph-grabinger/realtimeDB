import 'package:flutter/material.dart';

import 'src/navigation.dart';


void main() {
  runApp(const CoreApp());
}

class CoreApp extends StatelessWidget {
  const CoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dunef Database Interface',
      theme: ThemeData(
        primaryColor: Colors.purple[600],
      ),
    home: Navigation(),
    );
  }
}