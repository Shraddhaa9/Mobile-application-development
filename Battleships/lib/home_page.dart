import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'game_card.dart';
import 'utils/session_manager.dart';
import 'utils/auth_service.dart';
import 'battle_ships.dart';
import 'game_board.dart';
import 'finished_list.dart';
import 'utils/icons.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  String currentUser = "";
  HomePage({required this.currentUser});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  List<GameCard> games = [];
  List<GameCard> completedGames = [];
  String currentUserName = "";
  List<GameCard> fetchedGames = [];

  @override
  void initState() {
    super.initState();
    _fetchGames(); // Fetch the list of games when the page is initialized
    currentUserName = widget.currentUser;
  }

  Future<void> _fetchGames() async {
    try {
      // Fetch the list of games for the current user
      fetchedGames = await _getGamesForCurrentUser();

      setState(() {
        completedGames = [];
        games = fetchedGames;
        for (int i = 0; i < games.length; i++) {
          if (games[i].status == '1' || games[i].status == '2') {
            completedGames.add(games[i]);
          }
        }
        games.removeWhere((element) => completedGames.contains(element));
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching games: $e');
      }
    }
  }

  Future<List<GameCard>> _getGamesForCurrentUser() async {
    final response = await http.get(
      Uri.parse('http://165.227.117.48/games'),
      headers: {
        'Authorization': 'Bearer ${await SessionManager.getSessionToken()}'
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('games')) {
        final List<dynamic> gamesData = data['games'];
        final value = gamesData.map<GameCard>((gameData) {
          return GameCard(
            id: gameData['id'].toString(),
            player1: gameData['player1'],
            player2: gameData['player2'] ?? 'waiting for player',
            status: gameData['status'].toString(),
            turn: gameData['turn'].toString(),
            position: gameData['position'].toString(),
            method: () {},
            currentPlayer: gameData['currentPlayer'].toString(),
          );
        }).toList();

        return value;
      } else {
        throw Exception('Key "games" not found in the response');
      }
    } else {
      throw Exception('Failed to fetch games');
    }
  }

  static Future<String> getUsernameFromToken() async {
    try {
      final String token = await SessionManager.getSessionToken();

      if (token == null) {
        throw Exception('Session token is null');
      }

      // Add padding if needed to the entire token
      final String paddedToken = token + '=' * (token.length % 4);

      // Decode the entire token to get the payload
      final List<String> parts = paddedToken.split('.');

      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }

      final String payload = parts[1];

      // Add padding for base64 decoding
      final String decodedPayload = utf8.decode(
        base64Url.decode(payload.padRight((payload.length + 3) ~/ 4 * 4, '=')),
      );
      // Parse the decoded payload as JSON to get the map
      final Map<String, dynamic> decodedData = jsonDecode(decodedPayload);
      // Retrieve the username from the map or a nested map
      final String? username =
          decodedData['username'] ?? decodedData['user']['username'];

      if (username == null) {
        throw Exception('Username not found in token');
      }

      return username;
    } catch (e) {
      if (kDebugMode) print('Error in getUsernameFromToken: $e');
      rethrow;
    }
  }

  void _fetchCompletedGames() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FinishedList(
                  completedGames: completedGames,
                  currentPlayer: currentUserName,
                )));
  }

  void _startGame() async {
    // Wait for the result from the GameBoard page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GameBoard(
                currentUserName: currentUserName,
                ai: "",
              )),
    );
    // Check if the result is not null and update the UI accordingly
    if (result != null) {
      setState(() {
        games.add(result);
        // Fetch the updated list of games
        _fetchGames();
      });
    }
  }

  void _logout() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const BattleShips()));
  }

  void _refresh() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(currentUser: widget.currentUser),
      ),
    );
  }

  void _startGameAIType(String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              GameBoard(currentUserName: currentUserName, ai: type)),
    );
    if (result != null) {
      // Assuming result is a Game object, add it to the games list
      setState(() {
        games.add(result);
      });
    }
    // Fetch the updated list of games
    _fetchGames();
  }

  void _startGameWithAI() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Which AI do you want to play against?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                0.0), // Set borderRadius to 0.0 for square corners
          ),
          content: SizedBox(
            width: 200.0,
            height: 150, // Set a fixed width for the AlertDialog
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                        onTap: () {
                          _startGameAIType("random");
                        },
                        child: const SizedBox(
                            width: 180, height: 40, child: Text('Random'))),
                    GestureDetector(
                        onTap: () {
                          _startGameAIType("perfect");
                        },
                        child: const SizedBox(
                            width: 180, height: 40, child: Text('Perfect'))),
                    GestureDetector(
                        onTap: () {
                          _startGameAIType("oneship");
                        },
                        child: const SizedBox(
                            width: 180,
                            height: 40,
                            child: Text('One Ship(A1)'))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('My Games'),
        actions: <Widget>[
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'BattleShips',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Logged in as $currentUserName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            IconButtonWithText(
                onPressed: _startGame, title: "New Game", icon: Icons.add),
            IconButtonWithText(
                onPressed: _startGameWithAI,
                title: "New Game (AI)",
                icon: Icons.smart_toy_rounded),
            IconButtonWithText(
                onPressed: _fetchCompletedGames,
                title: "Show Completed Games",
                icon: Icons.list),
            IconButtonWithText(
                onPressed: _logout, title: "Logout", icon: Icons.logout),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: GameCard(
            id: games[index].id,
            player1: games[index].player1,
            player2: games[index].player2,
            status: games[index].status,
            turn: games[index].turn,
            position: games[index].position,
            method: _refresh,
            currentPlayer: widget.currentUser,
          ));
        },
      ),
    );
  }
}
