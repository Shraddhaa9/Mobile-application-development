import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'utils/session_manager.dart';
import 'home_page.dart';
import 'utils/icons.dart';

// ignore: must_be_immutable
class GamePage extends StatefulWidget {
  String id;
  String ai;
  String name;
  GamePage({required this.id, required this.ai, required this.name});
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
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
      (_) => MultiIcons(icons: []),
    ),
  );
  // Separate color for each button
  List<List<int>> sunkPieces = [];
  List<List<int>> wreckPieces = [];
  List<List<int>> shotPieces = [];
  List<List<int>> shipPieces = [];
  List<int> selected = [];
  int turn = 0;
  String ai = "";
  String name = "";
  int position = 0;
  int status = 0;
  String currentPlayer = "";
  String opponentPlayer = "";
  String player1 = "";
  String player2 = "";
  Future<void> _getGamesForCurrentUser() async {
    final response = await http.get(
      Uri.parse('http://165.227.117.48/games/$id'),
      headers: {
        'Authorization': 'Bearer ${await SessionManager.getSessionToken()}'
      },
    );
    if (kDebugMode) print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      currentPlayer = widget.name;
      opponentPlayer =
          widget.name == data["player1"] ? data["player2"] : data["player1"];
      setState(() {
        turn = data['turn'];
        position = data['position'];
        status = data['status'];
        player1 = data['player1'];
        player2 = data['player2'];
        for (int i = 0; i < data['shots'].length; i++) {
          String shipLocation = data['shots'][i];
          int row = rowElements.indexOf(shipLocation[0]);
          int col = int.parse(shipLocation[1]) - 1;
          if (!icons[row][col]
              .icons
              .contains(Icon(Icons.gps_not_fixed, color: Colors.black))) {
            icons[row][col]
                .icons
                .add(Icon(Icons.gps_not_fixed, color: Colors.black));
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
                .add(Icon(Icons.whatshot, color: Colors.orange));
          }
        }

        for (int i = 0; i < data['ships'].length; i++) {
          String shipLocation = data['ships'][i];
          int row = rowElements.indexOf(shipLocation[0]);
          int col = int.parse(shipLocation[1]) - 1;
          // Check if the icon is not already present
          if (!icons[row][col].icons.contains(Icon(Icons.directions_boat))) {
            icons[row][col].icons.add(Icon(Icons.directions_boat));
          }
        }

        for (int i = 0; i < data['wrecks'].length; i++) {
          String shipLocation = data['wrecks'][i];
          int row = rowElements.indexOf(shipLocation[0]);
          int col = int.parse(shipLocation[1]) - 1;
          // Check if the icon is not already present
          if (!icons[row][col]
              .icons
              .contains(Icon(Icons.bubble_chart, color: Colors.blue))) {
            icons[row][col]
                .icons
                .add(Icon(Icons.bubble_chart, color: Colors.blue));
          }
        }
      });
    } else {
      throw Exception('Failed to fetch games');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _place() async {
    if (selected.isEmpty) {
      _showErrorDialog(
          'Invalid Move', 'Please select a block before submitting.');
      return;
    }

    final row = rowElements[selected[0]];
    final col = (selected[1] + 1).toString();
    final shot = '$row$col';
    final response = await http.put(
      Uri.parse('http://165.227.117.48/games/$id'),
      headers: {
        'Authorization': 'Bearer ${await SessionManager.getSessionToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'shot': shot}),
    );
    try {
      if (response.statusCode == 200) {
        setState(() {
          _getGamesForCurrentUser();
        });
        if (sunkPieces.length == 5) {
          _showErrorDialog("Game Over", "$currentPlayer won");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                currentUser: widget.name,
              ),
            ),
          );
        }
        if (wreckPieces.length == 5) {
          _showErrorDialog("Game Over", "$opponentPlayer won");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                currentUser: widget.name,
              ),
            ),
          );
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GamePage(id: widget.id, ai: widget.ai, name: widget.name),
          ),
        );
      } else {
        _showErrorDialog('Invalid Move', 'Shot is made here');

        throw Exception('Invalid Move');
      }
    } catch (e) {
      if (kDebugMode) print("Exception$e");
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          currentUser: widget.name,
        ),
      ),
    );
  }

  Future<void> _showGameStatusDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Status'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      currentUser: widget.name,
                    ),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    if (kDebugMode) print(screenWidth);
    if (kDebugMode) print(screenHeight);
    double buttonSize = MediaQuery.of(context).size.shortestSide / 7;

    if (kDebugMode) print(buttonSize);
    if (status == 1 || status == 2) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showGameStatusDialog(status == 1 ? "$player1 won" : "$player2 won");
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Game page"),
        leading: IconButton(
          onPressed: _previousPage,
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: 6 * 6,
                itemBuilder: (context, index) {
                  int row = index ~/ 6 - 1;
                  int col = index % 6 - 1;

                  return Padding(
                    padding: EdgeInsets.only(right: 10, bottom: 10),
                    child: GridTile(
                      child: row == -1
                          ? Center(child: Text(columnElements[col + 1]))
                          : col == -1
                              ? Center(child: Text(rowElements[row]))
                              : ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (selected.isNotEmpty) {
                                        checked[selected[0]][selected[1]] ^=
                                            true;
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
            ),
            ElevatedButton(
              onPressed: position == turn
                  ? status == 3
                      ? _place
                      : null
                  : null,
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
