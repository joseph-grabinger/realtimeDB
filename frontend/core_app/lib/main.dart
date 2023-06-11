import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'src/navigation.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoreApp());
}

class CoreApp extends StatelessWidget {
  const CoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Realtime Database Interface',
      theme: ThemeData(
        primaryColor: Colors.purple[600],
      ),
    home: Navigation(),
    );
  }
}
