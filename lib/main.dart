import 'package:flutter/material.dart';
import 'package:gift_list/screens/home/home_screen.dart';
import 'package:gift_list/screens/landing/landing_screen.dart';

void main() => runApp(new GiftListApp());

class GiftListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Gift List',
      theme: new ThemeData(
        primarySwatch: Colors.pink,
      ),
      routes: <String, WidgetBuilder>{
        '/': (context) => new HomeScreen(),
        '/landing': (context) => new LandingScreen()
      },
      initialRoute: '/landing',
    );
  }
}
