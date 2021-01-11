import 'package:flutter/material.dart';
import 'screen/home.dart';
void main() {
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dictionary App',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
