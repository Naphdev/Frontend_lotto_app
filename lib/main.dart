import 'package:flutter/material.dart';
import 'package:lotto_app/pages/adminpages/admin1.dart';
import 'package:lotto_app/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        // home: admin1(),
        home: loginPage(),
        theme: ThemeData(useMaterial3: true));
  }
}
