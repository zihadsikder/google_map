import 'package:flutter/material.dart';

import 'home_screen.dart';

void main(){
  runApp(const GoogleApp());
}
class GoogleApp extends StatelessWidget {
  const GoogleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}
