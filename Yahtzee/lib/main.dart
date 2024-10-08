import 'package:flutter/material.dart';
import 'package:mp2/views/yahtzee.dart';

void main() {
  runApp(const YahtzeeApp());
}

class YahtzeeApp extends StatelessWidget {
  const YahtzeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Yahtzee'),
        ),
        body: const YahtzeeGame(),
      ),
    );
  }
}
