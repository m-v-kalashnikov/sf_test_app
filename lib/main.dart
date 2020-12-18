import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf_test_app/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    return MaterialApp(
      title: 'SFactor',
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}



