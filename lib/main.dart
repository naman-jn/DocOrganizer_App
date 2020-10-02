import 'package:document_organizer/screens/drawer.dart';
import 'package:flutter/material.dart';
import 'package:document_organizer/screens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doc Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: Stack(
        children: [
          DrawerScreen(),
          Home(),
        ],
      ),
    );
  }
}
