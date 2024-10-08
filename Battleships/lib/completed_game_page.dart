import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'utils/session_manager.dart';
import 'utils/icons.dart';

// ignore: must_be_immutable
class CompletedGamePage extends StatefulWidget {
  String id;
  String ai;
  String name;
  CompletedGamePage({required this.id, required this.ai, required this.name});
  @override
  _CompletedGamePageState createState() => _CompletedGamePageState();
}

class _CompletedGamePageState extends State<CompletedGamePage> {
  String id = "";
  List<List<int>> board = List.generate(5, (_) => List<int>.filled(5, -1));
  List<List<String>> positions =
      List.generate(5, (_) => List<String>.filled(5, ""));
  List<List<bool>> checked =
      List.generate(5, (_) => List<bool>.filled(5, false));
  List<String> columnElements = ["", "1", "2", "3", "4", "5"];
  List<String> rowElements = ["A", "B", "C", "D", "E"];
  List<List<Color>> buttonColors =
      List.generate(5, (_) => List<Color>.filled(5, Colors.white));
  List<List<MultiIcons>> icons = List.generate(
    5,
    (_) => List.generate(
      5,
      (_) => MultiIcons(icons: const []),
    ),
  );

  List<List<int>> sunkPieces = [];
  List<List<int>> wreckPieces = [];
  List<List<int>> shotPieces = [];
  List<List<int>> shipPieces = [];
  List<int> selected = [];
  int turn = 0;
  String ai = "";
  String name = "";
  int position = 0;
  Future<void> _getGamesForCurrentUser() async {
    final response = await http.get(
      Uri.parse('http://165.227.117.48/games/$id'),
      headers: {
        'Authorization': 'Bearer ${await SessionManager.getSessionToken()}'
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        turn = data['turn'];
        position = data['position'];
        for (int i = 0; i < data['shots'].length; i++) {
          String shipLocation = data['shots'][i];
          int row = rowElements.indexOf(shipLocation[0]);
          int col = int.parse(shipLocation[1]) - 1;
          if (!icons[row][col]
              .icons
              .contains(const Icon(Icons.gps_not_fixed, color: Colors.black))) {
            icons[row][col]
                .icons
                .add(const Icon(Icons.gps_not_fixed, color: Colors.black));
          }
        }

        for (int i = 0; i < data['sunk'].length; i++) {
          String shipLocation = data['sunk'][i];
          int row = rowElements.indexOf(shipLocation[0]);
          int col = int.parse(shipLocation[1]) - 1;

          if (icons[row][col].icons.any((icon) =>
              icon.icon == Icons.gps_not_fixed && icon.color == Colors.black)) {
            icons[row][col].icons.removeWhere((icon) =>
                icon.icon == Icons.gps_not_fixed && icon.color == Colors.black);
          }
          // Check if the icon is not already present
          if (!icons[row][col].icons.any((icon) =>
              icon.icon == Icons.whatshot && icon.color == Colors.orange)) {
            icons[row][col]
                .icons
                .add(const Icon(Icons.whatshot, color: Colors.orange));
          }
        }

        for (int i = 0; i < data['ships'].length; i++) {
          String shipLocation = data['ships'][i];
          int row = rowElements.indexOf(shipLocation[0]);
          int col = int.parse(shipLocation[1]) - 1;
          // Check if the icon is not already present
          if (!icons[row][col]
              .icons
              .contains(const Icon(Icons.directions_boat))) {
            icons[row][col].icons.add(const Icon(Icons.directions_boat));
          }
        }

        for (int i = 0; i < data['wrecks'].length; i++) {
          String shipLocation = data['wrecks'][i];
          int row = rowElements.indexOf(shipLocation[0]);
          int col = int.parse(shipLocation[1]) - 1;
          // Check if the icon is not already present
          if (!icons[row][col]
              .icons
              .contains(const Icon(Icons.bubble_chart, color: Colors.blue))) {
            icons[row][col]
                .icons
                .add(const Icon(Icons.bubble_chart, color: Colors.blue));
          }
        }
      });
    } else {
      throw Exception('Failed to fetch games');
    }
  }

  @override
  void initState() {
    id = widget.id;
    if (kDebugMode) print(widget.name);

    _getGamesForCurrentUser();
    super.initState();
    ai = widget.ai;
    name = widget.name;
    if (kDebugMode) print(name);
  }

  void _previousPage() {
    if (kDebugMode) print(widget.name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    double buttonSize =
        screenHeight > screenWidth ? screenWidth / 7 : screenHeight / 7;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("Game page"),
          leading: IconButton(
            onPressed: _previousPage,
            icon: const Icon(Icons.arrow_back),
          )),
      body: SafeArea(
        child: Column(
          children: [
            GridView.builder(
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
                                    if (selected.isNotEmpty) {
                                      checked[selected[0]][selected[1]] ^= true;
                                      buttonColors[selected[0]][selected[1]] =
                                          Colors.white;
                                      selected = [];
                                    }
                                    checked[row][col] ^= true;
                                    if (checked[row][col]) {
                                      buttonColors[row][col] = Colors.blue;
                                    } else {
                                      buttonColors[row][col] = Colors.white;
                                    }
                                    selected.add(row);
                                    selected.add(col);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColors[row][col],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  fixedSize: Size(buttonSize, buttonSize),
                                ),
                                child: icons[row][col].icons.isNotEmpty
                                    ? icons[row][col]
                                    : const Text(""),
                              ),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: null,
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
