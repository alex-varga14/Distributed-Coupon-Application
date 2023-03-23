import 'package:distributed_coupon_application/pages/WelcomePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 234, 229, 229),
          primaryColor: const Color.fromARGB(255, 93, 175, 191),
          appBarTheme:
              const AppBarTheme(color: Color.fromARGB(255, 93, 175, 191))),
    );
  }
}
