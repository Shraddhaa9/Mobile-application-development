import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';

// ignore: must_be_immutable
class GameBoard extends StatefulWidget {
  String currentUserName;
  String ai;
  GameBoard({required this.currentUserName, required this.ai});

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final String baseUrl = 'http://165.227.117.48';
  List<List<int>> board = List.generate(5, (_) => List<int>.filled(5, -1));
  List<List<bool>> checked =
      List.generate(5, (_) => List<bool>.filled(5, false));
  int selectedButtons = 0;
  List<List<int>> selectedButtonsList = [];
  List<String> columnElements = ["", "1", "2", "3", "4", "5"];
  List<String> rowElements = ["A", "B", "C", "D", "E"];
  List<String> shipPlaces = [];
  List<List<Color>> buttonColors =
      List.generate(5, (_) => List<Color>.filled(5, Colors.white));
  @override
  void initState() {
    shipPlaces = [];
    selectedButtons = 0;
    selectedButtonsList = [];
    super.initState();
  }

  void savePlaces() async {
    setState(() {
      selectedButtonsList = [];
      shipPlaces = [];
      for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
          if (buttonColors[i][j] == Colors.blue) {
            selectedButtonsList.add([i, j]);
          }
        }
      }
      for (int i = 0; i < 5; i++) {
        int row = selectedButtonsList[i][0];
        int col = selectedButtonsList[i][1];
        shipPlaces.add(rowElements[row] + columnElements[col + 1]);
      }
      if (kDebugMode) print(shipPlaces);
    });

    try {
      Map<String, dynamic> newGame = {"ships": shipPlaces};
      if (widget.ai != "") {
        newGame['ai'] = widget.ai;
        if (kDebugMode) print(newGame['ai']);
      }
      String gameJSON = jsonEncode(newGame);
      if (kDebugMode) print(gameJSON);
      final response = await http.post(
        Uri.parse('$baseUrl/games'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await SessionManager.getSessionToken()}'
        },
        body: gameJSON,
      );
      if (kDebugMode) {
        print(response.body);
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        // Pop the GameBoard page with the game data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              currentUser: widget.currentUserName,
            ),
          ),
        );
      } else {
        throw Exception(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      if (kDebugMode) print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double buttonSize = screenWidth / 6;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Battle Ships"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: 6 * 6,
                itemBuilder: (context, index) {
                  int row = index ~/ 6 - 1;
                  int col = index % 6 - 1;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 10),
                    child: GridTile(
                      child: row == -1
                          ? Center(child: Text(columnElements[col + 1]))
                          : col == -1
                              ? Center(child: Text(rowElements[row]))
                              : ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      checked[row][col] ^= true;
                                      if (checked[row][col]) {
                                        buttonColors[row][col] = Colors.blue;
                                        selectedButtons++;
                                      } else {
                                        buttonColors[row][col] = Colors.white;
                                        selectedButtons--;
                                      }
                                    });
                                    if (kDebugMode) {
                                      print(checked[row][col]);
                                      print(
                                          'Button pressed at row: $row, column: $col');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColors[row][col],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    minimumSize: Size(buttonSize, buttonSize),
                                  ),
                                  child: const Text(" "),
                                ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: selectedButtons == 5 ? savePlaces : null,
              child: const SizedBox(
                width: 60,
                height: 30,
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
