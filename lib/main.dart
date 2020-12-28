import 'package:flutter/material.dart';
import 'package:daun_herbal/splashscreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klasifikasi Daun Herbal',
      home: MySplash(),
      debugShowCheckedModeBanner: false,
    );
  }
}


