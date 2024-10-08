import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'utils/session_manager.dart';
import 'game_page.dart';

class GameCard extends StatefulWidget {
  String id;
  String player1;
  String player2;
  String status;
  String turn;
  String position;
  String currentPlayer;
  VoidCallback method;
  GameCard(
      {required this.id,
      required this.player1,
      required this.player2,
      required this.status,
      required this.turn,
      required this.position,
      required this.method,
      required this.currentPlayer});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  String id = "";
  String player1 = "";
  String player2 = "";
  String status = "";
  String turn = "";
  String position = "";
  String ai = "";
  String currentPlayer = "";

  @override
  void initState() {
    get();
    super.initState();
  }

  void get() {
    id = widget.id;
    player1 = widget.player1;
    player2 = widget.player2;
    status = widget.status;
    turn = widget.turn;
    position = widget.position;
    currentPlayer = widget.currentPlayer;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.id),
      onDismissed: (direction) async {
        final response = await http.delete(
          Uri.parse('http://165.227.117.48/games/$id'),
          headers: {
            'Authorization': 'Bearer ${await SessionManager.getSessionToken()}'
          },
        );
        if (response.statusCode == 200) {
          if (kDebugMode) ("Deletion Successful");
        } else {
          throw Exception('Failed to delete game');
        }
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(
                id: id,
                ai: ai,
                name: widget.currentPlayer,
              ),
            ),
          );
          setState(() {
            widget.method;
          });
        },
        child: Row(
          children: [
            Text(
              "#$id",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "$player1 vs $player2",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: player2 == "waiting for player"
                    ? const Text(
                        "matchMaking",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : status == 1
                        ? Text(
                            "$player1 won",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : status == 2
                            ? Text(
                                "$player2 won",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            : turn == position
                                ? const Text(
                                    "myTurn",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : const Text(
                                    "OpponentTurn",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
