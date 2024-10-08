import 'package:flutter/material.dart';
import 'package:mp3/models/deck_collection.dart';
import 'package:mp3/views/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => DeckCollection(),
        child: const HomePage(),
      )));
}
